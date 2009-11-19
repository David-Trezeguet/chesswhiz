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


		private var _nextColor:String = "Red"; // Keep track who moves NEXT.

		private var _redPieces:Array;
		private var _blackPieces:Array;

		private var _pieceMap:Array        = null;
		private var _redPieceHash:Object   = null;
		private var _blackPieceHash:Object = null;

		public function Referee()
		{
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

 			// --- Initialize the internal state.
			_resetInternalState();
		}

		public function resetGame() : void
		{
			for each (var piece:PieceInfo in _redPieces)
			{
				piece.setCaptured(false);
				piece.setPosition( piece.getInitialPosition() );
			}

			for each (piece in _blackPieces)
			{
				piece.setCaptured(false);
				piece.setPosition( piece.getInitialPosition() );
			}

			_nextColor = "Red";
			_resetInternalState();
		}

		public function getPieceInfoByPos(pos:Position):PieceInfo
		{
			return _pieceMap[pos.row][pos.column];
		}

		private function _resetInternalState() : void
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

			// --- Initialize piece hash.

			_redPieceHash = {};
			_redPieceHash["king"]     = [ _redPieces[4] ];
			_redPieceHash["chariot"]  = [ _redPieces[0], _redPieces[8] ];
			_redPieceHash["horse"]    = [ _redPieces[1], _redPieces[7] ];
			_redPieceHash["elephant"] = [ _redPieces[2], _redPieces[6] ];
			_redPieceHash["advisor"]  = [ _redPieces[3], _redPieces[5] ];
			_redPieceHash["cannon"]   = [ _redPieces[9], _redPieces[10] ];
			_redPieceHash["pawn"]     = [ _redPieces[11], _redPieces[12],
										  _redPieces[13], _redPieces[14], _redPieces[15] ];

			_blackPieceHash = {};
			_blackPieceHash["king"]     = [ _blackPieces[4] ];
			_blackPieceHash["chariot"]  = [ _blackPieces[0], _blackPieces[8] ];
			_blackPieceHash["horse"]    = [ _blackPieces[1], _blackPieces[7] ];
			_blackPieceHash["elephant"] = [ _blackPieces[2], _blackPieces[6] ];
			_blackPieceHash["advisor"]  = [ _blackPieces[3], _blackPieces[5] ];
			_blackPieceHash["cannon"]   = [ _blackPieces[9], _blackPieces[10] ];
			_blackPieceHash["pawn"]     = [ _blackPieces[11], _blackPieces[12],
											_blackPieces[13], _blackPieces[14], _blackPieces[15] ];
		}

		public function nextColor() : String { return _nextColor; }

		private function _getPiecesOfType(color:String, type:String) : Array
		{
			return (color == "Red") ? _redPieceHash[type] : _blackPieceHash[type];
		}

		private function _getIntervenedPiecesCount(curPos:Position, newPos:Position) : int
		{
			var numPieces:int = 0;   // The number intervened pieces.
			const newRow:int = newPos.row;
			const newCol:int = newPos.column;
			const curRow:int = curPos.row;
			const curCol:int = curPos.column;
			const rowDiff:uint = Math.abs(curRow - newRow);
			const colDiff:uint = Math.abs(curCol - newCol);

			var move:int = 0; // Move Type.
			if (rowDiff != 0) {
				if (colDiff != 0) {
					if ((rowDiff == 1 && colDiff == 2) || (rowDiff == 2 && colDiff == 1)) {
						move = 3; // L shape move
					} else if (rowDiff == colDiff) {
						move = 2; // Diagonal move
					} else {
						move = 4; // Steep move
					}
				} else {
					move = 1; // Vertical move
				}
			} else {
				move = 0; // Horizontal move
			}

			const startCol:int = (curCol > newCol ? newCol : curCol);
			const startRow:int = (curRow > newRow ? newRow : curRow);

			var i:int = 0;
			switch ( move )
			{
				case 0:  // Horizontal move
				{
					for (i = 1; i < colDiff; i++) {
						if (_pieceMap[curRow][startCol + i] != null) {
							numPieces++;
						}
					}
					break;
				}
				case 1:  // Vertical move
				{
					for (i = 1; i < rowDiff; i++) {
						if (_pieceMap[startRow + i][curCol] != null) {
							numPieces++;
						}
					}
					break;
				}
				case 2:  // Diagonal move
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
				case 3:  // L shape move
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
		public function validateAndRecordMove(piece:PieceInfo, newPos:Position) : Array
		{
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
			const oldPos:Position = piece.getPosition();
			const capturedPiece:PieceInfo = _recordMove(piece, newPos);

			/* If the Move violates one of the following rules:
			 *   (1) Its own King is checked.
			 *   (2) There is a KING-facing-KING situation
			 *
			 * then it is invalid and must be undone.
			 */
			if (   _isKingBeingChecked( piece.color )
			    /* || _isKingFacingKing() */ )  // FIXME: Need to implement King-facking-King.
			{
			    _undoMove(piece, oldPos, capturedPiece);
			    return [false, false];
			}

			/* Set the next-turn. */
			_nextColor = ( _nextColor == "Red" ? "Black" : "Red" );

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
			const capture:PieceInfo = this.getPieceInfoByPos(newPos);

			if (   (newPos.row == curPos.row && newPos.column == curPos.column) // Same position?
				|| (capture && capture.color == myColor) ) // ... or same side?
			{
				trace("Referee: Move is invalid (Same position or same side).");
				return false;
			}

			const rowDiff:uint = Math.abs(curPos.row - newPos.row);
			const colDiff:uint = Math.abs(curPos.column - newPos.column);

			var verticalDir:int = 0; // 1=forward move, -1=backward move
			if      (curPos.row > newPos.row) { verticalDir = (myColor == "Red" ? 1 : -1); }
			else if (curPos.row < newPos.row) { verticalDir = (myColor == "Red" ? -1 : 1); }

			const move:uint = _getMoveType(rowDiff, colDiff);
			var nIntervened:int = _getIntervenedPiecesCount(curPos, newPos);

			switch ( piece.type )
			{
				case "king":
				{
					if (   _isInsidePalace(myColor, newPos)
						&& ((move == M_HORIZONTAL && colDiff == 1) || (move == M_VERTICAL && rowDiff == 1)))
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
					if (  _isInsideCountry(myColor, newPos) ) // Within the country?
					{
						if (move == M_VERTICAL && rowDiff == 1 && verticalDir == 1)
						{
							return true;
						}
					}
					else // Outside the country (alread crossed the River)
					{
						if (   (move == M_VERTICAL && rowDiff == 1 && verticalDir == 1)
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

		private function _isKingBeingChecked(myColor:String) : Boolean
		{
			const myKing:Array = _getPiecesOfType(myColor, "king");
			const myKingPos:Position = myKing[0].getPosition();

			const oppColor:String = (myColor == "Red" ? "Black" : "Red");

			// FIXME: Missing "pawn" type!!!
			const types:Array = ["cannon", "horse", "chariot", "king"];

			for each (var type:String in types)
			{
				var oppPieces:Array = _getPiecesOfType(oppColor, type);
				for each (var oPiece:PieceInfo in oppPieces)
				{
					if ( oPiece && !oPiece.isCaptured() )
					{
						if ( _performBasicValidationOfMove(oPiece, myKingPos ) )
						{
							return true;
						}
					}
				}
			}
			return false;
		}

	}
}