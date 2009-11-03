package
{
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static var app:ChessApp = null;

		public static const VERSION:String    = "0.9.0.7";
		public static const BASE_URI:String   = "http://www.playxiangqi.com/chesswhiz/";

		/**
		 * The internal name known only to the PlayXiangqi server.
		 */
		public static const INAME:String      = "FLASHCHESS"; 
	}
}