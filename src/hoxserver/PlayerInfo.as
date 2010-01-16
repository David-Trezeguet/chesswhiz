/***************************************************************************
 *  Copyright 2009-2010 Bharatendra Boddu <bharathendra@yahoo.com>         *
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

package hoxserver
{
	public class PlayerInfo
	{
		public var pid:String   = "";
		public var color:String = "";
		public var score:String = "";

		public function PlayerInfo(pid:String, color:String, score:String)
		{
			this.pid   = pid;
			this.color = color;
			this.score = score;
		}
	}
}