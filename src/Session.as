package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.system.Security;
	
	import hoxserver.*;

	public class Session {
		private var _socket:XMLSocket  = null;
		private const _hostName:String = "games.playxiangqi.com";
		private const _port:int        = 80;

		public function Session() {
			Security.allowDomain("games.playxiangqi.com");
		}

		public function createSocket() : void {
			_socket = new XMLSocket();
			//_socket.timeout = 60000;
		}

		public function connect() : void {
			_socket.addEventListener(Event.CLOSE, function(status:Boolean):void {
			       trace("connection to socket closed");
				   Global.app.processSocketCloseEvent();
            });
			_socket.addEventListener(Event.CONNECT, function(status:Boolean):void {
				if (status) {
					trace("successfully connected to server");
					Global.app.processSocketConnectEvent();
				}
				else {
					trace("failed to connect to server");
				}
			});
			_socket.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
				trace("received data: " + event.data);
				Global.app.handleServerEvent(event);
		    });
			_socket.connect(_hostName, _port);
		}

		public function closeSocket() : void {
			if (_socket.connected) {
				_socket.close();
			}
		}

		public function sendRequest(req:Message):void  {
			var reqMsg:String = req.getMessage();
			trace("Sending request: " + reqMsg);
			if (_socket.connected) {
				_socket.send(reqMsg);
			}
			else {
			   Global.app.processSocketCloseEvent();
			}
		}

		public function sendRegisterRequest(uname:String, passwd:String):void  {
			var req:Message = new Message();
			req.createRegisterRequest(uname, passwd);
			this.sendRequest(req);
		}
		
		public function sendLoginRequest(uname:String, passwd:String, version:String):void  {
			var req:Message = new Message();
			req.createLoginRequest(uname, passwd, version);
			this.sendRequest(req);
		}
		
		public function sendLogoutRequest(pid:String, sid:String):void  {
			var req:Message = new Message();
			req.createLogoutRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendTableListRequest(pid:String, sid:String):void  {
			var req:Message = new Message();
			req.createListRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendJoinRequest(pid:String, sid:String, tid:String, color:String, joined:String):void  {
			var req:Message = new Message();
			req.createJoinRequest(pid, sid, tid, color, joined);
			this.sendRequest(req);
		}
		
		public function sendNewTableRequest(pid:String, sid:String, color:String):void  {
			var req:Message = new Message();
			req.createNewTableRequest(pid, sid, color);
			this.sendRequest(req);
		}
		
		public function sendMoveRequest(pid:String, sid:String, curPos:Position, newPos:Position, time:String, tid:String):void  {
			//op=MOVE&game_time=1486&move=2524&pid=bharat&status=in_progress&tid=1
			var req:Message = new Message();
			var move:String = "" + curPos.column + curPos.row + newPos.column + newPos.row;
			req.createMoveRequest(pid, sid, time, move, tid);
			this.sendRequest(req);
		}
		
		public function sendPollRequest(pid:String, sid:String):void  {
			var req:Message = new Message();
			req.createPollRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendLeaveRequest(pid:String, sid:String, tid:String):void  {
			var req:Message = new Message();
			req.createLeaveRequest(pid, sid, tid);
			this.sendRequest(req);
		}
		
		public function sendResignRequest(pid:String, sid:String, tid:String):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req:Message = new Message();
			req.createResignRequest(pid, sid, tid);
			this.sendRequest(req);
		}
		
		public function sendDrawRequest(pid:String, sid:String, tid:String):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req:Message = new Message();
			req.createDrawRequest(pid, sid, tid);
			this.sendRequest(req);
		}

		public function sendChatRequest(pid:String, sid:String, tid:String, msg:String):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req:Message = new Message();
			req.createChatRequest(pid, sid, tid, msg);
			this.sendRequest(req);
		}
	}
}