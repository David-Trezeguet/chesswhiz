package hoxserver
{
	public class PlayerInfo
	{
		public var pid:String   = "";
		public var color:String = "";
		public var score:String = "";

		public function PlayerInfo(pid:String, color:String, score:String)
		{
			this.pid   = pid;
			this.color = color;
			this.score = score;
		}

		public function clone() : PlayerInfo
		{
			return new PlayerInfo( pid, color, score );
		}
	}
}