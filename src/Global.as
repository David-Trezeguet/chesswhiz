package
{
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static var app:ChessApp = null;

		public static const VERSION:String    = "0.9.3.2";

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
		[Embed(source="assets/red_player.png")]
		[Bindable]
		static public var redPlayerImgClass:Class;

		[Embed(source="assets/black_player.png")]
		[Bindable]
		static public var blackPlayerImgClass:Class;

		[Embed(source="assets/timer.png")]
		[Bindable]
		static public var timerImgClass:Class;

		[Embed(source="assets/volume_on.png")]
		[Bindable]
		static public var volumeOnImageClass:Class;

		[Embed(source="assets/volume_off.png")]
		[Bindable]
		static public var volumeOffImageClass:Class;

		[Embed(source="assets/move.mp3")]
		[Bindable]
		static public var moveSoundClass:Class;
	}
}