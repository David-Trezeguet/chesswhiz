package hoxserver
{
	public class PlayerInfo
	{
		public var pid:String   = "";
		public var color:String = "";
		public var score:String = "";

		public function clone() : PlayerInfo
		{
			var player:PlayerInfo = new PlayerInfo();
			player.pid   = this.pid;
			player.score = this.score;
			player.color = this.color;
			return player;
		}
	}
}