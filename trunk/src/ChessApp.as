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

		public static const VERSION:String = "0.9.0.3";

		private var _menu:TopControlBar;
		private var _mainWindow:Container;
		private var _loginVersion:String;
		public var playerId:String;
		public var sessionId:String;
		public var login:Boolean;
		private var _session:Session;
		public var tableEntries:Object;
		public var currentTableId:String;
		public var tableObjects:Object;
		public var selectedTid:String;
		public var moveSound:Sound;
		public var firstLogin:Boolean;
		public var loginFailReason:String;
		public var preferences:Object;
		public var cookie:SharedObject;
		public var baseURI:String;

		public function ChessApp(menu:TopControlBar, window:Container) {
			_menu = menu;
			_mainWindow = window;
			baseURI = "http://www.playxiangqi.com/chesswhiz/";
			_loginVersion = "FLASHCHESS-" + VERSION;
			playerId = "";
			sessionId = "";
			login = false;
			_session = new Session();
			tableEntries = new Array();
			currentTableId = "";
			tableObjects = new Array();
			moveSound = new Sound();
			moveSound.load(new URLRequest(this.baseURI + "res/images/move.mp3"));
			firstLogin = true;
			loginFailReason = "";
			preferences = {};
			preferences["pieceskinindex"] = 1;
			preferences["boardcolor"] = 0x5b5d5b;
			preferences["linecolor"] = 0xa09e9e;
			preferences["sound"] = true;
			_loadCookie();
		}

		private function _loadCookie() : void {
			cookie = SharedObject.getLocal("flashchess");
			if (cookie && cookie.data && cookie.data.persist == 0xFFDDFF) {
				preferences["pieceskinindex"] = cookie.data.pieceskinindex;
				preferences["boardcolor"] = cookie.data.boardcolor;
				preferences["linecolor"] = cookie.data.linecolor;
				preferences["sound"] = cookie.data.sound;
			}
		}

		private function _saveCookie() : void {
			if (!cookie) {
				cookie = SharedObject.getLocal("flashchess");
			}
			if (cookie) {
				cookie.data.persist = 0xFFDDFF;
				cookie.data.pieceskinindex = preferences["pieceskinindex"];
				cookie.data.boardcolor = preferences["boardcolor"];
				cookie.data.linecolor = preferences["linecolor"];
				cookie.data.sound = preferences["sound"];
				var flushStatus:String = null;
	            try {
    	            flushStatus = cookie.flush(10000);
 	           } catch (error:Error) {
    	            trace("Error...Could not able to store the cookie\n");
        	    }
			}
		}

		public function startApp():void {			
			_session.createSocket();  // Create a connection to the server
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
			for (var key:String in this.tableObjects) {
				if (key && this.tableObjects[key]) {
					delete this.tableObjects[key];
				}
			}
			this.login = false;
			this.sessionId = "";
			this.playerId = "";
			clearView();
		}

		public function doGuestLogin() : void {
			var rand_no:Number = Math.ceil( 9999*Math.random() );
			var uname:String  = 'Guest#fl' + rand_no;
			Global.vars.app.doLogin(uname, '');
		}
		public function getPlayerID():String {
			return this.playerId;
		}
		public function getSessionID():String {
			return this.sessionId;
		}

		public function clearView() : void {
			_mainWindow.removeAllChildren();
		}

		private function _initLoginPanel() : void {
			var loginPanel:Login = new Login();
			_mainWindow.addChild(loginPanel);
		}

		public function initViewTablesPanel(tableList:Object) : void {
			clearView();
			var tableListPanel:TableList = new TableList();
			tableListPanel.setTableList(tableList);
			_mainWindow.addChild(tableListPanel);
			_menu.currentState = "viewTablesState";
		}

		public function doLogin(uname:String, passwd:String) : void {
			this.playerId = uname;
			_session.sendLoginRequest(uname, passwd, _loginVersion);
		}
		public function doLogout():void {
			_session.sendLogoutRequest(this.playerId, this.sessionId);
			stopApp();
			startApp();
		}
		public function doViewTables() : void {
			_session.sendTableListRequest(playerId, sessionId);
		}
		public function doNewTable() : void {
			_session.sendNewTableRequest(playerId, sessionId, "Red");
		}
		
		public function doJoinTable(tid:String) : void {
			_session.sendJoinRequest(playerId, sessionId, tid, "None", "0");
		}
		public function doCloseTable() : void {
			_session.sendLeaveRequest(playerId, sessionId, currentTableId);
		}
		public function doResignTable() : void {
			_session.sendResignRequest(playerId, sessionId, currentTableId);
		}
		public function doDrawTable() : void {
			_session.sendDrawRequest(playerId, sessionId, currentTableId);
		}
		public function doTableChat(msg:String) : void {
			_session.sendChatRequest(playerId, sessionId, currentTableId, msg);
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
				var tableObj:Table = this.getTable(this.currentTableId);
				if (tableObj) {
					var settings:Object = tableObj.getSettings();
					tableSettingsPanel.setCurrentSettings(settings);
				}
			}
		}
		public function updateTableSettings(settings:Object) : void
		{
			var tableObj:Table = this.getTable(this.currentTableId);
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
			if (pref != null) {
				var tableObj:Table = Global.vars.app.getTable(this.currentTableId);
				if (tableObj) {
					tableObj.updatePref(pref);
				}
				for (var key:String in pref) {
					this.preferences[key] = pref[key];
				}
				_saveCookie();
			}
		}
		public function handleServerEvent(event:DataEvent) : void {
			var eventData:String = event.data;
			// There can be multiple messages/events in the response body
			if (eventData === "Not yet authenticated\n") {
				//this.forceShutdown(response);
				//return;
			}

			var messages:Array = eventData.split("op");
			for (var i:int = 0; i < messages.length; i++) { 
				if (messages[i] != "") {
					trace("message: " + messages[i]);
					var line:Array = messages[i].split("\n\n");
					var msg:Message = new Message();
					trace("event: " + "op" + line[0]);
					msg.parse("op" + line[0]);
					if (msg.optype == "LOGIN") {
						this.processResponse_LOGIN(msg);
					}
	                else if (msg.optype == "LIST") {
	                    this.processResponse_LIST(msg);
	                }
	                else if (msg.optype == "I_TABLE") {
	                    this.processResponse_ITABLE(msg);
	                }
	                else if (msg.optype == "E_JOIN") {
	                    this.process_E_JOIN(msg);
	                }
	                else if (msg.optype == "MOVE") {
	                    this.process_MOVE(msg);
	                }
	                else if (msg.optype == "E_END") {
	                    this.processEvent_E_END(msg);
	                }
	                else if (msg.optype == "LOGOUT") {
	                    this.processResponse_LOGOUT(msg);
	                }
	                else if (msg.optype == "I_MOVES") {
	                    this.processEvent_I_MOVES(msg);
	                }
	                else if (msg.optype == "LEAVE") {
	                    this.processEvent_LEAVE(msg);
	                }
	                else if (msg.optype == "DRAW") {
	                    this.processEvent_DRAW(msg);
	                }
	                else if (msg.optype == "MSG") {
	                    this.processEvent_MSG(msg);
	                }
					else if (msg.optype == "UPDATE") {
						this.processEvent_UPDATE(msg);
					}
				}
			}
		}

		public function processResponse_LOGIN(response:Message) : void {
			var loginData:LoginInfo = null;
			if (response.optype === "LOGIN") {
				if (!this.login && response.getCode() === "0") {
					loginFailReason = "";
					loginData = new LoginInfo();
					loginData.parse(response.getContent());
					this.sessionId = loginData.getSessionID();
					this.playerId = loginData.getPlayerID();
					trace("playerid: " + this.playerId + " sessionid: " + this.sessionId);
					this.login = true;
					this.doViewTables();
				}
				else if (!this.login) {
					loginData = new LoginInfo();
					loginFailReason = response.getContent();
					_session.closeSocket();
					startApp();
				}
			}
		}
		public function processResponse_LOGOUT(response:Message) : void {
			if (!this.login && response.getCode() === "0") {
				if (response.getContent() == this.playerId) {
		        	this.stopApp();
				}
			}
        }

		public function processResponse_LIST(response:Message) : void {
			var tableList:Array = response.parseListResponse();
			if (this.tableEntries.length > 0) {
				this.tableEntries.splice(0, this.tableEntries.length);
			}
			this.tableEntries = tableList;
			this.initViewTablesPanel(this.tableEntries);
		}
		public function processResponse_ITABLE(response:Message) : void {
			var tableData:TableInfo = response.parseTableResponse();
			var tableId:String = tableData.getID();
			var tableObj:Table = this.getTable(tableId);
			if (tableObj == null) {
				tableObj = new Table(tableId, preferences);
				this.tableObjects[tableId] = tableObj;
			}
			this.currentTableId = tableObj.tableId;
			tableObj.newTable(tableData);
		}

		public function getTable(tableId:String) : Table 
		{
			trace("tableid: " + tableId);
			return this.tableObjects[tableId]; 
		}
		public function playGame(tableId:String, color:String) : void {
	        _session.sendJoinRequest(this.getPlayerID(), this.getSessionID(), tableId, color, '0');
    	}
		public function process_E_JOIN(event:Message) : void {
			if (event.getCode() === "0") {
				var joinData:JoinInfo = new JoinInfo();
				joinData.parse(event.getContent());
				var tableId:String = joinData.getTableID();
				var tableObj:Table = this.getTable(tableId);
				if (tableObj == null) {
					tableObj = new Table(tableId, preferences);
					this.tableObjects[tableId] = tableObj;
				}
				this.currentTableId = tableObj.tableId;
				tableObj.joinTable(joinData.getPlayer());
			}
	    }
		
		public function process_MOVE(event:Message) : void {
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
				tableObj = this.getTable(this.currentTableId);
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

		public function processEvent_I_MOVES(event:Message) : void {
			var moveList:MoveListInfo = new MoveListInfo();
			moveList.parse(event.getContent());
			var tableObj:Table = this.getTable( moveList.getTableID());
			if (tableObj) {
				tableObj.playMoveList(moveList);
			}
		}
	
		public function processEvent_LEAVE(event:Message) : void {
			var fields:Array = event.getContent().split(';');
			var tid:String = fields[0];
			var pid:String = fields[1];
			var tableObj:Table = this.getTable(tid);
			if (tableObj) {
				tableObj.leaveTable(pid);
				if (pid == this.playerId) {
					this.removeTable(tid);
					clearView();
					_menu.currentState = "viewTablesState";
					doViewTables();
				}
			}
		}
	
		public function processEvent_E_END(event:Message) : void {
			//op=E_END&code=0&content=2;black_win;Player resigned
			if (event.getCode() === "0") {
				var endEvent:EndEvent = new EndEvent(event.getContent());
				var tableObj:Table = this.getTable(endEvent.getTableID());
				if (tableObj) {
					tableObj.stopGame(endEvent.reason, endEvent.winner);
	
				}
			}
		}
	
		public function processEvent_DRAW(event:Message) : void {
			//op=E_END&code=0&content=2;black_win;Player resigned
			if (event.getCode() === "0") {
				var drawEvent:DrawEvent = new DrawEvent(event.getContent());
				var tableObj:Table = this.getTable(drawEvent.getTableID());
				if (tableObj) {
					tableObj.drawGame(drawEvent.getPlayerID());
				}
			}
		}
		public function processEvent_MSG(event:Message) : void {
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
			msg.params = {tid: tableId, pid: this.playerId, rated: (r) ? 1 : 0, itimes: times}
			_session.sendRequest(msg);
		}
		public function processEvent_UPDATE(event:Message) : void {
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
			//Util.createMessageBox(this, "Connection to server lost! Closing the application.", Global.vars.app.closeApp);
		}

		public function closeApp() : void {
			this.stopApp();
			this.startApp();
		}
		public function removeTable(tableId:String) : void { 
			var tableObj:Table = this.tableObjects[tableId];
			if (tableObj) {
				this.tableObjects[tableId] = null;
			}
			this.currentTableId = "";
		}
		public function playMoveSound() : void {
			if (this.preferences["sound"]) {
				moveSound.play();
			}
		}
		
	}
}
