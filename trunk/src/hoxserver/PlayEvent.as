package hoxserver {
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
 	import flash.net.URLRequest;
	import flash.display.*;
	import flash.events.Event;

	public class PlayEvent extends flash.events.Event {
		private var color:String;
		private var playerId:String;
		private var tableId:String;

		public void function PlayEvent(pid, tid, color) {
			this.color = color;
			this.playerId = pid;
			this.tableId = tid;
			
		}
	}
}