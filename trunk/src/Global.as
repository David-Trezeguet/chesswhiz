/***************************************************************************
 *  Copyright 2009-2010           <chesswhiz@playxiangqi.com>              *
 *                      Huy Phan  <huyphan@playxiangqi.com>                *
 *                                                                         * 
 *  This file is part of ChessWhiz.                                        *
 *                                                                         *
 *  ChessWhiz is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  ChessWhiz is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with ChessWhiz.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/

package
{
	import hoxserver.PlayerInfo;
	
	/**
	 * The class contains the variables and constants
	 * to be globally shared throught the entire application.
	 */
	public final class Global
	{
		public static const VERSION:String = "0.9.9.4";

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
		public static const INAME:String = "FLASHCHESS";

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