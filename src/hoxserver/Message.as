package hoxserver {
	public class Message {
		public var optype:String;
		public var params:Object;
		public function Message() {
			this.optype = "";
			this.params = null;
		}
	
		public function copy(arg:Message):void {
			this.optype = arg.optype;
			if (this.params === null) {
				this.params = {};
			}
			for (var key:String in arg.params) {
				if (key) {
					this.params[key] = arg.params[key];
				}
			}
		}
		
		public function setParam(key:String, value:String):void {
			this.params[key] = value;
		}
		
		public function getParam(key:String):String {
			return this.params[key];
		}
		
		public function getCode():String {
			return this.getParam('code');
		}
		public function getTableId():String {
			return this.getParam('tid');
		}
		public function getContent():String {
			return this.getParam('content');
		}
		
		public function createListRequest(pid:String, sid:String):void {
			this.optype = 'LIST';
			this.params = {
				pid: pid,
				sid: sid
			}
		}
		public function createJoinRequest(pid:String, sid:String, tid:String, color:String, joined:String):void {
			this.optype = "JOIN";
			this.params = {
				pid: pid,
				sid: sid,
				color: color,
				joined: joined,
				tid: tid
			}
		}
		public function createMoveRequest(pid, sid, time, move, tableId):void {
			this.optype = "MOVE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				time: time,
				move: move,
				status: "in_progress"
			};
		}
	
		public function createRegisterRequest(uname, passwd):void {
			this.optype = "REGISTER";
			this.params = {
				pid: uname,
				password: passwd
			};
		}
		
		public function createLoginRequest(uname, passwd, version):void {
			this.optype = "LOGIN";
			this.params = {
				pid: uname,
				password: passwd,
				version: version
			};
		}
		
		public function createPollRequest(pid, sid):void {
			this.optype = "POLL";
			this.params = {
				pid: pid,
				sid: sid
			};
		}
		
		public function createLogoutRequest(pid, sid):void {
			this.optype = "LOGOUT";
			this.params = {
				pid: pid,
				sid: sid
			};
		}
			
		public function createNewTableRequest(pid, sid, color):void {
			this.optype = "NEW";
			this.params = {
				pid: pid,
				sid: sid,
				itimes:  '1200/240/20',
				color: color
			};
		}
			
		public function createDrawRequest(pid, sid, tableId):void {
			this.optype = "DRAW";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				draw_response: '1'
			};
		}

		public function createChatRequest(pid, sid, tableId, msg):void {
			this.optype = "MSG";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				msg: msg
			};
		}

		public function createLeaveRequest(pid, sid, tableId):void {
			this.optype = "LEAVE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}
		
		public function createEndRequest(pid, sid, tableId):void {
			this.optype = "E_END";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}
		
		public function createResignRequest(pid, sid, tableId):void {
			this.optype = "RESIGN";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}
		
		public function createScoreRequest(pid, sid, tableId, score):void {
			this.optype = "E_SCORE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				score: score
			};
		}
		
		public function getMessage():String {
			var str:String = 'op=' + this.optype;
			var i:String;
			for (i in this.params) {
				if (i) {
					str += "&" + i + "=" + this.params[i];
				}
			}
			str += "\n";
			return str;
		}
		
		public function parseMessage(str) {
			var kvlist = str.split('&');
			for (var i = 0; i < kvlist.length; i++) {
				var kv = kvlist[i];
				var pair = kv.split('=');
				if (pair[0] == 'op') {
					this.optype = pair[1];
				}
				else {
					if (this.params === null) {
						this.params = {};
					}
					this.params[pair[0]] = pair[1];
				}
			}
		}
		
		public function parse(content) {
			this.parseMessage(content);
		}
		
		public function parseListResponse() {
			var entries = this.params.content.split('\n');
			var tables = [];
			for (var i = 0; i < entries.length; i++) {
				var entry = entries[i];
				if (entry !== "") {
				    trace("table entry: " + entries[i]);
					var table = new TableInfo();
					table.parse(entry);
					tables[table.getID()] = table;
				}
			}
			return tables;
		}
		
		public function parseTableResponse() {
			var table = new TableInfo();
			table.parse(this.params.content);
			return table;
		}
	}
}