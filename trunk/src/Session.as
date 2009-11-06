package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.system.Security;
	
	import hoxserver.*;

	public class Session
	{
		private const _hostName:String = "games.playxiangqi.com";
		private const _port:int        = 80;

		private var _socket:XMLSocket  = null;

		public function Session()
		{
			Security.allowDomain("games.playxiangqi.com");
		}

		public function openSocket() : void
		{
			_socket = new XMLSocket(); // Default connection timeout = 20 sec.

			_socket.addEventListener(Event.CONNECT, function(status:Boolean):void {
				if (status) { Global.app.processSocketConnectEvent(); }
				else        { trace("Failed to connect to server"); }
			});
			_socket.addEventListener(Event.CLOSE, function(status:Boolean):void {
				Global.app.processSocketCloseEvent();
            });
			_socket.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
				Global.app.handleServerEvent(event);
		    });

			_socket.connect(_hostName, _port);
		}

		public function closeSocket() : void
		{
			if (_socket.connected) {
				_socket.close();
			}
		}

		private function _sendRequest(req:Message) : void
		{
			var reqMsg:String = req.getMessage();
			trace("Sending request: " + reqMsg);
			if (_socket.connected) {
				_socket.send(reqMsg);
			}
			else {
			   Global.app.processSocketCloseEvent();
			}
		}
		
		public function sendLoginRequest(uname:String, passwd:String, version:String):void  {
			var req:Message = new Message();
			req.createLoginRequest(uname, passwd, version);
			_sendRequest(req);
		}
		
		public function sendLogoutRequest(pid:String, sid:String):void  {
			var req:Message = new Message();
			req.createLogoutRequest(pid, sid);
			_sendRequest(req);
		}
		
		public function sendTableListRequest(pid:String, sid:String):void  {
			var req:Message = new Message();
			req.createListRequest(pid, sid);
			_sendRequest(req);
		}
		
		public function sendJoinRequest(pid:String, sid:String, tid:String, color:String, joined:String):void  {
			var req:Message = new Message();
			req.createJoinRequest(pid, sid, tid, color, joined);
			_sendRequest(req);
		}
		
		public function sendNewTableRequest(pid:String, sid:String, color:String):void  {
			var req:Message = new Message();
			req.createNewTableRequest(pid, sid, color);
			_sendRequest(req);
		}
		
		public function sendMoveRequest(pid:String, sid:String, curPos:Position, newPos:Position, time:String, tid:String):void  {
			var req:Message = new Message();
			var move:String = "" + curPos.column + curPos.row + newPos.column + newPos.row;
			req.createMoveRequest(pid, sid, time, move, tid);
			_sendRequest(req);
		}
		
		public function sendLeaveRequest(pid:String, sid:String, tid:String):void  {
			var req:Message = new Message();
			req.createLeaveRequest(pid, sid, tid);
			_sendRequest(req);
		}
		
		public function sendResignRequest(pid:String, sid:String, tid:String):void  {
			var req:Message = new Message();
			req.createResignRequest(pid, sid, tid);
			_sendRequest(req);
		}
		
		public function sendDrawRequest(pid:String, sid:String, tid:String):void  {
			var req:Message = new Message();
			req.createDrawRequest(pid, sid, tid);
			_sendRequest(req);
		}

		public function sendChatRequest(pid:String, sid:String, tid:String, msg:String):void  {
			var req:Message = new Message();
			req.createChatRequest(pid, sid, tid, msg);
			_sendRequest(req);
		}
		
		public function sendUpdateTableRequest(pid:String, tid:String, times:String, r:Boolean) : void {
			var req:Message = new Message();
			req.createUpdateTableRequest(pid, tid, times, r);
			_sendRequest(req);
		}
	}
}