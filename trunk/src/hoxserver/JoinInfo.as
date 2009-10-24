package hoxserver {
	public class JoinInfo
	{
		private var tid: String;
		private var pid: String;
		private var score: String;
		private var color: String;
		public function JoinInfo() {
			tid = "";
			pid = "";
			score = "";
			color = "";
		}

		public function parse(entry:String):void {
			var fields:Array = entry.split(';');
			tid = fields[0];
			pid = fields[1];
			score = fields[2];
			color = fields[3];
		}
		public function getTableID():String {
			return this.tid;
		}
		public function getPlayer():PlayerInfo {
			var player:PlayerInfo = new PlayerInfo();
			player.setColor(this.color);
			player.setPlayerID(this.pid);
			player.setScore(this.score);
			return player;
		}
	}
}