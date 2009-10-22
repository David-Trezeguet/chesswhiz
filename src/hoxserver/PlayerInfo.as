package hoxserver {
public class PlayerInfo
{
	public var  pid:String;
    public var color:String;
    public var score:String;
	public function PlayerDate()
	{
		this.pid = "";
		this.color = "";
		this.score = "";
	}

		public function parse(entry):void {
		var fields = entry.split(';');
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
		 public function setPlayerID(pid):void  {
			this.pid = pid;
		}
		 public function setScore(score):void  {
			this.score = score;
		}
		public function setColor(color):void  {
			this.color = color;
		}
		public function clone():PlayerInfo  {
			var player = new PlayerInfo();
			player.pid = this.pid;
			player.score = this.score;
			player.color = this.color;
			return player;
		}
}
}