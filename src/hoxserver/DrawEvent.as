package hoxserver
{
	public class DrawEvent
	{
		public var tid:String;
		public var pid:String;

		public function DrawEvent(event:String)
		{
			const fields:Array = event.split(';');
			this.tid = fields[0];
			this.pid = fields[1];
		}
	}
}