﻿package {
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.system.Security;
	
	import hoxserver.*;
	
	import views.*;

	public class Session {
		public var socket:XMLSocket;
		public var hostName:String;
		public var port:int;
		public function Session() {
		}
		public function createSocket() : void {
			Security.allowDomain("games.playxiangqi.com");
			hostName = "games.playxiangqi.com";
			port = 80;
			//hostName = "localhost";
			//port = 80;
			socket = new XMLSocket();
			//socket.timeout = 60000;
		}
		public function connect() : void {
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
			var request:Message = new Message();
			socket.addEventListener(DataEvent.DATA, function(event:DataEvent):void {
				trace("received data: " + event.data);
				Global.vars.app.handleServerEvent(event);
		    });
			socket.connect(hostName, port);
		}
		public function closeSocket() : void {
			if (socket.connected) {
				socket.close();
			}
		}

//		public function onData(event:DataEvent):void {
//			trace("received data: " + event.data);
//		}

		public function sendRequest(req:Message):void  {
			var reqMsg:String = req.getMessage();
			trace("Sending request: " + reqMsg);
			if (socket.connected) {
				socket.send(reqMsg);
			}
			else {
			   Global.vars.app.processSocketCloseEvent();
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