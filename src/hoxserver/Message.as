﻿/***************************************************************************
 *  Copyright 2009-2010 Bharatendra Boddu <bharathendra@yahoo.com>         *
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

package hoxserver
{
	public class Message
	{
		public var optype:String = "";
		private var params:Object = {};

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

		public function createResetRequest(pid:String, sid:String, tableId:String):void {
			this.optype = "RESET";
			this.params = {
				pid: pid,
				sid: sid,
				tid: tableId
			};
		}

		public function createChatRequest(pid:String, sid:String, msg:String, tableId:String, oid:String):void {
			this.optype = "MSG";
			this.params = {
				pid: pid,
				sid: sid,
				msg: Util.escapeURL(msg),
				tid: tableId,
				oid: oid
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

		public function createQueryPlayerInfoRequest(pid:String, sid:String, oid:String) : void {
			this.optype = "PLAYER_INFO";
			this.params = {
				pid: pid,
				sid: sid,
				oid: oid
			};
		}

		public function createInvitePlayerRequest(pid:String, sid:String, oid:String, tid:String) : void {
			this.optype = "INVITE";
			this.params = {
				pid: pid,
				sid: sid,
				oid: oid,
				tid: tid   /* The table-ID is optional and can be empty. */
			};
		}

		/**
		 * Serialize the message into the format to be sent out to the server.
		 */
		public function getMessage():String {
			var str:String = "op=" + this.optype;
			for (var i:String in this.params) {
				str += "&" + i + "=" + this.params[i];
			}
			str += "\n";
			return str;
		}

		/* =================================================================*
		 *                                                                  *
		 *    Functions to parse events coming from the remote server.      *
		 *                                                                  *
		 * =================================================================*/

		public function parse_LOGIN() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					pid   : fields[0],
					score : fields[1],
					sid   : fields[2]
				};
		}

		public function parse_E_JOIN() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid   : fields[0],
					pid   : fields[1],
					score : fields[2],
					color : fields[3]
				};
		}

		public function parse_LEAVE() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid   : fields[0],
					pid   : fields[1]
				};
		}

		public function parse_MOVE() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid     : fields[0],
					pid     : fields[1],
					fromRow : parseInt( fields[2].charAt(1) ),
					fromCol : parseInt( fields[2].charAt(0) ),
					toRow   : parseInt( fields[2].charAt(3) ),
					toCol   : parseInt( fields[2].charAt(2) )
				};
		}

		public function parse_I_MOVES() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid    : fields[0],
					moves  : fields[1].split('/')
				};
		}

		public function parse_E_END() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid    : fields[0],
					winner : fields[1],
					reason : fields[2]
				};
		}

		public function parse_DRAW() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid  : fields[0],
					pid  : fields[1]
				};
		}

		public function parse_MSG() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					pid  : fields[0],
					msg  : Util.unescapeURL(fields[1]),
					tid  : this.getTableId()
				};
		}

		public function parse_UPDATE() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid    : fields[0],
					pid    : fields[1],
					rated  : (fields[2] == "1"),
					itimes : fields[3]
				};
		}

		public function parse_I_PLAYERS() : Object
		{
			var players:Array = [];
			const entries:Array = this.params.content.split('\n');
			for each (var entry:String in entries)
			{
				if ( entry == "" ) { continue; }
				const fields:Array = entry.split(';');
				players.push( { pid  : fields[0],
								score : fields[1] } );
			}
			return players;
		}

		public function parse_PLAYER_INFO() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					pid    : fields[0],
					score  : fields[1],
					wins   : fields[2],
					draws  : fields[3],
					losses : fields[4]
				};
		}

		public function parse_INVITE() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					pid    : fields[0],  // The inviting player's ID.
					score  : fields[1],  // The inviting player's Score.
					oid    : fields[2],  // The invited player
					tid    : this.getTableId()
				};
		}

		public function parse_E_SCORE() : Object
		{
			const fields:Array = params.content.split(';');
			return {
					tid    : fields[0],
					pid    : fields[1],
					score  : fields[2]
				};
		}

		public function parse_I_TABLE() : Object
		{
			return _helper_parse_I_TABLE( params.content, true /* observersRequired */ );
		}

		public function parse_LIST() : Object
		{
			var tables:Object = {};
			const entries:Array = this.params.content.split('\n');
			for (var i:int = 0; i < entries.length; i++)
			{
				const entry:String = entries[i];
				if (entry != "")
				{
				    //trace("table entry: " + entry);
					var table:Object = _helper_parse_I_TABLE(entry);
					tables[table.tid] = table;
				}
			}
			return tables;
		}

		/**
		 * The STATIC function to help parsing the following two events:
		 *   (1) The "I_TABLE" event
		 *   (2) The "LIST" event (consisting of the "I_TABLE" elements).
		 */
		private static function _helper_parse_I_TABLE(inputContent:String, observersRequired:Boolean=false) : Object
		{
			// Chop off the ending ";" to avoid having an "empty-string" observer. 
			if ( inputContent.charAt(inputContent.length-1) == ";" ) {
				inputContent = inputContent.substr(0, inputContent.length-1);
			}

			const fields:Array = inputContent.split(';');
			var tableInfo:Object = {
					tid         : fields[0],
					group       : fields[1],
					rated       : (fields[2] == "0"), // NOTE: Strange but true!
					initialtime : fields[3],
					redtime     : fields[4],
					blacktime   : fields[5],
					redid       : fields[6],
					redscore    : fields[7],
					blackid     : fields[8],
					blackscore  : fields[9]
				};

			if (observersRequired) {
				tableInfo.observers = fields.slice(10);
			}

			return tableInfo;
		}
	}
}