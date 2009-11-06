package hoxserver
{
	public class EndEvent
	{
		public var tid:String;
		public var winner:String;
		public var reason:String;

		public function EndEvent(event:String)
		{
			const fields:Array = event.split(';');
			this.tid    = fields[0];
			this.winner = fields[1];
			this.reason = fields[2];
		}
	}
}