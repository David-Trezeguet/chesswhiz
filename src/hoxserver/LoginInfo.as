package hoxserver {
	
    public class LoginInfo
	{
		public var pid:String;
		public var score:String;
		public var sid:String;
		public function LoginInfo() {
			pid = "";
			score = "";
			sid = "";
		}

		public function parse(entry:String):void  {
			trace("entry: " + entry);
			var fields:Array = entry.split(';');
			pid = fields[0];
			score = fields[1];
			sid = fields[2];
		}
		
		public function getPlayerID():String  {
			return this.pid;
		}
		public function getScore():String  {
			return this.score;
		}
		public function getSessionID():String  {
			return this.sid;
		}
    }
}