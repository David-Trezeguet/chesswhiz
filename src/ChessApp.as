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
		private var _preferences:Object = {};
		private var _menu:TopControlBar;
		private var _mainWindow:Container;
		private var _playerId:String = "";
		private var _sessionId:String = "";
		private var _bLoggedIn:Boolean = false;
		private var _session:Session = new Session();
		private var _currentTableId:String = "";
		private var _tableObjects:Object = {};
		private var _moveSound:Sound;
		private var _loginFailReason:String = "";
		private var _cookie:SharedObject;

		public function ChessApp(menu:TopControlBar, window:Container)
		{
			_menu = menu;
			_mainWindow = window;
			_moveSound = new Global.moveSoundClass() as Sound;
			_preferences["pieceskinindex"] = 1;
			_preferences["boardcolor"] = 0x5b5d5b;
			_preferences["linecolor"] = 0xa09e9e;
			_preferences["sound"] = true;
			_loadCookie();
		}

		private function _loadCookie() : void
		{
			try {
				_cookie = SharedObject.getLocal("flashchess");
				if (_cookie.data.persist == 0xFFDDFF) {
					_preferences["pieceskinindex"] = _cookie.data.pieceskinindex;
					_preferences["boardcolor"] = _cookie.data.boardcolor;
					_preferences["linecolor"] = _cookie.data.linecolor;
					_preferences["sound"] = _cookie.data.sound;
				}
			}
			catch (error:Error) {
				trace("Error: Failed to get the shared object: " + error);
			} 
		}

		private function _saveCookie() : void
		{
			if (!_cookie) {
				_cookie = SharedObject.getLocal("flashchess");
			}

			if (_cookie) {
				_cookie.data.persist = 0xFFDDFF;
				_cookie.data.pieceskinindex = _preferences["pieceskinindex"];
				_cookie.data.boardcolor = _preferences["boardcolor"];
				_cookie.data.linecolor = _preferences["linecolor"];
				_cookie.data.sound = _preferences["sound"];

				var flushStatus:String = null;
	            try {
					flushStatus = _cookie.flush( 10*1024 /* minDiskSpace */ );
				}
				catch (error:Error) {
					trace("Error: Failed to flush the shared object: " + error);
				}

				if (flushStatus != null)
				{
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

		public function startApp() : void
		{
			_session.openSocket();
		}

		public function addBoardToWindow(board:TableBoard) : void
		{
			_mainWindow.removeAllChildren();
			_mainWindow.addChild(board);
		}

		public function processSocketConnectEvent() : void
		{
			trace("Successfully connected to server");
			_menu.currentState = "";

			var loginPanel:LoginPanel = new LoginPanel();
			loginPanel.errorString = _loginFailReason;
			_mainWindow.addChild(loginPanel);
		}

		private function _stopApp() : void
		{
			_session.closeSocket();
			_tableObjects = {};
			_bLoggedIn = false;
			_sessionId = "";
			_playerId = "";
			_mainWindow.removeAllChildren();
		}

		public function getPlayerID():String  { return _playerId; }

		private function _initViewTablesPanel(tables:Object) : void
		{
			_mainWindow.removeAllChildren();
			var tableListPanel:TableList = new TableList();
			tableListPanel.setTableList(tables);
			_mainWindow.addChild(tableListPanel);
			_menu.currentState = "viewTablesState";
		}

		public function doLogin(uname:String, passwd:String) : void {
			_playerId = uname;
			_session.sendLoginRequest(uname, passwd, Global.LOGIN_VERSION);
		}

		public function doGuestLogin() : void {
			const rand_no:Number = Math.ceil( 9999*Math.random() );
			const uname:String  = 'Guest#fl' + rand_no;
			this.doLogin(uname, '');
		}

		public function doLogout() : void {
			_session.sendLogoutRequest(_playerId, _sessionId);
			_stopApp();
			startApp();
		}

		public function doViewTables() : void {
			_session.sendTableListRequest(_playerId, _sessionId);
		}

		public function doNewTable() : void {
			_session.sendNewTableRequest(_playerId, _sessionId, "Red");
		}
		
		public function doJoinTable(tid:String) : void {
			_session.sendJoinRequest(_playerId, _sessionId, tid, "None", "0");
		}

		public function doCloseTable() : void {
			_session.sendLeaveRequest(_playerId, _sessionId, _currentTableId);
		}

		public function doResignTable() : void {
			_session.sendResignRequest(_playerId, _sessionId, _currentTableId);
		}

		public function doDrawTable() : void {
			_session.sendDrawRequest(_playerId, _sessionId, _currentTableId);
		}

		public function doTableChat(msg:String) : void {
			_session.sendChatRequest(_playerId, _sessionId, _currentTableId, msg);
		}

		public function showTableMenu(showSettings:Boolean, showPref:Boolean) : void
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
			
			var tableObj:Table = _getTable(_currentTableId);
			if (tableObj) {
				var settings:Object = tableObj.getSettings();
				settingsPanel.setCurrentSettings(settings);
			}
		}

		public function updateTableSettings(settings:Object) : void
		{
			var tableObj:Table = _getTable(_currentTableId);
			if (tableObj) {
				tableObj.updateSettings(settings);
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

				var table:Table = _getTable(_currentTableId);
				if (table) {
					table.updatePreferences(pref);
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
			//trace("Received data: " + event.data);
			const eventData:String = event.data;
			const messages:Array = eventData.split("op");

			for (var i:int = 0; i < messages.length; i++) {
				if (messages[i] == "") continue;

				//trace("message: " + messages[i]);
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

		private function _processResponse_LOGIN(response:Message) : void {
			if (_bLoggedIn) return;

			if (response.getCode() === "0") {
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
				startApp();
			}
		}

		private function _processResponse_LOGOUT(response:Message) : void {
			if (!_bLoggedIn && response.getCode() === "0") {
				if (response.getContent() == _playerId) {
		        	_stopApp();
				}
			}
        }

		private function _processResponse_LIST(response:Message) : void {
			const tables:Object = response.parseListResponse();
			_initViewTablesPanel(tables);
		}

		private function _processResponse_ITABLE(response:Message) : void {
			var tableData:TableInfo = response.parseTableResponse();
			var tableId:String = tableData.getID();
			var tableObj:Table = _getTable(tableId);
			if (tableObj == null) {
				tableObj = new Table(tableId, _preferences);
				_tableObjects[tableId] = tableObj;
			}
			_currentTableId = tableObj.tableId;
			tableObj.newTable(tableData);
		}

		private function _getTable(tableId:String) : Table 
		{
			return _tableObjects[tableId]; 
		}

		public function playGame(tableId:String, color:String) : void {
	        _session.sendJoinRequest(this.getPlayerID(), _sessionId, tableId, color, '0');
    	}

		private function _process_E_JOIN(event:Message) : void {
			if (event.getCode() === "0") {
				var joinData:JoinInfo = new JoinInfo();
				joinData.parse(event.getContent());
				var tableId:String = joinData.getTableID();
				var tableObj:Table = _getTable(tableId);
				if (tableObj == null) {
					tableObj = new Table(tableId, _preferences);
					_tableObjects[tableId] = tableObj;
				}
				_currentTableId = tableObj.tableId;
				tableObj.joinTable(joinData.getPlayer());
			}
	    }
		
		private function _process_MOVE(event:Message) : void {
			var tableObj:Table = null;
			if (event.getCode() === "0") {
				const moveInfo:MoveInfo = new MoveInfo( event.getContent() );
				tableObj = _getTable( moveInfo.tid );
				if (tableObj) {
					const curPos:Position = new Position( moveInfo.fromRow, moveInfo.fromCol );
					const newPos:Position = new Position( moveInfo.toRow, moveInfo.toCol );
					tableObj.movePiece(curPos, newPos);
				}
			}
			else {
				tableObj = _getTable(_currentTableId);
				if (tableObj) {
					tableObj.processWrongMove(event.getContent());
				}
			}
	    }

		public function sendMoveRequest(player:PlayerInfo, piece:Piece, curPos:Position, newPos:Position, tid:String) : void {
			_session.sendMoveRequest(this.getPlayerID(), _sessionId, curPos, newPos, '1500', tid);
		}
		
		public function resignGame(tableId:String) : void {
			_session.sendResignRequest(this.getPlayerID(), _sessionId, tableId);
		}
	
		public function drawGame(tableId:String) : void {
			_session.sendDrawRequest(this.getPlayerID(), _sessionId, tableId);
		}

		public function doUpdateTableSettings(tableId:String, times:String, bRated:Boolean) : void {
			_session.sendUpdateTableRequest(_playerId, tableId, times, bRated)
		}

		private function _processEvent_I_MOVES(event:Message) : void {
			var moveList:MoveListInfo = new MoveListInfo();
			moveList.parse(event.getContent());
			var tableObj:Table = _getTable( moveList.getTableID());
			if (tableObj) {
				tableObj.playMoveList(moveList);
			}
		}
	
		private function _processEvent_LEAVE(event:Message) : void {
			var fields:Array = event.getContent().split(';');
			var tid:String = fields[0];
			var pid:String = fields[1];
			var tableObj:Table = _getTable(tid);
			if (tableObj) {
				tableObj.leaveTable(pid);
				if (pid == _playerId) {
					_removeTable(tid);
					_mainWindow.removeAllChildren();
					_menu.currentState = "viewTablesState";
					doViewTables();
				}
			}
		}
	
		private function _processEvent_E_END(event:Message) : void {
			if (event.getCode() === "0") {
				var endEvent:EndEvent = new EndEvent(event.getContent());
				var tableObj:Table = _getTable(endEvent.getTableID());
				if (tableObj) {
					tableObj.stopGame(endEvent.reason, endEvent.winner);
	
				}
			}
		}
	
		private function _processEvent_DRAW(event:Message) : void {
			if (event.getCode() === "0") {
				var drawEvent:DrawEvent = new DrawEvent(event.getContent());
				var tableObj:Table = _getTable(drawEvent.getTableID());
				if (tableObj) {
					tableObj.drawGame(drawEvent.getPlayerID());
				}
			}
		}

		private function _processEvent_MSG(event:Message) : void {
			var tableId:String = event.getTableId();
			var fields:Array = event.getContent().split(';');
			var pid:String = fields[0];
			var chatMsg:String = fields[1];
			if (event.getCode() === "0") {
				var tableObj:Table = _getTable(tableId);
				if (tableObj) {
					tableObj.displayChatMessage(pid, chatMsg);
				}
			}
		}

		private function _processEvent_UPDATE(event:Message) : void {
			var fields:Array = event.getContent().split(';');
			var tableId:String = fields[0];
			var pid:String = fields[1];
			var times:String = fields[3];
			if (event.getCode() === "0") {
				var tableObj:Table = _getTable(tableId);
				if (tableObj) {
					tableObj.updateGameTimes(pid, times);
				}
			}			
		}

		public function processSocketCloseEvent() : void
		{
			trace("Connection to server lost.");
		}

		private function _removeTable(tableId:String) : void { 
			var tableObj:Table = _tableObjects[tableId];
			if (tableObj) {
				_tableObjects[tableId] = null;
			}
			_currentTableId = "";
		}

		public function playMoveSound() : void {
			if (_preferences["sound"]) {
				_moveSound.play();
			}
		}
		
	}
}
