package {
	import flash.events.DataEvent;
	import flash.media.Sound;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	
	import hoxserver.*;
	
	import mx.core.Container;
	
	import ui.Login;
	import ui.TableBoard;
	import ui.TableList;
	import ui.TablePreferences;
	import ui.TableSettings;
	import ui.TopControlBar;
	
	import views.*;

	public class ChessApp {

		public static const VERSION:String = "0.9.0.4";
		public static const BASE_URI:String = "http://www.playxiangqi.com/chesswhiz/";

		private var _menu:TopControlBar;
		private var _mainWindow:Container;
		private var _loginVersion:String = "FLASHCHESS-" + VERSION;
		private var _playerId:String = "";
		private var _sessionId:String = "";
		private var _bLoggedIn:Boolean = false;
		private var _session:Session = new Session();
		private var _currentTableId:String = "";
		private var _tableObjects:Object = {};
		private var _moveSound:Sound;
		private var _loginFailReason:String = "";
		public var preferences:Object = {};
		private var _cookie:SharedObject;

		public function ChessApp(menu:TopControlBar, window:Container) {
			_menu = menu;
			_mainWindow = window;
			_moveSound = new Sound( new URLRequest(BASE_URI + "res/images/move.mp3") );
			preferences["pieceskinindex"] = 1;
			preferences["boardcolor"] = 0x5b5d5b;
			preferences["linecolor"] = 0xa09e9e;
			preferences["sound"] = true;
			_loadCookie();
		}

		private function _loadCookie() : void {
			_cookie = SharedObject.getLocal("flashchess");
			if (_cookie && _cookie.data && _cookie.data.persist == 0xFFDDFF) {
				preferences["pieceskinindex"] = _cookie.data.pieceskinindex;
				preferences["boardcolor"] = _cookie.data.boardcolor;
				preferences["linecolor"] = _cookie.data.linecolor;
				preferences["sound"] = _cookie.data.sound;
			}
		}

		private function _saveCookie() : void {
			if (!_cookie) {
				_cookie = SharedObject.getLocal("flashchess");
			}
			if (_cookie) {
				_cookie.data.persist = 0xFFDDFF;
				_cookie.data.pieceskinindex = preferences["pieceskinindex"];
				_cookie.data.boardcolor = preferences["boardcolor"];
				_cookie.data.linecolor = preferences["linecolor"];
				_cookie.data.sound = preferences["sound"];
	            try {
    	            _cookie.flush(10000);
 	           } catch (error:Error) {
    	            trace("Error: Could not store the cookie.");
        	   }
			}
		}

		public function startApp():void {			
			_session.createSocket();
			_session.connect();
		}

		public function addBoardToWindow(board:TableBoard):void {
			_mainWindow.addChild(board);
		}

		public function processSocketConnectEvent() : void {
			_menu.currentState = "";
			_initLoginPanel();
		}

		public function stopApp() : void {
			_session.closeSocket();
			_tableObjects = {};
			_bLoggedIn = false;
			_sessionId = "";
			_playerId = "";
			clearView();
		}

		public function getPlayerID():String  { return _playerId; }
		public function getSessionID():String { return _sessionId; }

		public function clearView() : void {
			_mainWindow.removeAllChildren();
		}

		private function _initLoginPanel() : void {
			var loginPanel:Login = new Login();
			loginPanel.errorString = _loginFailReason;
			_mainWindow.addChild(loginPanel);
		}

		private function _initViewTablesPanel(tableList:Array) : void {
			clearView();
			var tableListPanel:TableList = new TableList();
			tableListPanel.setTableList(tableList);
			_mainWindow.addChild(tableListPanel);
			_menu.currentState = "viewTablesState";
		}

		public function doLogin(uname:String, passwd:String) : void {
			_playerId = uname;
			_session.sendLoginRequest(uname, passwd, _loginVersion);
		}

		public function doGuestLogin() : void {
			const rand_no:Number = Math.ceil( 9999*Math.random() );
			const uname:String  = 'Guest#fl' + rand_no;
			this.doLogin(uname, '');
		}

		public function doLogout() : void {
			_session.sendLogoutRequest(_playerId, _sessionId);
			stopApp();
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

		public function showTableMenu(showSettings:Boolean, showPref:Boolean) : void {
			if (showSettings) {
				_menu.currentState = "newTableState";
			} else {
				_menu.currentState = "observerState";
			}
		}

		public function showObserverMenu(color:String, tid:String) : void {
			_menu.tableId = tid;
			if (color == "Red") {
				_menu.currentState = "openRedState";
			} else if (color == "Black") {
				_menu.currentState = "openBlackState";
			} else {
				_menu.currentState = "observerState";
			}
		}

		public function showGameMenu() : void {
			_menu.currentState = "inGameState";
		}

		public function changeTableSettings() : void {
			if (!(_mainWindow.getChildByName("tableSettingsPanel"))) {
				var tableSettingsPanel:TableSettings = new TableSettings();
				tableSettingsPanel.name = "tableSettingsPanel";
				_mainWindow.addChild(tableSettingsPanel);
				var tableObj:Table = this.getTable(_currentTableId);
				if (tableObj) {
					var settings:Object = tableObj.getSettings();
					tableSettingsPanel.setCurrentSettings(settings);
				}
			}
		}

		public function updateTableSettings(settings:Object) : void
		{
			var tableObj:Table = this.getTable(_currentTableId);
			if (tableObj) {
				tableObj.updateSettings(settings);
			}
		}

		public function changeTablePref() : void {
			if (!(_mainWindow.getChildByName("tablePrefPanel"))) {
				var tablePrefPanel:TablePreferences = new TablePreferences();
				tablePrefPanel.name = "tablePrefPanel";
				_mainWindow.addChild(tablePrefPanel);
				tablePrefPanel.setCurrentPreferences(this.preferences);
			}
		}

		public function updateTablePreferences(pref:Object) : void {
			var tableObj:Table = this.getTable(_currentTableId);
			if (tableObj) {
				tableObj.updatePref(pref);
			}
			for (var key:String in pref) {
				this.preferences[key] = pref[key];
			}
			_saveCookie();
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

				trace("message: " + messages[i]);
				const line:Array = messages[i].split("\n\n");
				const msg:Message = new Message();
				trace("event: op" + line[0]);
				msg.parse("op" + line[0]);

				if      (msg.optype == "LOGIN")   { _processResponse_LOGIN(msg); }
                else if (msg.optype == "LIST")    { _processResponse_LIST(msg); }
                else if (msg.optype == "I_TABLE") { _processResponse_ITABLE(msg); }
                else if (msg.optype == "E_JOIN")  { _process_E_JOIN(msg); }
                else if (msg.optype == "MOVE")    { _process_MOVE(msg); }
                else if (msg.optype == "E_END")   { _processEvent_E_END(msg);    }
                else if (msg.optype == "LOGOUT")  { _processResponse_LOGOUT(msg); }
                else if (msg.optype == "I_MOVES") { _processEvent_I_MOVES(msg); }
                else if (msg.optype == "LEAVE")   { _processEvent_LEAVE(msg); }
                else if (msg.optype == "DRAW")    { _processEvent_DRAW(msg); }
                else if (msg.optype == "MSG")     { _processEvent_MSG(msg); }
				else if (msg.optype == "UPDATE")  { _processEvent_UPDATE(msg); }
			}
		}

		private function _processResponse_LOGIN(response:Message) : void {
			if (_bLoggedIn) return;

			var loginData:LoginInfo = new LoginInfo();
			if (response.getCode() === "0") {
				_loginFailReason = "";
				loginData.parse(response.getContent());
				_sessionId = loginData.getSessionID();
				_playerId = loginData.getPlayerID();
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
		        	this.stopApp();
				}
			}
        }

		private function _processResponse_LIST(response:Message) : void {
			const tableEntries:Array = response.parseListResponse();
			_initViewTablesPanel(tableEntries);
		}

		private function _processResponse_ITABLE(response:Message) : void {
			var tableData:TableInfo = response.parseTableResponse();
			var tableId:String = tableData.getID();
			var tableObj:Table = this.getTable(tableId);
			if (tableObj == null) {
				tableObj = new Table(tableId, preferences);
				_tableObjects[tableId] = tableObj;
			}
			_currentTableId = tableObj.tableId;
			tableObj.newTable(tableData);
		}

		public function getTable(tableId:String) : Table 
		{
			return _tableObjects[tableId]; 
		}

		public function playGame(tableId:String, color:String) : void {
	        _session.sendJoinRequest(this.getPlayerID(), this.getSessionID(), tableId, color, '0');
    	}

		private function _process_E_JOIN(event:Message) : void {
			if (event.getCode() === "0") {
				var joinData:JoinInfo = new JoinInfo();
				joinData.parse(event.getContent());
				var tableId:String = joinData.getTableID();
				var tableObj:Table = this.getTable(tableId);
				if (tableObj == null) {
					tableObj = new Table(tableId, preferences);
					_tableObjects[tableId] = tableObj;
				}
				_currentTableId = tableObj.tableId;
				tableObj.joinTable(joinData.getPlayer());
			}
	    }
		
		private function _process_MOVE(event:Message) : void {
			var tableObj:Table = null;
			if (event.getCode() === "0") {
				var moveData:MoveInfo = new MoveInfo();
				moveData.parse(event.getContent());
				tableObj = this.getTable( moveData.getTableID());
				if (tableObj) {
					tableObj.movePiece(moveData);
				}
			}
			else {
				tableObj = this.getTable(_currentTableId);
				if (tableObj) {
					tableObj.processWrongMove(event.getContent());
				}
			}
	    }

		public function sendMoveRequest(player:PlayerInfo, piece:Piece, curPos:Position, newPos:Position, tid:String) : void {
			_session.sendMoveRequest(this.getPlayerID(), this.getSessionID(), curPos, newPos, '1500', tid);
		}
		
		public function resignGame(tableId:String) : void {
			_session.sendResignRequest(this.getPlayerID(), this.getSessionID(), tableId);
		}
	
		public function drawGame(tableId:String) : void {
			_session.sendDrawRequest(this.getPlayerID(), this.getSessionID(), tableId);
		}

		private function _processEvent_I_MOVES(event:Message) : void {
			var moveList:MoveListInfo = new MoveListInfo();
			moveList.parse(event.getContent());
			var tableObj:Table = this.getTable( moveList.getTableID());
			if (tableObj) {
				tableObj.playMoveList(moveList);
			}
		}
	
		private function _processEvent_LEAVE(event:Message) : void {
			var fields:Array = event.getContent().split(';');
			var tid:String = fields[0];
			var pid:String = fields[1];
			var tableObj:Table = this.getTable(tid);
			if (tableObj) {
				tableObj.leaveTable(pid);
				if (pid == _playerId) {
					this.removeTable(tid);
					clearView();
					_menu.currentState = "viewTablesState";
					doViewTables();
				}
			}
		}
	
		private function _processEvent_E_END(event:Message) : void {
			//op=E_END&code=0&content=2;black_win;Player resigned
			if (event.getCode() === "0") {
				var endEvent:EndEvent = new EndEvent(event.getContent());
				var tableObj:Table = this.getTable(endEvent.getTableID());
				if (tableObj) {
					tableObj.stopGame(endEvent.reason, endEvent.winner);
	
				}
			}
		}
	
		private function _processEvent_DRAW(event:Message) : void {
			//op=E_END&code=0&content=2;black_win;Player resigned
			if (event.getCode() === "0") {
				var drawEvent:DrawEvent = new DrawEvent(event.getContent());
				var tableObj:Table = this.getTable(drawEvent.getTableID());
				if (tableObj) {
					tableObj.drawGame(drawEvent.getPlayerID());
				}
			}
		}

		private function _processEvent_MSG(event:Message) : void {
			// op=MSG&code=0&tid=4&content=Guest#hox1454;hello
			var tableId:String = event.getTableId();
			var fields:Array = event.getContent().split(';');
			var pid:String = fields[0];
			var chatMsg:String = fields[1];
			if (event.getCode() === "0") {
				var tableObj:Table = this.getTable(tableId);
				if (tableObj) {
					tableObj.displayChatMessage(pid, chatMsg);
				}
			}
		}
		
		public function sendUpdateRequest(tableId:String, times:String, r:Boolean) : void {
			var msg:Message = new Message();
			msg.optype = "UPDATE";
			msg.params = {tid: tableId, pid: _playerId, rated: (r) ? 1 : 0, itimes: times}
			_session.sendRequest(msg);
		}

		private function _processEvent_UPDATE(event:Message) : void {
			// op=UPDATE&code=0&content=1;Guest#hox8233;1;600/240/5
			var fields:Array = event.getContent().split(';');
			var tableId:String = fields[0];
			var pid:String = fields[1];
			var times:String = fields[3];
			if (event.getCode() === "0") {
				var tableObj:Table = this.getTable(tableId);
				if (tableObj) {
					tableObj.updateGameTimes(pid, times);
				}
			}			
		}

		public function processSocketCloseEvent() : void {
			trace("Connection to server lost! Closing the application.");
		}

		public function removeTable(tableId:String) : void { 
			var tableObj:Table = _tableObjects[tableId];
			if (tableObj) {
				_tableObjects[tableId] = null;
			}
			_currentTableId = "";
		}

		public function playMoveSound() : void {
			if (this.preferences["sound"]) {
				_moveSound.play();
			}
		}
		
	}
}
