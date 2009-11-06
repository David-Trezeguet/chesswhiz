package hoxserver
{
	public class MoveInfo
	{
		public var tid: String  = "";
		public var pid: String  = "";
		public var fromRow:int  = -1;
		public var fromCol:int  = -1;
		public var toRow:int    = -1;
		public var toCol:int    = -1;

		public function MoveInfo(info:String)
		{
			const fields:Array = info.split(';');
			tid = fields[0];
			pid = fields[1];

			const move:String = fields[2];
			fromRow = parseInt( move.charAt(1) );
			fromCol = parseInt( move.charAt(0) );
			toRow   = parseInt( move.charAt(3) );
			toCol   = parseInt( move.charAt(2) );		
		}
	}
}