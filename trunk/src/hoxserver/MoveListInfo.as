package hoxserver {
	public class MoveListInfo
	{
		public var tid:String
		public var moves:Array;
		public function MoveListInfo() {
			this.tid = "";
			this.moves =new Array();			
		}
		
		public function parse(entry:String):void  {
			var fields:Array = entry.split(';');
			this.tid = fields[0];
			var poslist:Array = fields[1].split('/');
			for (var j:int = 0; j < poslist.length; j++) {
				this.moves[j] = poslist[j];
			}
		}
		
		public function getTableID():String {
			return this.tid;
		};
	}	
}