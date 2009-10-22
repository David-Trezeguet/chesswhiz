package hoxserver {
	
	public class MoveInfo
	{
		private var tid: String;
		private var pid: String;
		private var move: String;
		private var status: String;
		public function MoveInfo() {
			tid = "";
			pid = "";
			move = "";
			status = "";
		}

		public function parse(entry:String):void {
			var fields:Array = entry.split(';');
			tid = fields[0];
			pid = fields[1];
			move = fields[2];
			status = fields[3];
		}
		
		public function getTableID():String {
			return this.tid;
		}
		public function getPlayerID():String {
			return this.pid;
		}
		public function getCurrentPosRow():int {
			return parseInt(this.move.charAt(1));

		}
		public function getCurrentPosCol():int {
			return parseInt(this.move.charAt(0));
		}
		public function getNewPosRow():int {
			return parseInt(this.move.charAt(3));
		}
		public function getNewPosCol():int {
			return parseInt(this.move.charAt(2));
		}
	}
}