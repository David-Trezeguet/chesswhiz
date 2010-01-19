/***************************************************************************
 *  Copyright 2009-2010 Bharatendra Boddu <bharathendra@yahoo.com>         *
 *                      Huy Phan  <huyphan@playxiangqi.com>                *
 *                                                                         * 
 *  This file is part of ChessWhiz.                                        *
 *                                                                         *
 *  ChessWhiz is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  ChessWhiz is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with ChessWhiz.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/

package
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.Socket;
	
	import hoxserver.*;
	
	import mx.core.Application;
	import mx.core.Container;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import ui.AppPreferences;
	import ui.ChatPanel;
	import ui.LoginPanel;
	import ui.PlayerListPanel;
	import ui.TableList;

	public class ChessApp
	{
		private var _mainWindow:Container;
		private var _playerWindow:PlayerListPanel;
		private var _chatPanel:ChatPanel = null;

		private var _preferences:Object;
		private var _sharedObject:SharedObject;

		private var _playerId:String  = "";
		private var _session:Session  = new Session();
		private var _loginFailReason:String = "";

		private var _table:Table      = null;  // THE table.

		public function ChessApp(window:Container, playersPanel:PlayerListPanel)
		{
			_mainWindow = window;
			_playerWindow = playersPanel;

			_preferences =
				{
					"pieceskin"  : 1,
					"boardcolor" : 0x333333,
					"linecolor"  : 0xa09e9e,
					"sound"      : true,
					"movemode"   : 0
				};
			_loadPreferencesFromLocalSharedObject();

			Global.player = new PlayerInfo("", "None", "0");

			_table = new Table("", _preferences, Application.application.mainBoard);

			_startApp();
		}

		private function _loadPreferencesFromLocalSharedObject() : void
		{
			try {
				_sharedObject = SharedObject.getLocal("flashchess");
				if (_sharedObject.data.persist == 0xFFDDF2)
				{
					_preferences["pieceskin"]  = _sharedObject.data.pieceskin;
					_preferences["boardcolor"] = _sharedObject.data.boardcolor;
					_preferences["linecolor"]  = _sharedObject.data.linecolor;
					_preferences["sound"]      = _sharedObject.data.sound;
					_preferences["movemode"]   = _sharedObject.data.movemode;
				}
			}
			catch (error:Error) {
				trace("Error: Failed to get the shared object: " + error);
			} 
		}

		private function _savePreferencesToLocalSharedObject() : void
		{
			_sharedObject.data.persist    = 0xFFDDF2; // "Present" flag.
			_sharedObject.data.pieceskin  = _preferences["pieceskin"];
			_sharedObject.data.boardcolor = _preferences["boardcolor"];
			_sharedObject.data.linecolor  = _preferences["linecolor"];
			_sharedObject.data.sound      = _preferences["sound"];
			_sharedObject.data.movemode   = _preferences["movemode"];

			var flushStatus:String = null;
            try {
				flushStatus = _sharedObject.flush( 10*1024 /* minDiskSpace */ );
			}
			catch (error:Error) {
				trace("Error: Failed to flush the shared object: " + error);
			}

			switch (flushStatus) {
				case SharedObjectFlushStatus.PENDING:
					trace("Flush-Status: Requesting permission to save object...");
					_sharedObject.addEventListener(NetStatusEvent.NET_STATUS, _onFlushStatus);
					break;
				case SharedObjectFlushStatus.FLUSHED:
					trace("Flush-Status: Shared object successfully flushed to disk.");
					break;
			}
		}

        private function _onFlushStatus(event:NetStatusEvent) : void
        {
            switch (event.info.code) {
                case "SharedObject.Flush.Success":
                    trace("On Flush-Status: User granted permission -- value saved.");
                    break;
                case "SharedObject.Flush.Failed":
                    trace("On Flush-Status: User denied permission -- value not saved.");
                    break;
            }

            _sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, _onFlushStatus);
        }

		private function _startApp() : void
		{
			_session.open();
		}

		private function _stopApp() : void
		{
			_session.close();
			_playerId = "";
			Global.player.pid = "";
			Global.player.score = "0";
			Global.player.color = "None";
			_table.setTableId("");

			Application.application.currentState = "loginState";
		}

		public function processSocketConnectEvent() : void
		{
			trace("Connection to server established.");

			Application.application.currentState = "loginState";
			var loginPanel:LoginPanel = Application.application.mainWindow.getChildAt(0);
			loginPanel.errorString = _loginFailReason;
		}

		public function processSocketCloseEvent() : void
		{
			trace("Connection to server lost.");
		}

		public function doLogin(pid:String, passwd:String = "") : void
		{
			_playerId = pid;
			_session.sendLoginRequest(pid, passwd, Global.LOGIN_VERSION);
		}

		public function doGuestLogin() : void
		{
			const randNumber:Number = Math.ceil( 9999*Math.random() );
			this.doLogin( "Guest#fx" + randNumber );
		}

		public function doLogout() : void
		{
			_session.sendLogoutRequest(_playerId);
			_stopApp();
			_startApp();
		}

		public function doViewTables() : void
		{
			_session.sendTableListRequest(_playerId);
		}

		public function doNewTable() : void
		{
			if ( _table.valid() )
			{
				_session.sendLeaveRequest(_playerId, _table.tableId);
			}
			_session.sendNewTableRequest(_playerId, "Red", "1200/240/20");
		}
		
		public function doJoinTable(tableId:String, color:String = "None") : void
		{
			if ( _table.valid() )
			{
				if ( _table.tableId != tableId )
				{
					_session.sendLeaveRequest(_playerId, _table.tableId);
				}
				else if (_table.isPlayerPlaying(_playerId) )
				{
					_session.sendJoinRequest(_playerId, tableId, "None");
				}
			}
			_session.sendJoinRequest(_playerId, tableId, color);
		}

		public function doCloseTable() : void
		{
			if ( _table.valid() ) {
				_session.sendLeaveRequest(_playerId, _table.tableId);
			}
		}

		public function doResignTable() : void
		{
			if ( _table.valid() ) {
				_session.sendResignRequest(_playerId, _table.tableId);
			}
		}

		public function doDrawTable() : void
		{
			if ( _table.valid() ) {
				_session.sendDrawRequest(_playerId, _table.tableId);
			}
		}

		public function doResetTable() : void
		{
			if ( _table.valid() ) {
				_session.sendResetRequest(_playerId, _table.tableId);
			}
		}

		/**
		 * Handle two types of messages:
		 *   (1) "Table message (sent to all players at THE table).
		 *   (2) "Private" message (sent specifically to a player).
		 *
		 * @param oid (OPTIONAL) If present, then the message is private
		 *                       to only the specified player.
		 */
		public function doSendMessage(msg:String, oid:String = "") : void
		{
			if ( oid != "" ) { // Private message.
				_session.sendChatRequest(_playerId, msg, "" /* table-Id */, oid);
			}
			else if ( _table.valid() ) { // Table message.
				_session.sendChatRequest(_playerId, msg, _table.tableId);
			}
		}

		public function doSendMove(curPos:Position, newPos:Position) : void
		{
			if ( _table.valid() ) {
				_session.sendMoveRequest(_playerId, curPos, newPos, _table.tableId);
			}
		}

		public function doUpdateTableSettings(itimes:String, bRated:Boolean) : void
		{
			if ( _table.valid() ) {
				_session.sendUpdateTableRequest(_playerId, _table.tableId, itimes, bRated);
			}
		}

		public function doQueryPlayerInfo(pid:String) : void
		{
			_session.sendQueryPlayerInfoRequest(_playerId, pid);
		}

		public function doInvitePlayer(pid:String) : void
		{
			_session.sendInvitePlayerRequest(_playerId, pid, _table.tableId);
		}

		public function changeAppPreferences() : void
		{
			var preferencesPanel:AppPreferences = new AppPreferences();
			PopUpManager.addPopUp(preferencesPanel, _mainWindow, true /* modal */);
			PopUpManager.centerPopUp(preferencesPanel);
			preferencesPanel.preferences = ObjectUtil.copy(_preferences);
			preferencesPanel.addEventListener("newPreferences", newPreferencesEventHandler);
		}

		/**
		 * Callback function to handle the "newPreferences" event generated
		 * by the 'AppPreferences' window.
		 */
		private function newPreferencesEventHandler(event:Event) : void
		{
			var preferencesPanel:AppPreferences = event.target as AppPreferences;
			if ( preferencesPanel != null )
			{
				const pref:Object = preferencesPanel.preferences;
				_table.updatePreferences(pref);

				for (var key:String in pref) {
					_preferences[key] = pref[key];
				}
				_savePreferencesToLocalSharedObject();
			}
		}

		public function popupPrivateChatWindow(otherPlayerId:String) : void
		{
			/* Enforce the rule that only one Private Chat Session
			 * (with one other player) exists at one time.
			 */
			if ( _chatPanel )
			{
				trace("Private Chat Session has been taken.");
				return;
			}

			_chatPanel = new ChatPanel();
			_chatPanel.showCloseButton = true;
			_chatPanel.otherPlayerId = otherPlayerId;
			PopUpManager.addPopUp(_chatPanel, _mainWindow, false /* modeless */);
			PopUpManager.centerPopUp(_chatPanel);
			_chatPanel.addEventListener("newChatMessage", _newChatMessageEventHandler);
			_chatPanel.addEventListener("closeButton", _closeButtonEventHandler);
		}

		/**
		 * Callback function to handle the "newChatMessage" event generated
		 * by the 'ChatPanel' window.
		 */
		private function _newChatMessageEventHandler(event:Event) : void
		{
			if ( _chatPanel )
			{
				this.doSendMessage(_chatPanel.newMessage, _chatPanel.otherPlayerId);
			}
		}

		/**
		 * Callback function to handle the "closeButton" event generated
		 * by the 'ChatPanel' window.
		 */
		private function _closeButtonEventHandler(event:Event) : void
		{
			if ( _chatPanel != null )
			{
				PopUpManager.removePopUp(_chatPanel);
				_chatPanel = null;
			}
		}

		/**
		 * @note There can be multiple messages/events in the response body
		 */
		public function handleServerEvent(event:ProgressEvent) : void
		{
			var socket:Socket = event.target as Socket;
			if ( socket == null )
			{
				trace("Error: Unexpected target, which is not a 'Socket' type.");
				return;
			}
			const data:String = socket.readUTFBytes(socket.bytesAvailable);
			const messages:Array = data.split("op");

			for (var i:int = 0; i < messages.length; i++)
			{
				if (messages[i] == "") continue;

				const line:Array = messages[i].split("\n\n");
				trace("event: op" + line[0]);
				const msg:Message = new Message( "op" + line[0] );

				if      (msg.optype == "LOGIN")       { _processEvent_LOGIN(msg);       }
				else if (msg.optype == "I_PLAYERS")   { _processEvent_I_PLAYERS(msg);   }
				else if (msg.optype == "LIST")        { _processEvent_LIST(msg);        }
				else if (msg.optype == "I_TABLE")     { _processEvent_I_TABLE(msg);     }
				else if (msg.optype == "E_JOIN")      { _processEvent_E_JOIN(msg);      }
				else if (msg.optype == "MOVE")        { _processEvent_MOVE(msg);        }
				else if (msg.optype == "E_END")       { _processEvent_E_END(msg);       }
				else if (msg.optype == "LOGOUT")      { _processEvent_LOGOUT(msg);      }
				else if (msg.optype == "I_MOVES")     { _processEvent_I_MOVES(msg);     }
				else if (msg.optype == "LEAVE")       { _processEvent_LEAVE(msg);       }
				else if (msg.optype == "DRAW")        { _processEvent_DRAW(msg);        }
				else if (msg.optype == "MSG")         { _processEvent_MSG(msg);         }
				else if (msg.optype == "UPDATE")      { _processEvent_UPDATE(msg);      }
				else if (msg.optype == "RESET")       { _processEvent_RESET(msg);       }
				else if (msg.optype == "PLAYER_INFO") { _processEvent_PLAYER_INFO(msg); }
				else if (msg.optype == "INVITE")      { _processEvent_INVITE(msg);      }
				else if (msg.optype == "E_SCORE")     { _processEvent_E_SCORE(msg);     }
			}
		}

		private function _processEvent_LOGIN(event:Message) : void
		{
			if (event.getCode() != 0)
			{
				_loginFailReason = event.getContent();
				_session.close();
				_startApp();
				return;
			}

			const loginInfo:Object = event.parse_LOGIN();
			if ( loginInfo.pid == _playerId ) // My own Login success?
			{
				trace("My LOGIN = " + loginInfo.pid + "(" + loginInfo.score + ")"
									+ ", sessionid: " + loginInfo.sid);
				Global.player.pid = loginInfo.pid;
				Global.player.score = loginInfo.score;
				_session.setSid( loginInfo.sid );
				_loginFailReason = "";
				
				Application.application.currentState = "";
				Application.application.setPlayerLabel( loginInfo.pid, loginInfo.score );
				
				_table.setupEmptyTable();
				doViewTables(); // By default, get the List of Tables.
			}
			else
			{
				trace("Other LOGIN = " + loginInfo.pid + "(" + loginInfo.score + ")");
			}

			_playerWindow.addPlayer( loginInfo.pid, loginInfo.score );
		}

		private function _processEvent_LOGOUT(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const playerId:String = event.getContent(); 
			if (    _session.getSid() != ""
				 && playerId == _playerId )
			{
				_stopApp();
			}
			else
			{
				_playerWindow.removePlayer( playerId );
			}
        }

		private function _processEvent_I_PLAYERS(event:Message) : void
		{
			const players:Object = event.parse_I_PLAYERS();
			for each (var player:Object in players)
			{
				_playerWindow.addPlayer( player.pid, player.score );
			}
		}

		private function _processEvent_LIST(event:Message) : void
		{
			const tables:Object = event.parse_LIST();

			// Display the Tables view.

			var tableListPanel:TableList = new TableList();
			tableListPanel.setTableList(tables);
			if ( _table.valid() && _table.isPlayerPlaying(_playerId) )
			{
				tableListPanel.joinActionEnabled = false;
			}
			PopUpManager.addPopUp(tableListPanel, _mainWindow, true /* modal */);
			PopUpManager.centerPopUp(tableListPanel);
		}

		private function _processEvent_I_TABLE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const tableInfo:Object = event.parse_I_TABLE();

			const fields:Array = tableInfo.initialtime.split("/");
			const settings:Object =
				{
					"gametime"  : parseInt(fields[0]),
					"movetime"  : parseInt(fields[1]),
					"freetime"  : parseInt(fields[2]),
					"rated"     : tableInfo.rated
				};

			// Lookup the scores of observers using our internally Player-List.
			var detailedObversers:Array = [];
			for each (var oid:String in tableInfo.observers)
			{
				const score:String = _playerWindow.lookupPlayerScore(oid);
				detailedObversers.push( new PlayerInfo(oid, "None", score) );
			}
			tableInfo.observers = detailedObversers;

			_table.setupNewTable(tableInfo, settings);
		}

		private function _processEvent_E_JOIN(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const joinInfo:Object = event.parse_E_JOIN();

			if ( _table.tableId == joinInfo.tid )
			{
				_table.joinTable( new PlayerInfo(joinInfo.pid, joinInfo.color, joinInfo.score) );
			}
	    }
		
		private function _processEvent_MOVE(event:Message) : void
		{
			if ( ! _table.valid() ) {
				return;
			}

			if ( event.getCode() == 0 )
			{
				const moveInfo:Object = event.parse_MOVE();
				if ( _table.tableId == moveInfo.tid )
				{
					_table.handleNetworkMove( new Position(moveInfo.fromRow, moveInfo.fromCol),
											  new Position(moveInfo.toRow, moveInfo.toCol) );
				}
			}
			else
			{
				// This should not occur because we always validate the Move
				// before it is sent to the server.
				_table.processWrongMove(event.getContent());
			}
	    }

		private function _processEvent_I_MOVES(event:Message) : void
		{
			const moveList:Object = event.parse_I_MOVES();
			if (_table.tableId == moveList.tid)
			{
				_table.playMoveList(moveList.moves);
			}
		}
	
		private function _processEvent_LEAVE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const leaveInfo:Object = event.parse_LEAVE();
			if ( _table.tableId == leaveInfo.tid )
			{
				_table.leaveTable(leaveInfo.pid);
				if ( _playerId == leaveInfo.pid )
				{
					_table.closeCurrentTable();
				}
			}
		}
	
		private function _processEvent_E_END(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const endEvent:Object = event.parse_E_END();
			if ( _table.tableId == endEvent.tid )
			{
				_table.stopGame(endEvent.winner, endEvent.reason);
			}
		}
	
		private function _processEvent_DRAW(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const drawEvent:Object = event.parse_DRAW();
			if ( _table.tableId == drawEvent.tid )
			{
				_table.drawGame(drawEvent.pid);
			}
		}

		private function _processEvent_MSG(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const msgInfo:Object = event.parse_MSG();

			/* NOTE: There are 2 types of messages:
			 *  (1) For table messages, both "tid" and "pid" are present.
			 *  (2) For private messages, "tid" is missing.
			 */
			
			if ( msgInfo.tid == null )  // a private message?
			{
				_processEvent_MSG_private(msgInfo.pid, msgInfo.msg);
			}
			else if ( _table.tableId == msgInfo.tid )
			{
				_table.displayChatMessage(msgInfo.pid, msgInfo.msg);
			}
		}

		/**
		 * A helper function of _processEvent_MSG() to handle private messages.
		 *
		 * @also _processEvent_MSG()
		 */
		private function _processEvent_MSG_private(pid:String, msg:String) : void
		{
			if ( ! _chatPanel )
			{
				this.popupPrivateChatWindow(pid);
			}
			else if ( _chatPanel.otherPlayerId != pid )
			{
				/* This Player is different from the one I am chatting with!
				 * Simply display the message on the Table-Board.
				 */
				_table.displayChatMessage(pid, msg, true /* Private */);
				return;
			}

			_chatPanel.onMessageFrom(pid, msg);
		}

		private function _processEvent_UPDATE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const updateInfo:Object = event.parse_UPDATE();
			if ( _table.tableId == updateInfo.tid )
			{
				_table.updateTableSettings(updateInfo.itimes, updateInfo.rated);
			}
		}

		private function _processEvent_RESET(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const tableId:String = event.getContent();
			if ( _table.tableId == tableId )
			{
				_table.resetTable();
			}
		}

		private function _processEvent_PLAYER_INFO(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const playerInfo:Object = event.parse_PLAYER_INFO();
			_table.displayPlayerInfo(playerInfo);
		}

		private function _processEvent_INVITE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const inviteInfo:Object = event.parse_INVITE();
			_table.displayInvitation(inviteInfo);
		}

		private function _processEvent_E_SCORE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const scoreInfo:Object = event.parse_E_SCORE();
			_playerWindow.addPlayer(scoreInfo.pid, scoreInfo.score); // Add = Update.
			_table.updatePlayerScore(scoreInfo);
			if ( _playerId == scoreInfo.pid )
			{
				Application.application.setPlayerLabel( _playerId, scoreInfo.score );
			}
		}
	}
}
