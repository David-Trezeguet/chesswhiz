package {
	import flash.net.XMLSocket;
	import flash.system.Security;
	import flash.events.DataEvent;
	import flash.events.Event;
	import hoxserver.*;
	import views.*;

	public class Session {
		public var socket:XMLSocket;
		public var hostName:String;
		public var port:int;
		public function Session() {
		}
		public function createSocket() {
			Security.allowDomain("games.playxiangqi.com");
			hostName = "games.playxiangqi.com";
			port = 80;
			//hostName = "localhost";
			//port = 80;
			socket = new XMLSocket();
			//socket.timeout = 60000;
		}
		public function connect() {
			socket.addEventListener(Event.CLOSE, function(status:Boolean):void {
			       trace("connection to socket closed");
				   Global.vars.app.processSocketCloseEvent();
            });
			socket.addEventListener(Event.CONNECT, function(status:Boolean):void {
				if (status) {
					trace("successfully connected to server");
					Global.vars.app.processSocketConnectEvent();
				}
				else {
					trace("failed to connect to server");
				}
			});
			var request = new Message();
			socket.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
				trace("received data: " + event.data);
				Global.vars.app.handleServerEvent(event);
		    });
			socket.connect(hostName, port);
		}
		public function closeSocket() {
			if (socket.connected) {
				socket.close();
			}
		}

//		public function onData(event:DataEvent):void {
//			trace("received data: " + event.data);
//		}

		public function sendRequest(req):void  {
			var reqMsg = req.getMessage();
			trace("Sending request: " + reqMsg);
			if (socket.connected) {
				socket.send(reqMsg);
			}
			else {
			   Global.vars.app.processSocketCloseEvent();
			}
		}

		public function sendRegisterRequest(uname, passwd):void  {
			var req = new Message();
			req.createRegisterRequest(uname, passwd);
			this.sendRequest(req);
		}
		
		public function sendLoginRequest(uname, passwd, version):void  {
			var req = new Message();
			req.createLoginRequest(uname, passwd, version);
			this.sendRequest(req);
		}
		
		public function sendLogoutRequest(pid, sid):void  {
			var req = new Message();
			req.createLogoutRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendTableListRequest(pid, sid):void  {
			var req = new Message();
			req.createListRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendJoinRequest(pid, sid, tid, color, joined):void  {
			var req = new Message();
			req.createJoinRequest(pid, sid, tid, color, joined);
			this.sendRequest(req);
		}
		
		public function sendNewTableRequest(pid, sid, color):void  {
			var req = new Message();
			req.createNewTableRequest(pid, sid, color);
			this.sendRequest(req);
		}
		
		public function sendMoveRequest(pid, sid, curPos, newPos, time, tid):void  {
			//op=MOVE&game_time=1486&move=2524&pid=bharat&status=in_progress&tid=1
			var req = new Message();
			var move = "" + curPos.column + curPos.row + newPos.column + newPos.row;
			req.createMoveRequest(pid, sid, time, move, tid);
			this.sendRequest(req);
		}
		
		public function sendPollRequest(pid, sid):void  {
			var req = new Message();
			req.createPollRequest(pid, sid);
			this.sendRequest(req);
		}
		
		public function sendLeaveRequest(pid, sid, tid):void  {
			var req = new Message();
			req.createLeaveRequest(pid, sid, tid);
			this.sendRequest(req);
		}
		
		public function sendResignRequest(pid, sid, tid):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req = new Message();
			req.createResignRequest(pid, sid, tid);
			this.sendRequest(req);
		}
		
		public function sendDrawRequest(pid, sid, tid):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req = new Message();
			req.createDrawRequest(pid, sid, tid);
			this.sendRequest(req);
		}

		public function sendChatRequest(pid, sid, tid, msg):void  {
			//op=RESIGN&pid=Guest#hox5870&tid=1
			var req = new Message();
			req.createChatRequest(pid, sid, tid, msg);
			this.sendRequest(req);
		}
	}
}