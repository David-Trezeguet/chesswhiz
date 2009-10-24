package {
	import flash.display.Sprite;
	
	import mx.containers.Canvas;
	import mx.containers.Panel;
	
	public class Board extends Sprite 
	{
		private var  mWidth:int;
		private	var  mHeight:int;
		private	var  margin:int;
		private var cellWidth:int;
		private var cellHeight:int;
		private var panel:Canvas;
		private var offset:int;
		private var redPieces:Array = null;
		private var blackPieces:Array = null;
		private var redPieceHash:Array = null;
		private var blackPieceHash:Array = null;		
		private var pieceMap:Array = null;
		private var game:Game = null;
		private var parentClip:Panel = null;
		private var tableObj:Table;
		private var lastPieceInFocus:Piece = null;
		private var pieceSkinIndex:int = 1;
		private var bgColor:uint;
		private var lineColor:uint;
		public function Board(width:int, height:int, table:Table)
		{
			mWidth = width;
			mHeight = height;
			margin = 50;
			cellWidth = (width - 2 * margin)/8;
			cellHeight = (height - 2 * margin)/9;
			panel = null;
			offset = 45;
			this.tableObj = table;
            
			redPieces = new Array(16);
			blackPieces = new Array(16);
			redPieceHash = new Array();
			blackPieceHash = new Array();
			pieceMap = new Array(10);
			for (var k:int = 0; k < 10; k++)
			{
				pieceMap[k] = new Array(9);
			
			}
			for(k = 0; k < 10; k++)
			{
				for(var m:int = 0; m < 9; m++)
				{
					pieceMap[k][m] = null;
				}
			}
			var index:int = 0;
			var color:String;
			color = "Red";
			//create piece objects
			redPieces[0] = new Piece(index++, "chariot", 9, 0, "rchariot.png", "rchariot0", color, this);
			redPieces[1] = new Piece(index++, "horse", 9, 1, "rhorse.png", "rhorse0", color, this);
			redPieces[2] = new Piece(index++, "elephant", 9, 2, "relephant.png", "relephant0", color, this);
			redPieces[3] = new Piece(index++, "advisor", 9, 3, "radvisor.png", "radvisor0", color, this);
			redPieces[4] = new Piece(index++, "king", 9, 4, "rking.png", "rking0", color, this);
			redPieces[5] = new Piece(index++, "advisor", 9, 5, "radvisor.png", "radvisor1", color, this);
			redPieces[6] = new Piece(index++, "elephant", 9, 6, "relephant.png", "relephant1", color, this);
			redPieces[7] = new Piece(index++, "horse", 9, 7, "rhorse.png", "rhorse1", color, this);
			redPieces[8] = new Piece(index++, "chariot", 9, 8, "rchariot.png", "rchariot1", color, this);
			redPieces[9] = new Piece(index++, "cannon", 7, 1, "rcannon.png", "rcannon0", color, this);
			redPieces[10] = new Piece(index++, "cannon", 7, 7, "rcannon.png", "rcannon1", color, this);

   			var id:String = "rpawn";
  			for (var pawn:int = 0; pawn < 5; pawn++) {
	        	redPieces[11 + pawn] = new Piece(index++, "pawn", 6, 2*pawn, "rpawn.png", id + pawn, color, this);
			}
			
			index = 0;
			color = "Black";
			blackPieces[0] = new Piece(index++, "chariot", 0, 0, "bchariot.png", "bchariot0", color, this);
			blackPieces[1] = new Piece(index++, "horse", 0, 1, "bhorse.png", "bhorse0", color, this);
			blackPieces[2] = new Piece(index++, "elephant", 0, 2, "belephant.png", "belephant0", color, this);
			blackPieces[3] = new Piece(index++, "advisor", 0, 3, "badvisor.png", "badvisor0", color, this);
			blackPieces[4] = new Piece(index++, "king", 0, 4, "bking.png", "bking0", color, this);
			blackPieces[5] = new Piece(index++, "advisor", 0, 5, "badvisor.png", "badvisor1", color, this);
			blackPieces[6] = new Piece(index++, "elephant", 0, 6, "belephant.png", "belephant1", color, this);
			blackPieces[7] = new Piece(index++, "horse", 0, 7, "bhorse.png", "bhorse1", color, this);
			blackPieces[8] = new Piece(index++, "chariot", 0, 8, "bchariot.png", "bchariot1", color, this);
			blackPieces[9] = new Piece(index++, "cannon", 2, 1, "bcannon.png", "bcannon0", color, this);
			blackPieces[10] = new Piece(index++, "cannon", 2, 7, "bcannon.png", "bcannon1", color, this);
	
   			id = "rpawn";
  			for (pawn = 0; pawn < 5; pawn++) {
	        	blackPieces[11 + pawn] = new Piece(index++, "pawn", 3, 2*pawn, "bpawn.png", id + pawn, color, this);
			}
 			// initialize piece map 
			pieceMap[0][0] = blackPieces[0];
			pieceMap[0][1] = blackPieces[1];
			pieceMap[0][2] = blackPieces[2];
			pieceMap[0][3] = blackPieces[3];
			pieceMap[0][4] = blackPieces[4];
			pieceMap[0][5] = blackPieces[5];
			pieceMap[0][6] = blackPieces[6];
			pieceMap[0][7] = blackPieces[7];
			pieceMap[0][8] = blackPieces[8];
			pieceMap[2][1] = blackPieces[9];
			pieceMap[2][7] = blackPieces[10];
			for (pawn = 0; pawn < 5; pawn++) {
	        	pieceMap[3][2*pawn] = blackPieces[11 + pawn];
			}
			//initialize Red pieces
			pieceMap[9][0] = redPieces[0];
			pieceMap[9][1] = redPieces[1];
			pieceMap[9][2] = redPieces[2];
			pieceMap[9][3] = redPieces[3];
			pieceMap[9][4] = redPieces[4];
			pieceMap[9][5] = redPieces[5];
			pieceMap[9][6] = redPieces[6];
			pieceMap[9][7] = redPieces[7];
			pieceMap[9][8] = redPieces[8];
			pieceMap[7][1] = redPieces[9];
			pieceMap[7][7] = redPieces[10];
			for (pawn = 0; pawn < 5; pawn++) {
	        	pieceMap[6][2*pawn] = redPieces[11 + pawn];
			}
			this.redPieceHash["king"] = [];
			this.redPieceHash["king"][0] = this.redPieces[4];
			this.redPieceHash["chariot"] = [];
			this.redPieceHash["chariot"][0] = this.redPieces[0];
			this.redPieceHash["chariot"][1] = this.redPieces[8];
			this.redPieceHash["horse"] = [];
			this.redPieceHash["horse"][0] = this.redPieces[1];
			this.redPieceHash["horse"][1] = this.redPieces[7];
			this.redPieceHash["elephant"] = [];
			this.redPieceHash["elephant"][0] = this.redPieces[2];
			this.redPieceHash["elephant"][1] = this.redPieces[6];
			this.redPieceHash["advisor"] = [];
			this.redPieceHash["advisor"][0] = this.redPieces[3];
			this.redPieceHash["advisor"][1] = this.redPieces[5];
			this.redPieceHash["cannon"] = [];
			this.redPieceHash["cannon"][0] = this.redPieces[9];
			this.redPieceHash["cannon"][1] = this.redPieces[10];
			this.redPieceHash["pawn"] = [];
			for (var i:int = 0; i < 5; i++) {
				this.redPieceHash["pawn"][i] = this.redPieces[11 + i];
			}
			this.blackPieceHash["king"] = [];
			this.blackPieceHash["king"][0] = this.blackPieces[4];
			this.blackPieceHash["chariot"] = [];
			this.blackPieceHash["chariot"][0] = this.blackPieces[0];
			this.blackPieceHash["chariot"][1] = this.blackPieces[8];
			this.blackPieceHash["horse"] = [];
			this.blackPieceHash["horse"][0] = this.blackPieces[1];
			this.blackPieceHash["horse"][1] = this.blackPieces[7];
			this.blackPieceHash["elephant"] = [];
			this.blackPieceHash["elephant"][0] = this.blackPieces[2];
			this.blackPieceHash["elephant"][1] = this.blackPieces[6];
			this.blackPieceHash["advisor"] = [];
			this.blackPieceHash["advisor"][0] = this.blackPieces[3];
			this.blackPieceHash["advisor"][1] = this.blackPieces[5];
			this.blackPieceHash["cannon"] = [];
			this.blackPieceHash["cannon"][0] = this.blackPieces[9];
			this.blackPieceHash["cannon"][1] = this.blackPieces[10];
			this.blackPieceHash["pawn"] = [];
			for (i = 0; i < 5; i++) {
				this.blackPieceHash["pawn"][i] = this.blackPieces[11 + i];
			}

		}
		public function createBoard(parentClip:Panel, bgColor:uint, lineColor:uint, pieceSkinIndex:int, leftMargin:int, topMargin:int):void
		{
			drawBoard(parentClip, bgColor, lineColor, pieceSkinIndex, leftMargin, topMargin);
			displayPieces();
		}

		public function drawBoard(parentClip:Panel, bgColor:uint, lineColor:uint, pieceSkinIndex:int, leftMargin:int, topMargin:int):void
		{
			this.pieceSkinIndex = pieceSkinIndex;
			this.parentClip = parentClip;
			this.lineColor = lineColor;
			this.bgColor = bgColor;
			panel = new Canvas();
			panel.x = leftMargin;
			panel.y = topMargin;
			panel.graphics.lineStyle(2, 0xa09e9e);
			panel.graphics.beginFill(bgColor);
			panel.graphics.drawRect(0, 0, this.mHeight, this.mWidth);
			panel.graphics.endFill();
			parentClip.addChild(panel);
			var i:int;
			var j:int;
			for(i = 0; i < 10; i++)
			{
				drawLine(panel, offset, offset+i*cellHeight, offset + 8*cellWidth, offset + i*cellHeight);
			}
	
			for(j = 0; j < 9; j++)
			{
				if (j === 0 || j === 8) {
					drawLine(panel, offset + cellWidth * j, offset, offset + cellWidth * j, offset + cellHeight * 9);
				}
				else {
					drawLine(panel, offset + cellWidth * j, offset, offset + cellWidth * j, offset + cellHeight * 4);
					drawLine(panel, offset + cellWidth * j, offset + 5 * cellHeight, offset + cellWidth * j, offset + cellHeight * 9);
				}
			}
	
			drawLine(panel, offset + 3*cellWidth, offset, offset + 5*cellWidth, offset + cellHeight*2);
			drawLine(panel, offset + 5*cellWidth, offset, offset + 3*cellWidth, offset + cellHeight*2);
			drawLine(panel, offset + 3*cellWidth, offset + 7 * cellHeight, offset + 5*cellWidth, offset + cellHeight * 9);
			drawLine(panel, offset + 5*cellWidth, offset + 7 * cellHeight, offset + 3*cellWidth, offset + cellHeight * 9);

			var offsetLeft:int = offset;
	        var offsetTop:int = offset;
			// draw row headers
			var order:String = "ascending";
			if (this.tableObj.getTopSideColor() == "Red") {
				order = "descending";
			}
			this.drawHeader("row", offsetLeft, offsetTop, 10, order);
			this.drawHeader("column", offsetLeft, offsetTop, 9, order);
			this.drawHeader("row", offset + (cellWidth * 9) + 15, offset, 10, order);
			this.drawHeader("column", offsetLeft, offsetTop + (10 * cellHeight) + 10, 9, order);
		}

		public function displayPieces() : void {
			var i:int = 0;
			for (i = 0; i < 16; i++) {
				redPieces[i].draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
			}
			for (i = 0; i < 16; i++) {
				blackPieces[i].draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
			}
		}
		public function drawLine(panel:Canvas, startX:int, startY:int, endX:int, endY:int):void
		{
			panel.graphics.lineStyle(1, lineColor);
			panel.graphics.moveTo(startX, startY);
			panel.graphics.lineTo(endX, endY);
		}
		public function drawHeader(type:String, offsetLeft:int, offsetTop:int, numCells:int, order:String) : void {
			var start:int = 0;
			if (order == "descending") {
				start = numCells - 1;
			}
			var left:int = offsetLeft - 40;
			var top:int = 0;
			if (type == "row") {
				for (var i:int = 0; i < numCells; i++) {
					top = offsetTop + (i * cellHeight) - 6; 
					Util.createTextField(this.panel, "" + start, left, top, false, lineColor, "Verdana", 12);
					if (order == "descending") {
						start--;
					}
					else {
						start++;
					}
				}
			}
			else {
				top =  offsetTop - 40;
				for (var j:int = 0; j < numCells; j++) {
					left = offsetLeft + (j * cellWidth) - 6;
					Util.createTextField(this.panel, String.fromCharCode(97 + start), left, top, false, lineColor, "Verdana", 12);
					if (order == "descending") {
						start--;
					}
					else {
						start++;
					}
				}
			}
		}

		public function getNearestCell(x:int, y:int, radius:int):Position
		{
			var i:int;
			var j:int; 
			var yRow:int;
			var xColumn:int;
			var cell:Array;
			trace("x: " + x + " y: " + y);
			trace("panel mouse x: " + panel.mouseX + " y: " + panel.mouseY);
			trace("container x: " + Global.vars.app.mainWindow.x + " y: " + Global.vars.app.mainWindow.y);
			trace("toolbar x: " + Global.vars.app.mainToolBar.x + " y: " + Global.vars.app.mainToolBar.y);
			for (i = 0; i < 10; i++)
			{
				//yRow = Global.vars.app.mainWindow.y + this.parentClip.y + panel.y + offset + cellHeight * i;
				yRow = offset + cellHeight * i;
				//yRow = offset + cellHeight * i;
				if (Math.abs(panel.mouseY-yRow) < radius)
				{
					trace("row"+i);
					break;
				}
			}
			for (j = 0; j < 9; j++)
			{
				//xColumn = Global.vars.app.mainWindow.x + this.parentClip.x + panel.x + offset + cellWidth * j;
				xColumn = offset + cellWidth * j;
				//xColumn = offset + cellWidth * j;
				if (Math.abs(panel.mouseX-xColumn) < radius)
				{					
					trace("col"+j);
					break;
				}
			}
			var pos:Position = new Position(0, 0);
			if (i >= 10 || j >= 9) {
				pos.row = pos.column = -1;
			}
			else {
				pos.row = i;
				pos.column = j;
			}
			return pos;
		}

		public function getX(column:int) : int {
			return offset + column * cellWidth;
		}

		public function getY(row:int) : int {
			return offset + row * cellHeight;
		}
		public function getPieceByPos(pos:Position):Piece
		{
			return pieceMap[pos.row][pos.column];
		}
		public function getPiece(color:String, type:String) : Array {
			return (color == "Red") ? this.redPieceHash[type] : this.blackPieceHash[type];
		}
		public function getPieceByIndex(color:String, index:String) : Piece {
			if (color === "Red") {
				return this.redPieces[index];
			}
			return this.blackPieces[index];
		}
		public function getGame():Game
		{
			return this.tableObj.getGame();
		}
		public function getTable():Table
		{
			return this.tableObj;
		}

		public function getInterveningPiece(curPos:Position, newPos:Position) : int
		{
			var numPieces:int = 0;
			var newRow:int = newPos.row;
			var newCol:int = newPos.column;
			var curRow:int = curPos.row;
			var curCol:int = curPos.column;
			var rowDiff:int = Math.abs(curRow - newRow);
			var colDiff:int = Math.abs(curCol - newCol);
			var move:int = 0;
			if (rowDiff > 0) {
				if (colDiff > 0) {
					if ((rowDiff === 1 && colDiff === 2) || (rowDiff === 2 && colDiff === 1)) {
						move = 3; // L shape move
					} else if (rowDiff === colDiff) {
						move = 2; // Diagnol move
					} else {
						move = 4; // Steep move
					}
				} else {
					move = 1; // Vertical move
				}
			} else {
				move = 0; // Horizontal move
			}
			var startCol:int = curCol;
			if (curCol > newCol) {
				startCol = newCol;
			}
			var startRow:int = curRow;
			if (curRow > newRow) {
				startRow = newRow;
			}
			var i:int = 0;
			if (move === 0) {
				for (i = 1; i < colDiff; i++) {
					if (this.pieceMap[curRow][startCol + i] !== null) {
						numPieces++;
					}
				}
			} else if (move === 1) {
				for (i = 1; i < rowDiff; i++) {
					if (this.pieceMap[startRow + i][curCol] !== null) {
						numPieces++;
					}
				}
			} else if (move === 2) {
				if (curRow < newRow) {
					for (i = 1; i < rowDiff; i++) {
						if (curCol < newCol) {
							if (this.pieceMap[curRow + i][curCol + i] !== null) {
								numPieces++;
							}
						} else {
							if (this.pieceMap[curRow + i][curCol - i] !== null) {
								numPieces++;
							}
						}
					}
				} else {
					for (i = 1; i < rowDiff; i++) {
						if (curCol < newCol) {
							if (this.pieceMap[curRow - i][curCol + i] !== null) {
								numPieces++;
							}
						} else {
							if (this.pieceMap[curRow - i][curCol - i] !== null) {
								numPieces++;
							}
						}
					}
				}
			}  else if (move === 3) {
				if (rowDiff === 1 && colDiff === 2) {
					if (curCol > newCol) {
						if (this.pieceMap[curRow][curCol - 1] !== null) {
							numPieces++;
						}
					} else {
						if (this.pieceMap[curRow][curCol + 1] !== null) {
							numPieces++;
						}
					}
				} else {
					if (curRow > newRow) {
						if (this.pieceMap[curRow - 1][curCol] !== null) {
							numPieces++;
						}
					} else {
						if (this.pieceMap[curRow + 1][curCol] !== null) {
							numPieces++;
						}
					}
				}
			}

			return numPieces;
		}		
		
		public function isMySide(color:String, pos:Position):Boolean
		{
			if (color === "Black") {
				if (pos.row < 5) {
					return true;
				}
			}
			else {
				if (pos.row >= 5) {
					return true;
				}
			}
			return false;
		}
		
		public function updatePieceMapState(piece:Piece, oldPos:Position, newPos:Position) : void
		{
			pieceMap[newPos.row][newPos.column] = piece;
			pieceMap[oldPos.row][oldPos.column] = null;
		}

		public function updatePieceMap(newPos:Position, piece:Piece) : void
		{
			var curPiece:Piece = pieceMap[newPos.row][newPos.column];
			var oldPos:Position = piece.getPosition();
			pieceMap[newPos.row][newPos.column] = piece;
			pieceMap[oldPos.row][oldPos.column] = null;
			if (curPiece) {
				curPiece.setCapture(true);
				curPiece.removeImage(panel);
			}
			piece.setPosition(newPos);
		}
		public function setFocus(piece:Piece) : void {
			if (this.lastPieceInFocus) {
				this.lastPieceInFocus.clearFocus();
				this.lastPieceInFocus = null;
			}
			if (piece) {
				piece.setFocus();
				this.lastPieceInFocus = piece;
			}
		}

		public function movePieceByPos(piece:Piece, newPos:Position, moveImage:Boolean) : void {
			updatePieceMap(newPos, piece);
			if (moveImage) {
				piece.moveImage();
				if (this.lastPieceInFocus) {
					this.lastPieceInFocus.clearFocus();
				}
				piece.setFocus();
			}
			this.lastPieceInFocus = piece;
		}
		public function rewindPieceByPos(piece:Piece, curPos:Position, prevPos:Position, capturedPiece:Piece) : void {
			pieceMap[prevPos.row][prevPos.column] = piece;
			pieceMap[curPos.row][curPos.column] = capturedPiece;
			if (this.lastPieceInFocus) {
				this.lastPieceInFocus.clearFocus();
			}
			piece.setPosition(prevPos);
			piece.moveImage();
			if (capturedPiece) {
				capturedPiece.setCapture(false);
				capturedPiece.setPosition(curPos);
				capturedPiece.draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
				capturedPiece.setFocus();
				this.lastPieceInFocus = capturedPiece;
			}
			else {
				piece.setFocus();
				this.lastPieceInFocus = piece;
			}
		}
		public function isNormalView() : Boolean {
			if (this.tableObj.getBottomSideColor() === "Black") {
				return true;
			}
			return false;
		}
		
		public function getViewPosition(pos:Position) : Position {
			if (this.isNormalView()) {
				var tRow:int = Math.abs(pos.row - 9);
				var tColumn:int = Math.abs(pos.column - 8);
				return new Position(tRow, tColumn);
			}
			return new Position(pos.row, pos.column);
		}
		public function getAbsolutePosition(pos:Position) : Position {
			if (this.isNormalView()) {
				var tRow:int = Math.abs(pos.row - 9);
				var tColumn:int = Math.abs(pos.column - 8);
				return new Position(tRow, tColumn);
			}
			return new Position(pos.row, pos.column);
		}

		public function displayStatus(status:String) : void {
			Util.createTextField(this.panel, status, this.getX(1), this.getY(4) + 10, false, 0x33CCFF, "Verdana", 18);
		}

		public function enableEvents(color:String) : void {
			var i:int;
			if (color == "Red") {
				for (i = 0; i < 16; i++) {
					this.redPieces[i].enableEvents();
				}
			}
			else {
				for (i = 0; i < 16; i++) {
					this.blackPieces[i].enableEvents();
				}
			}
		}

		public function disableEvents(color:String) : void {
			var i:int;
			if (color == "Red") {
				for (i = 0; i < 16; i++) {
					this.redPieces[i].disableEvents();
				}
			}
			else {
				for (i = 0; i < 16; i++) {
					this.blackPieces[i].disableEvents();
				}
			}			
		}
		public function getRedPieces() : Array {
			var pieces:Array = new Array();
			for (var i:int = 0; i < this.redPieces.length; i++) {
				pieces[i] = this.redPieces[i].clone();
			}
			return pieces;
		}
		public function getBlackPieces() : Array {
			var pieces:Array = new Array();
			for (var i:int = 0; i < this.blackPieces.length; i++) {
				pieces[i] = this.blackPieces[i].clone();
			}
			return pieces;
		}
		public function reDraw(changeSet:Array, focusPiece:Piece) : void {
			if (changeSet == null || changeSet.length == 0) {
				return;
			}
			var i:int = 0;
			var piece:Piece = null;
			var captured:Boolean = false;
			var pos1:Position = null;
			var pos2:Position = null;
			var color:String = "";
			var index:int = 0;
			for (var j:int = 0; j < changeSet.length; j++) {
				color = changeSet[j][0];
				index = parseInt(changeSet[j][1]);
				if (color == "Red") {
					piece = redPieces[index];
				}
				else {
					piece = blackPieces[index];
				}
				captured = changeSet[j][4];
				pos1 = piece.getPosition();
				pos2 = new Position(parseInt(changeSet[j][2]), parseInt(changeSet[j][3]));
				if (!captured) {
					if (piece.isCaptured()) {
						piece.setPosition(pos2);
						piece.draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
						if (piece.isEventsEnabled()) {
							piece.enableEvents();
						}
					}
					else {
						if (pos1.Compare(pos2) != 0) {
							piece.removeImage(panel);
							piece.setPosition(pos2);
							piece.draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
							if (piece.isEventsEnabled()) {
								piece.enableEvents();
							}
						}
					}
					piece.setCapture(false);
				} else {
					if (!piece.isCaptured()) {
						piece.removeImage(panel);
					}
					piece.setPosition(pos2);
					piece.setCapture(true);
				}
			}
			if (focusPiece != null) {
				if (this.lastPieceInFocus) {
					this.lastPieceInFocus.clearFocus();
				}
				focusPiece.setFocus();
				lastPieceInFocus = focusPiece;
			}
		}
		public function restoreState() : void {
			var i:int = 0;
			var piece:Piece = null;
			var pos1:Position = null;
			var pos2:Position = null;
			for (i = 0; i < redPieces.length; i++) {
				piece = redPieces[i];
				pos1 = piece.getPosition();
				if (!(piece.isCaptured())) {
					if (!(redPieces[i].isCaptured())) {
						redPieces[i].removeImage(panel);
					}
					piece.draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
					if (piece.isEventsEnabled()) {
						piece.enableEvents();
					}
				}
			}
			for (i = 0; i < blackPieces.length; i++) {
				piece = blackPieces[i];
				pos1 = piece.getPosition();
				if (!(piece.isCaptured())) {
					if (!(blackPieces[i].isCaptured())) {
						blackPieces[i].removeImage(panel);
					}
					piece.draw(panel, offset, cellWidth, cellHeight, pieceSkinIndex);
					if (piece.isEventsEnabled()) {
						piece.enableEvents();
					}
				}
			}
		}
		
		public function getPieceMapInfo() : String {
			var result:String = "piecemap: \n";
			var line:String = "";
			var piece:Piece = null;
			var k:int = 0;
			var m:int = 0;
			var pos:Position = null;
			for(k = 0; k < 10; k++)
			{
				for(m = 0; m < 9; m++)
				{
					piece = pieceMap[k][m];
					if (piece != null) {
						pos = piece.getPosition();
						line = pos.toString() + ": " + piece.getColor() + " " + piece.getType() + "\n";
						result += line;
					}
				}
			}
			return result;
		}
		
		public function getRedPiecesInfo() : String {
			var result:String = "redpieces: \n";
			var line:String = "";
			var piece:Piece = null;
			var pos:Position = null;
			for (var i:int = 0; i < this.redPieces.length; i++) {
				piece = this.redPieces[i];
				pos = piece.getPosition();
				line = "" + piece.getType() + " " + pos.toString() + " " + (piece.isCaptured() ? "captured" : "")  + "\n";
				result += line;
			}
			return result;
		}
		public function getBlackPiecesInfo() : String {
			var result:String = "blackpieces: \n";
			var line:String = "";
			var piece:Piece = null;
			var pos:Position = null;
			for (var i:int = 0; i < this.blackPieces.length; i++) {
				piece = this.blackPieces[i];
				pos = piece.getPosition();
				line = "" + piece.getType() + " " + pos.toString() + " " + (piece.isCaptured() ? "captured" : "")  + "\n";
				result += line;
			}
			return result;
		}
		
		public function changePiecesSkin(skinIndex:int) : void {
			var piece:Piece = null;
			var i:int = 0;
			for (i = 0; i < 16; i++) {
				piece = redPieces[i];
				if (!(piece.isCaptured())) {
					piece.removeImage(panel);
					if (skinIndex == 3) {
						piece.setImageCenter(22, 28);
					} else {
						piece.setImageCenter(22, 22);
					}
					piece.draw(panel, offset, cellWidth, cellHeight, skinIndex);
					if (piece.isEventsEnabled()) {
						piece.enableEvents();
					}
				}
			}
			for (i = 0; i < 16; i++) {
				piece = blackPieces[i];
				if (!(piece.isCaptured())) {
					piece.removeImage(panel);
					if (skinIndex == 3) {
						piece.setImageCenter(22, 28);
					} else {
						piece.setImageCenter(22, 22);
					}
					piece.draw(panel, offset, cellWidth, cellHeight, skinIndex);
					if (piece.isEventsEnabled()) {
						piece.enableEvents();
					}
				}
			}
			pieceSkinIndex = skinIndex;
		}
		
		public function getFocusPiece() : Piece {
			return this.lastPieceInFocus;
		}
	}
}
