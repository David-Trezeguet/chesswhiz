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
	public class PieceInfo
	{
		public var type:String;
		public var color:String;
		public var position:Position;

		private var _captured:Boolean = false;

		public function PieceInfo(type:String, color:String, position:Position)
		{
			this.type = type;
			this.color = color;
			this.position = position.clone();
		}

		public function clone() : PieceInfo
		{
			return new PieceInfo(this.type, this.color, this.position);
		}

		public function isCaptured():Boolean { return _captured; }
		public function setCaptured(val:Boolean) : void { _captured = val; }

		public function setPosition(newPosition:Position) : void
		{
			this.position.row = newPosition.row;
			this.position.column = newPosition.column;
		}

	}
}