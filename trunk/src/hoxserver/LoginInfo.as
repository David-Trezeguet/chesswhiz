package hoxserver
{
    public class LoginInfo
	{
		public var pid:String   = "";
		public var score:String = "";
		public var sid:String   = "";

		public function LoginInfo(info:String)
		{
			const fields:Array = info.split(';');
			pid   = fields[0];
			score = fields[1];
			sid   = fields[2];
		}
    }
}