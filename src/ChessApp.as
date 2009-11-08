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
	import ui.TableBoard;
	import ui.TableList;
	import ui.TablePreferences;
	import ui.TableSettings;
	import ui.TopControlBar;

	public class ChessApp
	{
		private var _preferences:Object;
		private var _menu:TopControlBar;
		private var _mainWindow:Container;
		private var _playerId:String = "";
		private var _sessionId:String = "";
		private var _bLoggedIn:Boolean = false;
		private var _session:Session = new Session();

		private var _table:Table = null;  // THE table.

		private var _moveSound:Sound;
		private var _loginFailReason:String = "";
		private var _cookie:SharedObject;

		public function ChessApp(menu:TopControlBar, window:Container)
		{
			_menu       = menu;
			_mainWindow = window;

			_moveSound = new Global.moveSoundClass() as Sound;
			_preferences = {
					"pieceskinindex" : 1,
					"boardcolor"     : 0x5b5d5b,
					"linecolor"      : 0xa09e9e,
					"sound"          : true
				};
			_loadCookie();

			_startApp();
		}

		private function _loadCookie() : void
		{
			try {
				_cookie = SharedObject.getLocal("flashchess");
				if (_cookie.data.persist == 0xFFDDFF) {
					_preferences["pieceskinindex"] = _cookie.data.pieceskinindex;
					_preferences["boardcolor"]     = _cookie.data.boardcolor;
					_preferences["linecolor"]      = _cookie.data.linecolor;
					_preferences["sound"]          = _cookie.data.sound;
				}
			}
			catch (error:Error) {
				trace("Error: Failed to get the shared object: " + error);
			} 
		}

		private function _saveCookie() : void
		{
			_cookie.data.persist        = 0xFFDDFF; // "Present" flag.
			_cookie.data.pieceskinindex = _preferences["pieceskinindex"];
			_cookie.data.boardcolor     = _preferences["boardcolor"];
			_cookie.data.linecolor      = _preferences["linecolor"];
			_cookie.data.sound          = _preferences["sound"];

			var flushStatus:String = null;
            try {
				flushStatus = _cookie.flush( 10*1024 /* minDiskSpace */ );
			}
			catch (error:Error) {
				trace("Error: Failed to flush the shared object: " + error);
			}

			switch (flushStatus) {
				case SharedObjectFlushStatus.PENDING:
					trace("Flush-Status: Requesting permission to save object...");
					_cookie.addEventListener(NetStatusEvent.NET_STATUS, _onFlushStatus);
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

            _cookie.removeEventListener(NetStatusEvent.NET_STATUS, _onFlushStatus);
        }

		private function _startApp() : void
		{
			_session.openSocket();
		}

		private function _stopApp() : void
		{
			_session.closeSocket();
			_table     = null;
			_bLoggedIn = false;
			_sessionId = "";
			_playerId  = "";
			_mainWindow.removeAllChildren();
		}

		public function addBoardToWindow(board:TableBoard) : void
		{
			_mainWindow.removeAllChildren();
			_mainWindow.addChild(board);
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

		public function getPlayerID():String  { return _playerId; }

		public function doLogin(uname:String, passwd:String = "") : void
		{
			_playerId = uname;
			_session.sendLoginRequest(uname, passwd, Global.LOGIN_VERSION);
		}

		public function doGuestLogin() : void
		{
			const randNumber:Number = Math.ceil( 9999*Math.random() );
			this.doLogin( "Guest#Fl" + randNumber );
		}

		public function doLogout() : void
		{
			_session.sendLogoutRequest(_playerId, _sessionId);
			_stopApp();
			_startApp();
		}

		public function doViewTables() : void {
			_session.sendTableListRequest(_playerId, _sessionId);
		}

		public function doNewTable() : void {
			_session.sendNewTableRequest(_playerId, _sessionId, "Red");
		}
		
		public function doJoinTable(tableId:String, color:String = "None") : void {
			_session.sendJoinRequest(_playerId, _sessionId, tableId, color, "0");
		}

		public function doCloseTable() : void
		{
			if ( _table ) {
				_session.sendLeaveRequest(_playerId, _sessionId, _table.tableId);
			}
		}

		public function doResignTable() : void
		{
			if ( _table ) {
				_session.sendResignRequest(_playerId, _sessionId, _table.tableId);
			}
		}

		public function doDrawTable() : void
		{
			if ( _table ) {
				_session.sendDrawRequest(_playerId, _sessionId, _table.tableId);
			}
		}

		public function doTableChat(msg:String) : void
		{
			if ( _table ) {
				_session.sendChatRequest(_playerId, _sessionId, _table.tableId, msg);
			}
		}

		public function showTableMenu(showSettings:Boolean) : void
		{
			if (showSettings) { _menu.currentState = "newTableState"; }
			else              { _menu.currentState = "observerState"; }
		}

		public function showObserverMenu(color:String, tid:String) : void
		{
			_menu.tableId = tid;
			if      (color == "Red")   { _menu.currentState = "openRedState";   }
			else if (color == "Black") { _menu.currentState = "openBlackState"; }
			else                       { _menu.currentState = "observerState";  }
		}

		public function showGameMenu() : void
		{
			_menu.currentState = "inGameState";
		}

		public function changeTableSettings() : void
		{
			var settingsPanel:TableSettings = new TableSettings();
			PopUpManager.addPopUp(settingsPanel, _mainWindow, true /* modal */);
			PopUpManager.centerPopUp(settingsPanel);
			
			if (_table) {
				var settings:Object = _table.getSettings();
				settingsPanel.setCurrentSettings(settings);
			}
		}

		public function updateTableSettings(settings:Object) : void
		{
			if (_table) {
				_table.updateSettings(settings);
			}
		}

		public function changeAppPreferences() : void
		{
			var preferencesPanel:TablePreferences = new TablePreferences();
			PopUpManager.addPopUp(preferencesPanel, _mainWindow, true /* modal */);
			PopUpManager.centerPopUp(preferencesPanel);
			preferencesPanel.preferences = ObjectUtil.copy(_preferences);
			preferencesPanel.applyCurrentPreferences();
			preferencesPanel.addEventListener("newPreferences", newPreferencesEventHandler);
		}

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
				_saveCookie();
			}
		}

		/**
		 * @note There can be multiple messages/events in the response body
		 */
		public function handleServerEvent(event:DataEvent) : void
		{
			const eventData:String = event.data;
			const messages:Array = eventData.split("op");

			for (var i:int = 0; i < messages.length; i++) {
				if (messages[i] == "") continue;

				const line:Array = messages[i].split("\n\n");
				const msg:Message = new Message();
				trace("event: op" + line[0]);
				msg.parse("op" + line[0]);

				if      (msg.optype == "LOGIN")   { _processResponse_LOGIN(msg);  }
                else if (msg.optype == "LIST")    { _processResponse_LIST(msg);   }
                else if (msg.optype == "I_TABLE") { _processResponse_ITABLE(msg); }
                else if (msg.optype == "E_JOIN")  { _process_E_JOIN(msg);         }
                else if (msg.optype == "MOVE")    { _process_MOVE(msg);           }
                else if (msg.optype == "E_END")   { _processEvent_E_END(msg);     }
                else if (msg.optype == "LOGOUT")  { _processResponse_LOGOUT(msg); }
                else if (msg.optype == "I_MOVES") { _processEvent_I_MOVES(msg);   }
                else if (msg.optype == "LEAVE")   { _processEvent_LEAVE(msg);     }
                else if (msg.optype == "DRAW")    { _processEvent_DRAW(msg);      }
                else if (msg.optype == "MSG")     { _processEvent_MSG(msg);       }
				else if (msg.optype == "UPDATE")  { _processEvent_UPDATE(msg);    }
			}
		}

		private function _processResponse_LOGIN(response:Message) : void
		{
			if (_bLoggedIn) return;

			if (response.getCode() == "0") {
				_loginFailReason = "";
				var loginData:LoginInfo = new LoginInfo( response.getContent() );
				_sessionId = loginData.sid;
				_playerId = loginData.pid;
				trace("playerid: " + _playerId + " sessionid: " + _sessionId);
				_bLoggedIn = true;
				this.doViewTables();
			}
			else {
				_loginFailReason = response.getContent();
				_session.closeSocket();
				_startApp();
			}
		}

		private function _processResponse_LOGOUT(response:Message) : void
		{
			if (    _bLoggedIn
				 && response.getCode() == "0"
				 && response.getContent() == _playerId )
			{
				_stopApp();
			}
        }

		private function _processResponse_LIST(response:Message) : void
		{
			const tables:Object = response.parseListResponse();
			
			// Display the Tables view.
			_mainWindow.removeAllChildren();
			var tableListPanel:TableList = new TableList();
			tableListPanel.setTableList(tables);
			_mainWindow.addChild(tableListPanel);
			_menu.currentState = "viewTablesState";
		}

		private function _processResponse_ITABLE(response:Message) : void
		{
			var tableInfo:TableInfo = new TableInfo( response.getContent() );
			const tableId:String = tableInfo.tid;

			if ( _table == null || _table.tableId != tableId )
			{
				_table = new Table(tableId, _preferences);
			}

			// NOTE: Update my table with the *new* info coming from the server.
			_table.newTable(tableInfo);
		}

		private function _process_E_JOIN(event:Message) : void
		{
			if ( event.getCode() != "0" ) {
				return;
			}

			const joinInfo:JoinInfo = new JoinInfo( event.getContent() );
			const tableId:String = joinInfo.tid;

			if ( _table == null || _table.tableId != tableId )
			{
				_table = new Table(tableId, _preferences);
			}
			
			_table.joinTable( new PlayerInfo(joinInfo.pid, joinInfo.color, joinInfo.score) );
	    }
		
		private function _process_MOVE(event:Message) : void
		{
			if ( ! _table ) {
				return;
			}

			if ( event.getCode() == "0" )
			{
				const moveInfo:MoveInfo = new MoveInfo( event.getContent() );
				if ( _table.tableId == moveInfo.tid )
				{
					_table.movePiece( new Position(moveInfo.fromRow, moveInfo.fromCol),
									  new Position(moveInfo.toRow, moveInfo.toCol) );
				}
			}
			else
			{
				_table.processWrongMove(event.getContent());
			}
	    }

		public function sendMoveRequest(player:PlayerInfo, piece:Piece, curPos:Position, newPos:Position, tid:String) : void
		{
			_session.sendMoveRequest(_playerId, _sessionId, curPos, newPos, '1500', tid);
		}
		
		public function resignGame(tableId:String) : void
		{
			_session.sendResignRequest(_playerId, _sessionId, tableId);
		}
	
		public function drawGame(tableId:String) : void
		{
			_session.sendDrawRequest(_playerId, _sessionId, tableId);
		}

		public function doUpdateTableSettings(tableId:String, times:String, bRated:Boolean) : void
		{
			_session.sendUpdateTableRequest(_playerId, tableId, times, bRated)
		}

		private function _processEvent_I_MOVES(event:Message) : void
		{
			const moveList:MoveListInfo = new MoveListInfo( event.getContent() );
			if (_table && _table.tableId == moveList.tid)
			{
				_table.playMoveList(moveList.moves);
			}
		}
	
		private function _processEvent_LEAVE(event:Message) : void
		{
			var fields:Array = event.getContent().split(';');
			const tid:String = fields[0];
			const pid:String = fields[1];

			if ( _table && _table.tableId == tid )
			{
				_table.leaveTable(pid);
				if (pid == _playerId)
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
			if ( event.getCode() != "0" ) {
				return;
			}

			const endEvent:EndEvent = new EndEvent( event.getContent() );
			if ( _table && _table.tableId == endEvent.tid )
			{
				_table.stopGame(endEvent.reason, endEvent.winner);
			}
		}
	
		private function _processEvent_DRAW(event:Message) : void
		{
			if ( event.getCode() != "0" ) {
				return;
			}

			const drawEvent:DrawEvent = new DrawEvent(event.getContent());
			if ( _table && _table.tableId == drawEvent.tid )
			{
				_table.drawGame(drawEvent.pid);
			}
		}

		private function _processEvent_MSG(event:Message) : void
		{
			if ( event.getCode() != "0" ) {
				return;
			}

			const tableId:String = event.getTableId();
			var fields:Array = event.getContent().split(';');
			const pid:String = fields[0];
			const chatMsg:String = fields[1];
			if ( _table && _table.tableId == tableId )
			{
				_table.displayChatMessage(pid, chatMsg);
			}
		}

		private function _processEvent_UPDATE(event:Message) : void
		{
			if ( event.getCode() != "0" ) {
				return;
			}

			const fields:Array = event.getContent().split(';');
			const tableId:String = fields[0];
			const pid:String = fields[1];
			const times:String = fields[3];
			if ( _table && _table.tableId == tableId )
			{
				_table.updateGameTimes(pid, times);
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
