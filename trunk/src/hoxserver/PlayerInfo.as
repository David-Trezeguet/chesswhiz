package hoxserver {
public class PlayerInfo
{
	public var pid:String;
    public var color:String;
    public var score:String;
	public function PlayerDate() : void
	{
		this.pid = "";
		this.color = "";
		this.score = "";
	}

		public function parse(entry:String):void {
			var fields:Array = entry.split(';');
			this.pid = fields[0];
			this.color = fields[1];
			this.score = fields[2];
		}

		public function getPlayerID():String  {
			return this.pid;
		}
		public function getScore():String  {
			return this.score;
		}
		public function getColor():String  {
			return this.color;
		}
		 public function setPlayerID(pid:String):void  {
			this.pid = pid;
		}
		 public function setScore(score:String):void  {
			this.score = score;
		}
		public function setColor(color:String):void  {
			this.color = color;
		}
		public function clone():PlayerInfo  {
			var player:PlayerInfo = new PlayerInfo();
			player.pid = this.pid;
			player.score = this.score;
			player.color = this.color;
			return player;
		}
}
}