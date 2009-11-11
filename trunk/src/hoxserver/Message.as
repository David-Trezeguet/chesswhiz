package hoxserver
{
	public class Message
	{
		public var optype:String = "";
		public var params:Object = {};

		public function Message(content:String = "")
		{
			if ( content != "" )
			{
				var kvlist:Array = content.split('&');
				for (var i:int = 0; i < kvlist.length; i++)
				{
					var pair:Array = kvlist[i].split('=');
					if (pair[0] == "op") { this.optype = pair[1]; }
					else                 { this.params[pair[0]] = pair[1]; }
				}
			}
		}

		public function getCode():int { return parseInt(this.params["code"]); }
		public function getTableId():String { return this.params["tid"];     }
		public function getContent():String { return this.params["content"]; }

		public function createListRequest(pid:String, sid:String):void {
			this.optype = "LIST";
			this.params = {
				pid: pid,
				sid: sid
			}
		}

		public function createJoinRequest(pid:String, sid:String, tid:String, color:String):void {
			this.optype = "JOIN";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tid,
				color: color
			}
		}

		public function createMoveRequest(pid:String, sid:String, move:String, tableId:String):void {
			this.optype = "MOVE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				move: move
			};
		}
		
		public function createLoginRequest(pid:String, passwd:String, version:String):void {
			this.optype = "LOGIN";
			this.params = {
				pid: pid,
				password: passwd,
				version: version
			};
		}
		
		public function createLogoutRequest(pid:String, sid:String):void {
			this.optype = "LOGOUT";
			this.params = {
				pid: pid,
				sid: sid
			};
		}
			
		public function createNewTableRequest(pid:String, sid:String, color:String, itimes:String):void {
			this.optype = "NEW";
			this.params = {
				pid: pid,
				sid: sid,
				itimes: itimes,
				color: color
			};
		}
			
		public function createDrawRequest(pid:String, sid:String, tableId:String):void {
			this.optype = "DRAW";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				draw_response: "1"
			};
		}

		public function createChatRequest(pid:String, sid:String, tableId:String, msg:String):void {
			this.optype = "MSG";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				msg: msg
			};
		}

		public function createLeaveRequest(pid:String, sid:String, tableId:String):void {
			this.optype = "LEAVE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}
		
		public function createResignRequest(pid:String, sid:String, tableId:String):void {
			this.optype = "RESIGN";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}
		
		public function createScoreRequest(pid:String, sid:String, tableId:String, score:String):void {
			this.optype = "E_SCORE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId,
				score: score
			};
		}

		public function createUpdateTableRequest(pid:String, sid:String, tid:String, itimes:String, bRated:Boolean) : void {
			this.optype = "UPDATE";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tid,
				itimes: itimes,
				rated: (bRated ? 1 : 0)
			};
		}

		public function getMessage():String {
			var str:String = "op=" + this.optype;
			for (var i:String in this.params) {
				str += "&" + i + "=" + this.params[i];
			}
			str += "\n";
			return str;
		}
		
		public function parseListResponse() : Object {
			var tables:Object = {};
			const entries:Array = this.params.content.split('\n');
			for (var i:int = 0; i < entries.length; i++) {
				const entry:String = entries[i];
				if (entry != "") {
				    trace("table entry: " + entry);
					var table:TableInfo = new TableInfo(entry);
					tables[table.tid] = table;
				}
			}
			return tables;
		}
	}
}