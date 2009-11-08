package hoxserver
{
	public class JoinInfo
	{
		public var tid:String   = "";
		public var pid:String   = "";
		public var score:String = "";
		public var color:String = "";

		public function JoinInfo(info:String)
		{
			const fields:Array = info.split(';');
			tid   = fields[0];
			pid   = fields[1];
			score = fields[2];
			color = fields[3];
		}
	}
}