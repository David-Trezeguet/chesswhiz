package hoxserver {
//op=DRAW&code=0&content=1;Guest#hox883

	public class DrawEvent {
		public var tid:String;
		public var pid:String;
		public function DrawEvent(event:String) {
			var fields:Array = event.split(';');
			this.tid = fields[0];
			this.pid = fields[1];
		}
		public function getTableID():String {
			return this.tid;
		}
		public function getPlayerID():String {
			return this.pid;
		}
	}
}