package
{
	import hoxserver.PlayerInfo;
	
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static const VERSION:String    = "0.9.6.0";

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

		/* Application-wide icons. */

		[Embed(source="assets/logout.png")]
		[Bindable]
		static public var logoutImageClass:Class;

		[Embed(source="assets/preferences.png")]
		[Bindable]
		static public var preferencesImageClass:Class;

		[Embed(source="assets/new.png")]
		[Bindable]
		static public var newImageClass:Class;

		[Embed(source="assets/list.png")]
		[Bindable]
		static public var listImageClass:Class;

		/* Table specific icons. */

		[Embed(source="assets/reverse.png")]
		[Bindable]
		static public var reverseImageClass:Class;

		[Embed(source="assets/settings.png")]
		[Bindable]
		static public var settingsImageClass:Class;

		[Embed(source="assets/white_flag.png")]
		[Bindable]
		static public var whiteFlagImageClass:Class;

		[Embed(source="assets/blue_flag.png")]
		[Bindable]
		static public var blueFlagImageClass:Class;
		
		[Embed(source="assets/go_first.png")]
		[Bindable]
		static public var goFirstImageClass:Class;
		
		[Embed(source="assets/go_previous.png")]
		[Bindable] static public var goPreviousImageClass:Class;
		
		[Embed(source="assets/go_next.png")]
		[Bindable]
		static public var goNextImageClass:Class;
		
		[Embed(source="assets/go_last.png")]
		[Bindable]
		static public var goLastImageClass:Class;
	}
}