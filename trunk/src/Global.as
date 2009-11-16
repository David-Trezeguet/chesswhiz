package
{
	import hoxserver.PlayerInfo;
	
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static const VERSION:String    = "0.9.7.8";

		/**
		 * The reference to the global Application.
		 */
		public static var app:ChessApp = null;

		/**
		 * The reference to THE player (i.e., the local player).
		 */
		public static var player:PlayerInfo = null;

		/**
		 * The internal name known only to the PlayXiangqi server.
		 */
		public static const INAME:String      = "FLASHCHESS";

		/**
		 * The 'version' that is sent to the PlayXiangqi server during the login phase.
		 */
		public static const LOGIN_VERSION:String = INAME + "-" + VERSION;

		/**
		 * Embedded assets.
		 */

		[Embed(source="assets/move.mp3")]
		[Bindable]
		static public var moveSoundClass:Class;
	}
}