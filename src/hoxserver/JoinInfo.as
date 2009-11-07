package hoxserver
{
	public class JoinInfo
	{
		public var tid:String     = "";
		private var _pid:String   = "";
		private var _score:String = "";
		private var _color:String = "";

		public function JoinInfo(info:String)
		{
			const fields:Array = info.split(';');
			tid    = fields[0];
			_pid   = fields[1];
			_score = fields[2];
			_color = fields[3];
		}

		public function getPlayer():PlayerInfo
		{
			return new PlayerInfo(_pid, _color, _score);
		}
	}
}