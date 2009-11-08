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
    }

}