package
{
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static var app:ChessApp = null;

		public static const VERSION:String    = "0.9.0.8";
		public static const BASE_URI:String   = "http://www.playxiangqi.com/chesswhiz/";

		/**
		 * The internal name known only to the PlayXiangqi server.
		 */
		public static const INAME:String      = "FLASHCHESS";

		/**
		 * The 'version' that is sent to the PlayXiangqi server during the login phase.
		 */
		public static const LOGIN_VERSION:String = INAME + "-" + VERSION;
	}
}