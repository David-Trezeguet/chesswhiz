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
	public class Referee
	{
		/**
		 * Constants for the different Move Types.
		 */
		private static const M_HORIZONTAL:uint = 0;
		private static const M_VERTICAL:uint   = 1;
		private static const M_DIAGONAL:uint   = 2;
		private static const M_LSHAPE:uint     = 3;  // The L-shape.
		private static const M_OTHER:uint      = 4;  // The 'other' type.

		private var _nextColor:String = "None"; // Keep track who moves NEXT.
		private var _nMoves :uint = 0; // The number of moves.

		private var _redPieces:Array;
		private var _blackPieces:Array;

		private var _redKing:PieceInfo;
		private var _blackKing:PieceInfo;
		private var _pieceMap:Array;

		public function Referee()
		{
			this.resetGame();
		}

		/**
		 * Reset the Game back to the initial state.
		 *
		 * @note This function is optimized so that it will not reset TWICE
		 *       so that outside callers can call it multiple times with much
		 *       performance penalty.
		 */
		public function resetGame() : void
		{
			if ( _nextColor == "Red" && _nMoves == 0 )
			{
				return; // Already in the initial state. 
			}

			_nextColor = "Red";
			_nMoves = 0;

			// --- Create piece objects.

			_redPieces = new Array(16);
			_redPieces[0]  = new PieceInfo("chariot",  "Red", new Position(9, 0));
			_redPieces[1]  = new PieceInfo("horse",    "Red", new Position(9, 1));
			_redPieces[2]  = new PieceInfo("elephant", "Red", new Position(9, 2));
			_redPieces[3]  = new PieceInfo("advisor",  "Red", new Position(9, 3));
			_redPieces[4]  = new PieceInfo("king",     "Red", new Position(9, 4));
			_redPieces[5]  = new PieceInfo("advisor",  "Red", new Position(9, 5));
			_redPieces[6]  = new PieceInfo("elephant", "Red", new Position(9, 6));
			_redPieces[7]  = new PieceInfo("horse",    "Red", new Position(9, 7));
			_redPieces[8]  = new PieceInfo("chariot",  "Red", new Position(9, 8));
			_redPieces[9]  = new PieceInfo("cannon",   "Red", new Position(7, 1));
			_redPieces[10] = new PieceInfo("cannon",   "Red", new Position(7, 7));
  			for (var pawn:int = 0; pawn < 5; pawn++)
  			{
	        	_redPieces[11 + pawn] = new PieceInfo("pawn", "Red", new Position(6, 2*pawn));
			}

			_blackPieces = new Array(16);
			_blackPieces[0]  = new PieceInfo("chariot",  "Black", new Position(0, 0));
			_blackPieces[1]  = new PieceInfo("horse",    "Black", new Position(0, 1));
			_blackPieces[2]  = new PieceInfo("elephant", "Black", new Position(0, 2));
			_blackPieces[3]  = new PieceInfo("advisor",  "Black", new Position(0, 3));
			_blackPieces[4]  = new PieceInfo("king",     "Black", new Position(0, 4));
			_blackPieces[5]  = new PieceInfo("advisor",  "Black", new Position(0, 5));
			_blackPieces[6]  = new PieceInfo("elephant", "Black", new Position(0, 6));
			_blackPieces[7]  = new PieceInfo("horse",    "Black", new Position(0, 7));
			_blackPieces[8]  = new PieceInfo("chariot",  "Black", new Position(0, 8));
			_blackPieces[9]  = new PieceInfo("cannon",   "Black", new Position(2, 1));
			_blackPieces[10] = new PieceInfo("cannon",   "Black", new Position(2, 7));
  			for (pawn = 0; pawn < 5; pawn++)
  			{
	        	_blackPieces[11 + pawn] = new PieceInfo("pawn", "Black", new Position(3, 2*pawn));
			}

			// --- Initialize other internal variables.
			_redKing = _redPieces[4];
			_blackKing = _blackPieces[4];
			_initializePieceMap();
		}

		private function _initializePieceMap() : void
		{
			// --- Initialize piece map.
            _pieceMap = new Array(10);
			for (var i:int = 0; i < 10; i++)
			{
				_pieceMap[i] = new Array(9);
				for (var j:int = 0; j < 9; j++)
				{
					_pieceMap[i][j] = null;
				}
			}

			_pieceMap[0][0] = _blackPieces[0];
			_pieceMap[0][1] = _blackPieces[1];
			_pieceMap[0][2] = _blackPieces[2];
			_pieceMap[0][3] = _blackPieces[3];
			_pieceMap[0][4] = _blackPieces[4];
			_pieceMap[0][5] = _blackPieces[5];
			_pieceMap[0][6] = _blackPieces[6];
			_pieceMap[0][7] = _blackPieces[7];
			_pieceMap[0][8] = _blackPieces[8];
			_pieceMap[2][1] = _blackPieces[9];
			_pieceMap[2][7] = _blackPieces[10];
			for (var pawn:int = 0; pawn < 5; pawn++)
			{
	        	_pieceMap[3][2*pawn] = _blackPieces[11 + pawn];
			}

			_pieceMap[9][0] = _redPieces[0];
			_pieceMap[9][1] = _redPieces[1];
			_pieceMap[9][2] = _redPieces[2];
			_pieceMap[9][3] = _redPieces[3];
			_pieceMap[9][4] = _redPieces[4];
			_pieceMap[9][5] = _redPieces[5];
			_pieceMap[9][6] = _redPieces[6];
			_pieceMap[9][7] = _redPieces[7];
			_pieceMap[9][8] = _redPieces[8];
			_pieceMap[7][1] = _redPieces[9];
			_pieceMap[7][7] = _redPieces[10];
			for (pawn = 0; pawn < 5; pawn++)
			{
	        	_pieceMap[6][2*pawn] = _redPieces[11 + pawn];
			}
		}

		public function nextColor() : String { return _nextColor; }

		public function findPieceAtPosition(pos:Position) : PieceInfo
		{
			var piece:PieceInfo = _pieceMap[pos.row][pos.column];
			return ( piece ? piece.clone() : null );
		}

		private function _getPositionOfKing(color:String) : Position
		{
			const king:PieceInfo = (color == "Red" ? _redKing : _blackKing);
			return king.position.clone();	
		}

		/**
		 * @return The number of pieces between the two given positions.
		 */
		private function _getIntervenedCount(curPos:Position, newPos:Position) : uint
		{
			var numPieces:uint = 0;   // The number intervened pieces.
			const newRow:int = newPos.row;
			const newCol:int = newPos.column;
			const curRow:int = curPos.row;
			const curCol:int = curPos.column;
			const rowDiff:uint = Math.abs(curRow - newRow);
			const colDiff:uint = Math.abs(curCol - newCol);

			const startCol:int = (curCol > newCol ? newCol : curCol);
			const startRow:int = (curRow > newRow ? newRow : curRow);

			var i:int = 0;

			const move:uint = _getMoveType(rowDiff, colDiff);
			switch ( move )
			{
				case M_HORIZONTAL:
				{
					for (i = 1; i < colDiff; i++) {
						if (_pieceMap[curRow][startCol + i] != null) {
							numPieces++;
						}
					}
					break;
				}
				case M_VERTICAL:
				{
					for (i = 1; i < rowDiff; i++) {
						if (_pieceMap[startRow + i][curCol] != null) {
							numPieces++;
						}
					}
					break;
				}
				case M_DIAGONAL:
				{
					if (curRow < newRow) {
						for (i = 1; i < rowDiff; i++) {
							if (curCol < newCol) {
								if (_pieceMap[curRow + i][curCol + i] != null) {
									numPieces++;
								}
							} else {
								if (_pieceMap[curRow + i][curCol - i] != null) {
									numPieces++;
								}
							}
						}
					} else {
						for (i = 1; i < rowDiff; i++) {
							if (curCol < newCol) {
								if (_pieceMap[curRow - i][curCol + i] != null) {
									numPieces++;
								}
							} else {
								if (_pieceMap[curRow - i][curCol - i] != null) {
									numPieces++;
								}
							}
						}
					}
					break;
				}
				case M_LSHAPE:
				{
					if (rowDiff == 1 && colDiff == 2) {
						if (curCol > newCol) {
							if (_pieceMap[curRow][curCol - 1] != null) {
								numPieces++;
							}
						} else {
							if (_pieceMap[curRow][curCol + 1] != null) {
								numPieces++;
							}
						}
					} else {
						if (curRow > newRow) {
							if (_pieceMap[curRow - 1][curCol] != null) {
								numPieces++;
							}
						} else {
							if (_pieceMap[curRow + 1][curCol] != null) {
								numPieces++;
							}
						}
					}
					break;
				}
			} /* switch (...) */

			return numPieces;
		}		

		/**
		 * Check whether a position is inside the Palace (or Fortress).
		 */
		private function _isInsidePalace(color:String, pos:Position) : Boolean
		{
			if ( color == "Black" )
			{
				return (pos.column <= 5 && pos.column >= 3) && (pos.row <= 2 && pos.row >= 0);
			}
			/*      "Red"     */
			return (pos.column <= 5 && pos.column >= 3) && (pos.row <= 9 && pos.row >= 7);
		}

		/**
		 * Check whether a position is inside the same country
		 * (i.e., not yet cross the River).
		 */
		private function _isInsideCountry(color:String, pos:Position) : Boolean
		{
			if ( color == "Black" ) { return (pos.row >=0 && pos.row <= 4); }
			/*      "Red"       */    return (pos.row >= 5 && pos.row <= 9);
		}

		/**
		 * Check whether a give Move is valid. If yes, record the Move. 
		 *
		 * @return an Array of two elements:
		 *     result[0] - true if the Move is valid.
		 *     result[1] - true if the Move is a capture move.
		 */
		public function validateAndRecordMove(oldPos:Position, newPos:Position) : Array
		{
			var piece:PieceInfo = _pieceMap[oldPos.row][oldPos.column];
			if ( piece == null )
			{
				trace("Referee: Logic Error! Piece is null.");
				return [false, false];
			}

			/* Check for 'turn' */
			if ( piece.color != _nextColor )
			{
				return [false, false];
			}

			/* Perform a basic validation. */
			if ( ! _performBasicValidationOfMove(piece, newPos) )
			{
				return [false, false];
			}

			/* At this point, the Move is valid.
			 * Record this move (to validate future Moves).
			 */
			const capturedPiece:PieceInfo = _recordMove(piece, newPos);

			/* If the Move violates one rule, which says that
			 * "Your own King should not be checked after your Move.",
			 * then it is invalid and must be undone.
			 *
			 * NOTE: For the case of "King-facing-King", it has been taken
			 *       care of inside the "King" basic validation.
			 */
			if ( _isKingBeingChecked( piece.color ) )
			{
			    _undoMove(piece, oldPos, capturedPiece);
			    return [false, false];
			}

			/* Set the next-turn. */
			_nextColor = ( _nextColor == "Red" ? "Black" : "Red" );
			++_nMoves;

			const bCapturedMove:Boolean = (capturedPiece != null);
			return [true, bCapturedMove]; // Finally, it is a valid Move.
		}

		/**
		 * @return The piece being captured, if any..
		 */
		private function _recordMove(piece:PieceInfo, newPos:Position) : PieceInfo
		{
			var capturedPiece:PieceInfo = _pieceMap[newPos.row][newPos.column];
			if (capturedPiece)
			{
				capturedPiece.setCaptured(true);
			}

			_pieceMap[newPos.row][newPos.column] = piece;
			_pieceMap[piece.position.row][piece.position.column] = null;

			piece.setPosition(newPos);

			return capturedPiece;
		}

		private function _undoMove(piece:PieceInfo, oldPos:Position, capturedPiece:PieceInfo) : void
		{
			const curPos:Position = piece.position;

			_pieceMap[oldPos.row][oldPos.column] = piece;
			_pieceMap[curPos.row][curPos.column] = capturedPiece;
			
			piece.setPosition(oldPos);

			if (capturedPiece)
			{
				capturedPiece.setCaptured(false);
				capturedPiece.setPosition(curPos);
			}
		}

		/**
		 * Perform a basic validation.
		 *
		 * @return false if the Move is invalid.
		 */
		private function _performBasicValidationOfMove(piece:PieceInfo, newPos:Position) : Boolean
		{
			const myColor:String = piece.color;
			const curPos:Position = piece.position;
			const capture:PieceInfo = _pieceMap[newPos.row][newPos.column];

			if (   (newPos.row == curPos.row && newPos.column == curPos.column) // Same position?
				|| (capture && capture.color == myColor) ) // ... or same side?
			{
				trace("Referee: Move is invalid (Same position or same side).");
				return false;
			}

			const rowDiff:uint = Math.abs(curPos.row - newPos.row);
			const colDiff:uint = Math.abs(curPos.column - newPos.column);

			const move:uint = _getMoveType(rowDiff, colDiff);
			const nIntervened:uint = _getIntervenedCount(curPos, newPos);

			switch ( piece.type )
			{
				case "king":
				{
					if (   _isInsidePalace(myColor, newPos)
						&& ((move == M_HORIZONTAL && colDiff == 1) || (move == M_VERTICAL && rowDiff == 1)))
					{
						return true;
					}
					if (  capture && capture.type == "king"	/* Flying king */
						&& move == M_VERTICAL && nIntervened == 0 )
					{
						return true;
					}
					break;
				}
				case "advisor":
				{
					if (   _isInsidePalace(myColor, newPos)
						&& (move == M_DIAGONAL && rowDiff == 1))
					{
						return true;
					}
					break;
				}
				case "elephant":
				{
					if (   _isInsideCountry(myColor, newPos)
						&& (move == M_DIAGONAL && rowDiff == 2 && nIntervened == 0))
					{
						return true;
					}
					break;
				}
				case "horse":
				{
					if (move == M_LSHAPE && nIntervened == 0)
					{
						return true;
					}
					break;
				} 
				case "chariot":
				{
					if (    (move == M_HORIZONTAL || move == M_VERTICAL)
						 && nIntervened == 0 )
					{
						return true;
					}
					break;
				}
				case "cannon":
				{
					if (move == M_HORIZONTAL || move == M_VERTICAL)
					{
						if (   (capture && nIntervened == 1)
						    || (!capture && nIntervened == 0) )
						{
							return true;
						}
					}
					break;
				}
				case "pawn":
				{
					// Make sure the Move is never a "backward" move.
					const bFoward:Boolean = (  (myColor == "Red"   && newPos.row < curPos.row)
											|| (myColor == "Black" && newPos.row > curPos.row) ); 
					if (  _isInsideCountry(myColor, newPos) ) // Within the country?
					{
						if (move == M_VERTICAL && rowDiff == 1 && bFoward)
						{
							return true;
						}
					}
					else // Outside the country (alread crossed the River)
					{
						if (   (move == M_VERTICAL && rowDiff == 1 && bFoward)
							|| (move == M_HORIZONTAL && colDiff == 1) )
						{
							return true;
						}
					}
					break;
				}
			} /* switch(...) */

			return false;  // Invalid Move.
		}

		private function _getMoveType(rowDiff:uint, colDiff:uint) : uint
		{
			var move:uint = M_OTHER;   // Move type.

			if      (rowDiff == 0)       { move = M_HORIZONTAL; }
			else if (colDiff == 0)       { move = M_VERTICAL;   }
			else if (rowDiff == colDiff) { move = M_DIAGONAL;   }
			else if ( (rowDiff == 1 && colDiff == 2) || (rowDiff == 2 && colDiff == 1) )
			{
				move = M_LSHAPE;
			}

			return move;
		}

		/**
		 * This function performs that check to see of any of my opponent pieces
		 * can capture my own King.
		 */
		private function _isKingBeingChecked(myColor:String) : Boolean
		{
			const myKingPos:Position = _getPositionOfKing(myColor);

			const oppPieces:Array = (myColor == "Red" ? _blackPieces : _redPieces);

			for each (var oPiece:PieceInfo in oppPieces)
			{
				if (   oPiece.isCaptured()
					|| oPiece.type == "elephant" || oPiece.type == "advisor" )
				{
					continue;
				}

				if ( _performBasicValidationOfMove(oPiece, myKingPos) )
				{
					return true;
				}
			}
			
			return false;
		}

	}
}