package {
	import hoxserver.*;
	
	import ui.BoardCanvas;

	public class Game
	{
		private var _table:Table;
		private var _localPlayer:PlayerInfo = null
		private var _oppPlayer:PlayerInfo = null;
		private var _state:String = "idle";

		public function Game(table:Table)
		{
			_table = table;
		}
		
		public function setLocalPlayer(player:PlayerInfo) : void {
			_localPlayer = player.clone();
		}

		public function setOppPlayer(player:PlayerInfo) : void {
			_oppPlayer = player.clone();
		}

		public function getLocalPlayer() : PlayerInfo { return _localPlayer; }
		public function getOppPlayer()   : PlayerInfo { return _oppPlayer;   }
		public function getGameState()   : String     { return _state;       }

		public function waitingForMyMove() : Boolean {
	    	return (_state === "localmove");
		}

		public function processEvent(event:String) : void {
			if (_state === "idle") {
				if (event === "start") {
					this.start();
					if (_localPlayer.color === "Red") {
						_state = "localmove";
					}
					else {
						_state = "oppmove";
					}
				}
			}
			else if (_state === "localmove") {
				if (event === "move") {
					_state = "oppmove";
				}
			}
			else if (_state === "oppmove") {
				if (event === "move") {
					_state = "localmove";
				}
			}
		}

		public function start() : void {
			_table.view.board.enableEvents(_localPlayer.color);
		}

		private function _getMyPieces(type:String) : Array {
			return _table.view.board.getPiece(_localPlayer.color, type);
		}

		private function _getOppPieces(type:String) : Array {
			if (_localPlayer.color === "Black") {
				return _table.view.board.getPiece("Red", type);
			}
			return _table.view.board.getPiece("Black", type);
		}
		
		private function _isInsideFort(color:String, newPos:Position) : Boolean
		{
			if (color == "Black") {
				if ((newPos.column <= 5 && newPos.column >= 3) && (newPos.row <= 2 && newPos.row >= 0)) {
					return true;
				}
			} else {
				if ((newPos.column <= 5 && newPos.column >= 3) && (newPos.row <= 9 && newPos.row >= 7)) {
					return true;
				}				
			}
			return false;
		}

		public function validateMove(board:BoardCanvas, newPos:Position, piece:Piece) : Array
		{
			var result:Array = new Array();
			var reason:String = "";
			var curPiece:Piece = board.getPieceByPos(newPos);
			if (curPiece && (curPiece.getColor() === piece.getColor())) {
				// Invalid move
				reason = "same color piece at " + newPos.toString();
				result[0] = 0;
				result[1] = reason;
				return result;
			}
		
			var newRow:int = newPos.row;
			var newCol:int = newPos.column;
			var curRow:int = piece.getPosition().row;
			var curCol:int = piece.getPosition().column;
			// Not moved from current cell
			if (newRow === curRow && newCol === curCol) {
				reason = "new position " + newPos.toString() + "same as current position";
				result[0] = 0;
				result[1] = reason;
				return result;
			}
			var startRow:int = piece.getInitialPosition().row	;
			var startCol:int = piece.getInitialPosition().column;
			var rowDiff:int = Math.abs(curRow - newRow);
			var colDiff:int = Math.abs(curCol - newCol);
			var startRowDiff:int = Math.abs(startRow - newRow);
			var startColDiff:int = Math.abs(startCol - newCol);
			var verticalDir:int = 0;
			if ((curRow - newRow) > 0) {
				if (piece.getColor() === "Black") {
					verticalDir = -1;
				} else {
					verticalDir = 1;
				}
			} else if ((curRow - newRow) < 0){
				if (piece.getColor() === "Black") {
					verticalDir = 1; // forward move
				} else {
					verticalDir = -1; // backward move
				}
			}
			var horizontalDir:int = 0;
			if ((curCol - newCol) > 0) {
				horizontalDir = -1; // Left move
			} else if ((curCol - newCol) < 0) {
				horizontalDir = 1; // right move
			} else {
				horizontalDir = 0; // no movement in horizontal direction
			}
		
			var move:int = 0;
			if (rowDiff > 0) {
				if (colDiff > 0) {
					if ((rowDiff === 1 && colDiff === 2) || (rowDiff === 2 && colDiff === 1)) {
						move = 3; // L shape move
					} else if (rowDiff === colDiff) {
						move = 2; // Diagnol move
					}
					else {
						move = 4; // Steep move
					}
				} else {
					move = 1; // Vertical move
				}
			} else {
				move = 0; // Horizontal move
			}
			var curPos:Position = new Position(curRow, curCol);
			var interveningPieces:int = board.getInterveningPiece(curPos, newPos);
			var validMove:int = 0;
			if (piece.getType() === "king") {
				if ((startRowDiff <= 2 && startColDiff <= 2) &&
					((move === 0 && colDiff === 1) || (move === 1 && rowDiff === 1))) {
					if (_isInsideFort(piece.getColor(), newPos)) {
						validMove = 1;
					}
				}
				else if (curPiece && curPiece.getType() === "king" && move === 1 && interveningPieces === 0) {
					// Flying kin
					validMove = 1;
				}
			} else if (piece.getType() === "advisor") {
				if ((startRowDiff <= 2 && startColDiff <= 2) &&
					(move === 2 && rowDiff === 1 && colDiff === 1)) {
					if (_isInsideFort(piece.getColor(), newPos)) {
						validMove = 1;
					}
				}
			} else if (piece.getType() === "elephant") {
				if ((startRowDiff <= 4) &&
					(move === 2 && rowDiff === 2 && colDiff === 2)  && interveningPieces === 0) {
					validMove = 1;
				}
			} else if (piece.getType() === "horse") {
				if (move === 3 && interveningPieces === 0) {
					validMove = 1;
				}
			} else if (piece.getType() === "chariot") {
				if ((move === 0  || move === 1) && interveningPieces === 0) {
					validMove = 1;
				}
			} else if (piece.getType() === "cannon") {
				if (move === 0 || move === 1) {
					if (curPiece !== null) {
						if (interveningPieces === 1) {
							validMove = 1;
						}
					} else {
						if (interveningPieces === 0) {
							validMove = 1;
						}
					}
				}
			}  else if (piece.getType() === "pawn") {
				if (board.isMySide(piece.getColor(), newPos)) {
					if (move === 1 && rowDiff === 1 && verticalDir === 1) {
						validMove = 1;
					}
				} else {
					// Pawn is on the othser side of the board
					if ((move === 1 && rowDiff === 1 && verticalDir === 1) || (move === 0 && colDiff === 1)) {
						validMove = 1;
					}
				}
			}
			if (validMove != 1) {
				reason = "can not move to " + newPos.toString();
			}
			result[0] = validMove;
			result[1] = reason;
			return result;
		}

		public function isCheckMate(piece:Piece) : Boolean
		{
			var resultObj:Array = null;
			var myKing:Array = _getMyPieces("king");
			var myKingPos:Position = myKing[0].getPosition();
			if (piece) {
				resultObj = this.validateMove(_table.view.board, myKingPos, piece);
				if (resultObj[0]) {
					return true;
				}
			}
			var types:Array = ["cannon", "horse", "chariot", "king"];
			for (var j:int = 0; j < types.length; j++) {
				var pieces:Array = _getOppPieces(types[j]);
				for (var i:int = 0; i < pieces.length; i++) {
					var oPiece:Piece = pieces[i];
					if (oPiece && !oPiece.isCaptured()) {
						resultObj = this.validateMove(_table.view.board, myKingPos, oPiece);
						if (resultObj[0]) {
							return true;
						}
					}
				}
			}
			return false;
		}
   } 
}