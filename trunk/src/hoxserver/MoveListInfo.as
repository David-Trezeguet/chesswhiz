package hoxserver
{
	public class MoveListInfo
	{
		public var tid:String  = "";
		public var moves:Array = [];

		public function MoveListInfo(info:String)
		{
			const fields:Array = info.split(';');
			this.tid = fields[0];
			var poslist:Array = fields[1].split('/');
			for (var i:int = 0; i < poslist.length; i++) {
				this.moves[i] = poslist[i];
			}
		}
	}	
}