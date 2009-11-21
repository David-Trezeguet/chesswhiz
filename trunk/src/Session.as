/***************************************************************************
 *  Copyright 2009-2010           <chesswhiz@playxiangqi.com>              *
 *                      Huy Phan  <huyphan@playxiangqi.com>                *
 *                                                                         * 
 *  This file is part of ChessWhiz.                                        *
 *                                                                         *
 *  ChessWhiz is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  ChessWhiz is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with ChessWhiz.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/

package
{
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
		private var _sid:String         = "";   // The session-ID.

		public function Session()
		{
			Security.allowDomain("games.playxiangqi.com");
		}

		public function getSid() : String { return _sid; }
		public function setSid(id:String) : void { _sid = id; }

		public function open() : void
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

		public function close() : void
		{
			if (_socket.connected) {
				_socket.close();
			}
			_sid = "";
		}

		private function _sendRequest(req:Message) : void
		{
			const reqMsg:String = req.getMessage();
			if (_socket.connected) {
				trace("Sending: " + reqMsg);
				_socket.send(reqMsg);
			}
			else {
			   trace("Session: Fail to send request. Connection lost.");
			}
		}
		
		public function sendLoginRequest(pid:String, passwd:String, version:String):void  {
			var req:Message = new Message();
			req.createLoginRequest(pid, passwd, version);
			_sendRequest(req);
		}
		
		public function sendLogoutRequest(pid:String):void {
			var req:Message = new Message();
			req.createLogoutRequest(pid, _sid);
			_sendRequest(req);
		}
		
		public function sendTableListRequest(pid:String):void {
			var req:Message = new Message();
			req.createListRequest(pid, _sid);
			_sendRequest(req);
		}
		
		public function sendJoinRequest(pid:String, tid:String, color:String):void {
			var req:Message = new Message();
			req.createJoinRequest(pid, _sid, tid, color);
			_sendRequest(req);
		}
		
		public function sendNewTableRequest(pid:String, color:String, itimes:String):void {
			var req:Message = new Message();
			req.createNewTableRequest(pid, _sid, color, itimes);
			_sendRequest(req);
		}
		
		public function sendMoveRequest(pid:String, curPos:Position, newPos:Position, tid:String):void {
			var req:Message = new Message();
			var move:String = "" + curPos.column + curPos.row + newPos.column + newPos.row;
			req.createMoveRequest(pid, _sid, move, tid);
			_sendRequest(req);
		}
		
		public function sendLeaveRequest(pid:String, tid:String):void {
			var req:Message = new Message();
			req.createLeaveRequest(pid, _sid, tid);
			_sendRequest(req);
		}
		
		public function sendResignRequest(pid:String, tid:String):void {
			var req:Message = new Message();
			req.createResignRequest(pid, _sid, tid);
			_sendRequest(req);
		}
		
		public function sendDrawRequest(pid:String, tid:String):void {
			var req:Message = new Message();
			req.createDrawRequest(pid, _sid, tid);
			_sendRequest(req);
		}

		public function sendResetRequest(pid:String, tid:String):void {
			var req:Message = new Message();
			req.createResetRequest(pid, _sid, tid);
			_sendRequest(req);
		}

		public function sendChatRequest(pid:String, msg:String, tid:String, oid:String = ""):void {
			var req:Message = new Message();
			req.createChatRequest(pid, _sid, msg, tid, oid);
			_sendRequest(req);
		}

		public function sendUpdateTableRequest(pid:String, tid:String, itimes:String, bRated:Boolean) : void {
			var req:Message = new Message();
			req.createUpdateTableRequest(pid, _sid, tid, itimes, bRated);
			_sendRequest(req);
		}

		public function sendQueryPlayerInfoRequest(pid:String, oid:String) : void {
			var req:Message = new Message();
			req.createQueryPlayerInfoRequest(pid, _sid, oid);
			_sendRequest(req);
		}

		public function sendInvitePlayerRequest(pid:String, oid:String, tid:String) : void {
			var req:Message = new Message();
			req.createInvitePlayerRequest(pid, _sid, oid, tid);
			_sendRequest(req);
		}
	}
}