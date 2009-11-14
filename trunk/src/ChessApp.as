package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Sound;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	import hoxserver.*;
	
	import mx.core.Container;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import ui.LoginPanel;
	import ui.PlayerListPanel;
	import ui.TableBoard;
	import ui.TableList;
	import ui.TablePreferences;
	import ui.TopControlBar;

	public class ChessApp
	{
		private var _menu:TopControlBar;
		private var _mainWindow:Container;
		private var _playerWindow:PlayerListPanel;
		private var _moveSound:Sound = new Global.moveSoundClass() as Sound;

		private var _preferences:Object;
		private var _sharedObject:SharedObject;

		private var _playerId:String  = "";
		private var _session:Session  = new Session();
		private var _loginFailReason:String = "";

		private var _requestingTable:Boolean = false;
		private var _table:Table      = null;  // THE table.

		public function ChessApp(menu:TopControlBar, window:Container, playersPanel:PlayerListPanel)
		{
			_menu       = menu;
			_mainWindow = window;
			_playerWindow = playersPanel;

			_preferences = {
					"pieceskin"  : 1,
					"boardcolor" : 0x333333,
					"linecolor"  : 0xa09e9e,
					"sound"      : true
				};
			_loadPreferencesFromLocalSharedObject();

			Global.player = new PlayerInfo("", "None", "0");

			_startApp();
		}

		private function _loadPreferencesFromLocalSharedObject() : void
		{
			try {
				_sharedObject = SharedObject.getLocal("flashchess");
				if (_sharedObject.data.persist == 0xFFDDF1)
				{
					_preferences["pieceskin"]  = _sharedObject.data.pieceskin;
					_preferences["boardcolor"] = _sharedObject.data.boardcolor;
					_preferences["linecolor"]  = _sharedObject.data.linecolor;
					_preferences["sound"]      = _sharedObject.data.sound;
				}
			}
			catch (error:Error) {
				trace("Error: Failed to get the shared object: " + error);
			} 
		}

		private function _savePreferencesToLocalSharedObject() : void
		{
			_sharedObject.data.persist    = 0xFFDDF1; // "Present" flag.
			_sharedObject.data.pieceskin  = _preferences["pieceskin"];
			_sharedObject.data.boardcolor = _preferences["boardcolor"];
			_sharedObject.data.linecolor  = _preferences["linecolor"];
			_sharedObject.data.sound      = _preferences["sound"];

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
			_table = null;
			_mainWindow.removeAllChildren();
			_playerWindow.visible = false;
			_playerWindow.includeInLayout = false;
		}

		public function addBoardToWindow(board:TableBoard) : void
		{
			_mainWindow.removeAllChildren();
			_mainWindow.addChild(board);
			_menu.currentState = "observerState";
		}

		public function processSocketConnectEvent() : void
		{
			trace("Connection to server established.");
			_menu.currentState = "";

			var loginPanel:LoginPanel = new LoginPanel();
			loginPanel.errorString = _loginFailReason;
			_mainWindow.addChild(loginPanel);
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
			if ( _table )
			{
				_session.sendLeaveRequest(_playerId, _table.tableId);
				_requestingTable = true;
			}
			_session.sendNewTableRequest(_playerId, "Red", "1200/240/20");
		}
		
		public function doJoinTable(tableId:String, color:String = "None") : void
		{
			if ( _table )
			{
				if ( _table.tableId != tableId )
				{
					_session.sendLeaveRequest(_playerId, _table.tableId);
					_requestingTable = true;
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
			if ( _table ) {
				_session.sendLeaveRequest(_playerId, _table.tableId);
			}
		}

		public function doResignTable() : void
		{
			if ( _table ) {
				_session.sendResignRequest(_playerId, _table.tableId);
			}
		}

		public function doDrawTable() : void
		{
			if ( _table ) {
				_session.sendDrawRequest(_playerId, _table.tableId);
			}
		}

		public function doResetTable() : void
		{
			if ( _table ) {
				_session.sendResetRequest(_playerId, _table.tableId);
			}
		}

		public function doTableChat(msg:String) : void
		{
			if ( _table ) {
				_session.sendChatRequest(_playerId, _table.tableId, msg);
			}
		}

		public function doSendMove(piece:Piece, curPos:Position, newPos:Position, tid:String) : void
		{
			if ( _table && _table.tableId == tid ) {
				_session.sendMoveRequest(_playerId, curPos, newPos, tid);
			}
		}

		public function doUpdateTableSettings(tid:String, itimes:String, bRated:Boolean) : void
		{
			if ( _table && _table.tableId == tid ) {
				_session.sendUpdateTableRequest(_playerId, tid, itimes, bRated);
			}
		}

		public function showObserverMenu() : void { _menu.currentState = "observerState"; }

		public function changeAppPreferences() : void
		{
			var preferencesPanel:TablePreferences = new TablePreferences();
			PopUpManager.addPopUp(preferencesPanel, _mainWindow, true /* modal */);
			PopUpManager.centerPopUp(preferencesPanel);
			preferencesPanel.preferences = ObjectUtil.copy(_preferences);
			preferencesPanel.applyCurrentPreferences();
			preferencesPanel.addEventListener("newPreferences", newPreferencesEventHandler);
		}

		/**
		 * Callback function to handle the "newPreferences" event generated
		 * by the 'TablePreferences' window.
		 */
		private function newPreferencesEventHandler(event:Event) : void
		{
			var preferencesPanel:TablePreferences = event.target as TablePreferences;
			if ( preferencesPanel != null )
			{
				const pref:Object = preferencesPanel.preferences;
				if (_table) {
					_table.updatePreferences(pref);
				}
				for (var key:String in pref) {
					_preferences[key] = pref[key];
				}
				_savePreferencesToLocalSharedObject();
			}
		}

		/**
		 * @note There can be multiple messages/events in the response body
		 */
		public function handleServerEvent(event:DataEvent) : void
		{
			const messages:Array = event.data.split("op");

			for (var i:int = 0; i < messages.length; i++)
			{
				if (messages[i] == "") continue;

				const line:Array = messages[i].split("\n\n");
				trace("event: op" + line[0]);
				const msg:Message = new Message( "op" + line[0] );

				if      (msg.optype == "LOGIN")   { _processEvent_LOGIN(msg);  }
				else if (msg.optype == "I_PLAYERS") { _processEvent_I_PLAYERS(msg); }
				else if (msg.optype == "LIST")    { _processEvent_LIST(msg);   }
				else if (msg.optype == "I_TABLE") { _processEvent_I_TABLE(msg);}
				else if (msg.optype == "E_JOIN")  { _processEvent_E_JOIN(msg); }
				else if (msg.optype == "MOVE")    { _processEvent_MOVE(msg);   }
				else if (msg.optype == "E_END")   { _processEvent_E_END(msg);  }
				else if (msg.optype == "LOGOUT")  { _processEvent_LOGOUT(msg); }
				else if (msg.optype == "I_MOVES") { _processEvent_I_MOVES(msg);}
				else if (msg.optype == "LEAVE")   { _processEvent_LEAVE(msg);  }
				else if (msg.optype == "DRAW")    { _processEvent_DRAW(msg);   }
				else if (msg.optype == "MSG")     { _processEvent_MSG(msg);    }
				else if (msg.optype == "UPDATE")  { _processEvent_UPDATE(msg); }
				else if (msg.optype == "RESET")   { _processEvent_RESET(msg);  }
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
				_playerWindow.visible = true;
				_playerWindow.includeInLayout = true;
				this.doViewTables(); // By default, get the List of Tables.
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

			if (   _menu.currentState == null || _menu.currentState == ""
				|| _menu.currentState == "viewTablesState" )
			{
				_mainWindow.removeAllChildren();
				tableListPanel.showCloseButton = false;
				_mainWindow.addChild(tableListPanel);
				_menu.currentState = "viewTablesState";
			}
			else
			{
				if ( _table && _table.isPlayerPlaying(_playerId) )
				{
					tableListPanel.joinActionEnabled = false;
				}
				PopUpManager.addPopUp(tableListPanel, _mainWindow, true /* modal */);
				PopUpManager.centerPopUp(tableListPanel);
			}
		}

		private function _processEvent_I_TABLE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const tableInfo:Object = event.parse_I_TABLE();

			if ( _table == null || _table.tableId != tableInfo.tid )
			{
				const initialTimer:Object = GameTimers.parse_times(tableInfo.initialtime);
				const settings:Object = {
						"gametime"  : initialTimer.gametime,
						"movetime"  : initialTimer.movetime,
						"extratime" : initialTimer.extratime,
						"rated"     : tableInfo.rated
					};
				_table = new Table(tableInfo.tid, _preferences, settings);
			}

			if ( _requestingTable )
			{
				_requestingTable = false;
			}

			_table.newTable(tableInfo);
		}

		private function _processEvent_E_JOIN(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const joinInfo:Object = event.parse_E_JOIN();

			if ( _table && _table.tableId == joinInfo.tid )
			{
				_table.joinTable( new PlayerInfo(joinInfo.pid, joinInfo.color, joinInfo.score) );
			}
	    }
		
		private function _processEvent_MOVE(event:Message) : void
		{
			if ( ! _table ) {
				return;
			}

			if ( event.getCode() == 0 )
			{
				const moveInfo:Object = event.parse_MOVE();
				if ( _table.tableId == moveInfo.tid )
				{
					_table.handleRemoteMove( new Position(moveInfo.fromRow, moveInfo.fromCol),
									  		 new Position(moveInfo.toRow, moveInfo.toCol) );
				}
			}
			else
			{
				// TODO: We must avoid handling wrong Move by fixing the way
				//       we validate Move to get it right in the first place
				//       before the Move is sent to the server.
				_table.processWrongMove(event.getContent());
			}
	    }

		private function _processEvent_I_MOVES(event:Message) : void
		{
			const moveList:Object = event.parse_I_MOVES();
			if (_table && _table.tableId == moveList.tid)
			{
				_table.playMoveList(moveList.moves);
			}
		}
	
		private function _processEvent_LEAVE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const leaveInfo:Object = event.parse_LEAVE();
			if ( _table && _table.tableId == leaveInfo.tid )
			{
				_table.leaveTable(leaveInfo.pid);
				if (    _playerId == leaveInfo.pid
				     && _requestingTable == false )
				{
					_table = null;
					_mainWindow.removeAllChildren();
					_menu.currentState = "viewTablesState";
					doViewTables();
				}
			}
		}
	
		private function _processEvent_E_END(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const endEvent:Object = event.parse_E_END();
			if ( _table && _table.tableId == endEvent.tid )
			{
				_table.stopGame(endEvent.reason, endEvent.winner);
			}
		}
	
		private function _processEvent_DRAW(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const drawEvent:Object = event.parse_DRAW();
			if ( _table && _table.tableId == drawEvent.tid )
			{
				_table.drawGame(drawEvent.pid);
			}
		}

		private function _processEvent_MSG(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const msgInfo:Object = event.parse_MSG();

			/* NOTE: There are 2 types of messages:
			 *  (1) For table messages, "both tid" and "pid" are present.
			 *  (2) For private messages, "tid" is missing.
			 */
			
			if ( msgInfo.tid == null )  // a private message?
			{
				// TODO: Need to handle private messages.
				trace("[" + msgInfo.pid + "]: sent a private message [" + msgInfo.msg + "]");
			}
			else if ( _table && _table.tableId == msgInfo.tid )
			{
				_table.displayChatMessage(msgInfo.pid, msgInfo.msg);
			}
		}

		private function _processEvent_UPDATE(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const updateInfo:Object = event.parse_UPDATE();
			if ( _table && _table.tableId == updateInfo.tid )
			{
				_table.updateTableSettings(updateInfo.itimes, updateInfo.rated);
			}
		}

		private function _processEvent_RESET(event:Message) : void
		{
			if ( event.getCode() != 0 ) { return; }

			const tableId:String = event.getContent();
			if ( _table && _table.tableId == tableId )
			{
				_table.resetTable();
			}
		}

		public function playMoveSound() : void
		{
			if (_preferences["sound"]) {
				_moveSound.play();
			}
		}
	}
}
