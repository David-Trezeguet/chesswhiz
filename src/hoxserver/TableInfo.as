package hoxserver
{
	public class TableInfo
	{
		public var tid:String         = "";
		public var group:String       = "";
		public var gametype:String    = "";
		public var initialtime:String = "";
		public var redtime:String     = "";
		public var blacktime:String   = "";
		public var redid:String       = "";
		public var redscore:String    = "";
		public var blackid:String     = "";
		public var blackscore:String  = "";

		public function TableInfo(info:String = "")
		{
			if ( info != "" )
			{
				const fields:Array = info.split(';');
				tid = fields[0];
				group = fields[1];
				gametype = fields[2];
				initialtime = fields[3];
				redtime = fields[4];
				blacktime = fields[5];
				redid = fields[6];
				redscore = fields[7];
				blackid = fields[8];
				blackscore = fields[9];
			}
        }

		public function clone():TableInfo
		{
			var tableData:TableInfo = new TableInfo();
			tableData.tid = tid;
			tableData.group = group;
			tableData.gametype = gametype;
			tableData.initialtime = initialtime;
			tableData.redtime = redtime;
			tableData.blacktime = blacktime;
			tableData.redid = redid;
			tableData.redscore = redscore;
			tableData.blackid = blackid;
			tableData.blackscore = blackscore;
			return tableData;
		}
			
		public function getRedPlayer():PlayerInfo
		{
			var player:PlayerInfo = new PlayerInfo();
			player.color = "Red";
			player.pid = this.redid;
			player.score = this.redscore;
			return player;
		}
		
		public function getBlackPlayer():PlayerInfo
		{
			var player:PlayerInfo = new PlayerInfo();
			player.color = "Black";
			player.pid = this.blackid;
			player.score = this.blackscore;
			return player;
		}
		
		public function getTime(color:String):String
		{
			return (color == "Red" ? this.redtime : this.blacktime);
		}
		
		public function updateTimes(times:String):void
		{
			this.redtime = times;
			this.blacktime = times;
		}
    }

}