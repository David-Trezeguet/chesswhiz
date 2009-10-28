package {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import hoxserver.*;
	
	import ui.TableBoard;
	
	import views.*;
	
	public class Table {
		public var tableId:String;
		private var redPlayer:PlayerInfo;
		private var blackPlayer:PlayerInfo;
		private var observers:Array;
		public var view:TableBoard;
		private var game:Game;
		private var sides:Object;
		private var tableState:String;
		private var tableData:TableInfo;
		private var owner:String;
		private var redTimes:GameTimers;
		private var blackTimes:GameTimers;
		private var redTimer:Timer;
		private var blackTimer:Timer;
		private var pieceType:int;
		private var moveList:Array;
		private var curMoveIndex:int;
		private var stateBeforeReview:String;
		private var settings:Object;
		private var curPref:Object;

		public function Table(tableId:String, pref:Object) {
			this.tableId = tableId;
			this.redPlayer = null;
			this.blackPlayer = null;
			this.observers = [];
			this.game = null;
			this.sides = {
				top:  new Side("top", "Red", null),
				bottom: new Side("bottom", "Black", null)
			};
			this.view = null;
			this.tableState = "IDLE_STATE";
			this.tableData = null;
			this.owner = "";
			this.redTimes = null;
			this.blackTimes = null;
			this.redTimer = null;
			this.blackTimer = null;
			this.pieceType = 1;
			this.moveList = [];
		    this.observers = new Array();
			this.curMoveIndex = -1;
			stateBeforeReview = "IDLE_STATE";
			settings = {};
			settings["gametime"] = 1200;
			settings["movetime"] = 300;
			settings["extratime"] = 20;
			settings["rated"] = false;
			curPref = pref;
		}

		public function setTableData(tableData:TableInfo):void {
			this.tableData = tableData.clone();
		}
		
		public function setRedPlayer(player:PlayerInfo):void {
			this.redPlayer = player.clone();
		}
		
		public function setBlackPlayer(player:PlayerInfo):void {
			this.blackPlayer =  player.clone();
		}
		
		public function setOwner(pid:String):void {
			this.owner = pid;
		}
		
		public function getOwner():String {
			return this.owner;
		}
		
		public function setObserver(player:PlayerInfo):void {
			this.observers[this.observers.length] = player.clone();
		}
		
		public function init(tableData:TableInfo):void {
			if ( tableData.getRedPlayer() ) {
				this.setRedPlayer(tableData.getRedPlayer());
			}
		
			if ( tableData.getBlackPlayer() ) {
				this.setBlackPlayer(tableData.getBlackPlayer());
			}
		}
		
		public function getTopSideColor():String {
			return this.sides.top.color;
		}
		
		public function getBottomSideColor():String {
			return this.sides.bottom.color;
		}
		
		public function getGame():Game {
			return this.game;
		}
		public function setSideColors(color:String):void {
			if (color === "Red") {
				this.sides.top.color = "Black";
				this.sides.bottom.color = "Red";
			}
			else if (color === "Black") {
				this.sides.top.color = "Red";
				this.sides.bottom.color = "Black";
			}
			else if (color == "") {
				this.sides.top.color = "Black";
				this.sides.bottom.color = "Red";
			}
		}
		public function getTimers(color:String) : GameTimers {
			return new GameTimers(this.tableData.getTime(color));			
		}
		public function getJoinColor():String {
			var joinColor:String = "";
			if ( (this.redPlayer !== null && this.redPlayer.getPlayerID() !== "") && 
				 (this.blackPlayer === null || this.blackPlayer.getPlayerID() === "") ) {
				joinColor = "Black";
			}
			else if ( (this.blackPlayer !== null && this.blackPlayer.getPlayerID() !== "") &&
					  (this.redPlayer === null || this.redPlayer.getPlayerID() === "") ) {
				joinColor = "Red";
			}
			return joinColor;
		}
		public function newTable(tableData:TableInfo):void {
			if ( tableData.getRedPlayer() != null ||
				 tableData.getRedPlayer().getPlayerID() != "" ) {
				this.setRedPlayer(tableData.getRedPlayer());
			}
			if ( tableData.getBlackPlayer() != null ||
				 tableData.getBlackPlayer().getPlayerID() != "" ) {
				this.setBlackPlayer(tableData.getBlackPlayer());
			}
			this.setTableData(tableData);
			this.processTableEvent("TABLEINFO_EVENT", tableData);
		}
		
		public function createView ():void {
			Global.vars.app.clearView();
			//this.view = new TableView(Global.vars.app.mainWindow, this);
			//this.view.display();
			this.view = new TableBoard();
			this.view.display(this);
			Global.vars.app.mainWindow.addChild(this.view);
		}

		public function reviewMove(cmd:String) : void {
			if (tableState != "MOVEREVIEW_STATE") {
				if (moveList.length > 0 && cmd != "end" && cmd != "forward") {
					curMoveIndex = moveList.length;
					stateBeforeReview = tableState;
				}
				else {
					return;
				}
			}
			this.processTableEvent("MOVEREVIEW_EVENT", cmd);
		}

		public function createNewTableView():void {
			if (this.view === null) {
				this.createView();
			}
			if (this.redPlayer !== null && this.redPlayer.getPlayerID() === Global.vars.app.playerId) {
				this.view.displayPlayerData(this.redPlayer);
			}
			else if (this.blackPlayer !== null && this.blackPlayer.getPlayerID() === Global.vars.app.playerId) {
				this.view.displayPlayerData(this.blackPlayer);
			}
		}
		
		public function createObserveTableView(joinColor:String) : void {
			if (this.view === null) {
				this.createView();
			}
			if (this.redPlayer !== null && this.redPlayer.getPlayerID() !== "") {
				this.view.displayPlayerData(this.redPlayer);
				this.view.displayMessage("" + this.redPlayer.getPlayerID() + " joined");
			}
			if (this.blackPlayer !== null && this.blackPlayer.getPlayerID() !== "") {
				this.view.displayPlayerData(this.blackPlayer);
				this.view.displayMessage("" + this.blackPlayer.getPlayerID() + " joined");
			}
			trace("joinable color: " + joinColor);
			Global.vars.app.showObserverMenu(joinColor, this.tableId);
		}

		public function displayChatMessage(pid:String, chatMsg:String) : void {
			this.view.displayChatMessage(pid, chatMsg);
		}
		public function getMoveListInfo():String {
			var result:String = "movelist: \n";
			var mov:String = "";
			var line:String = "";
			for (var i:int = 0; i < this.moveList.length; i++) {
				mov = this.moveList[i];
				var fields:Array = mov.split(":");
				line = fields[0] + " " + this.view.board.getPieceByIndex(fields[0], fields[1]).getType() + " " + fields[2].charAt(0) + "," + String.fromCharCode(97 + parseInt(fields[2].charAt(1))) + "->" + fields[2].charAt(2) + "," + String.fromCharCode(97 + parseInt(fields[2].charAt(3))) + "\n";
				result += line;
			}
			return result;
		}

		public function displayPlayers():void {
			if (this.view === null) {
				return;
			}
			if (this.sides.top.color == "Red") {
				this.view.displayPlayerData(this.redPlayer);
			}
			else {
				this.view.displayPlayerData(this.blackPlayer);
			}
			if (this.sides.bottom.color == "Red") {
				this.view.displayPlayerData(this.redPlayer);
			}
			else {
				this.view.displayPlayerData(this.blackPlayer);
			}
		}

		public function startGame() : void {
			if ( (this.redPlayer !== null && this.redPlayer.getPlayerID() !== "") &&
				 (this.blackPlayer !== null && this.blackPlayer.getPlayerID() !== "") ) {
				if (this.redPlayer.getPlayerID() === Global.vars.app.playerId) {
					this.game = new Game(this);
					this.game.setLocalPlayer(this.redPlayer);
					this.game.setOppPlayer(this.blackPlayer);
					this.game.processEvent("start");
				}
				else if (this.blackPlayer.getPlayerID() === Global.vars.app.playerId) {
					this.game = new Game(this);
					this.game.setLocalPlayer(this.blackPlayer);
					this.game.setOppPlayer(this.redPlayer);
					this.game.processEvent("start");
				}
			}
		}

		public function resumeGame() : void {
			if(this.game) {
				this.game.start();
			}
			else {
				this.startGame();
			}
		}
		
		public function stopGame(reason:String, winner:String) : void {
			if (this.game) {
				this.view.board.disableEvents(this.game.getLocalPlayer().getColor());
				this.game = null;
			}
			this.view.board.displayStatus("Game Over (" + reason + ")");
			this.view.displayMessage(winner);
			this.stopTimer();
			this.processTableEvent("RESIGNGAME_EVENT", null);
		}
		
		public function drawGame(pid:String) : void {
			this.view.displayMessage("" + pid + " offering draw");
		}
		
		public function updateGameTimes(pid:String, times:String) : void
		{
			if (this.moveList.length == 0) {
				var timer:GameTimers = null;
				this.tableData.updateTimes(times);
				timer = new GameTimers(times);
				this.view.updateTimers(getTopSideColor(), timer);
				this.view.updateTimers(getBottomSideColor(), timer);
				var fields:Array = times.split("/");
				this.settings["gametime"] = fields[0];
				this.settings["movetime"] = fields[1];
				this.settings["extratime"] = fields[2];
				this.view.displayMessage("timer changed to " + times);
			}
		}
	
		public function startTimer() : void {
			this.redTimes = new GameTimers(this.tableData.getRedTime());
			this.redTimer = new Timer(1000, this.redTimes.gameTime);
			this.redTimer.addEventListener(TimerEvent.TIMER, this.timerHandler);

			this.blackTimes = new GameTimers(this.tableData.getBlackTime());
			this.blackTimer = new Timer(1000, this.blackTimes.gameTime);
			this.blackTimer.addEventListener(TimerEvent.TIMER, this.timerHandler);
			var color:String = this.getMoveColor();
			if (color == "Red") {
				this.redTimer.start();
			} else {
				this.blackTimer.start();
			}
		}

		public function getMoveColor():String {
			var color:String = "";
			if (game != null) {
				if (this.game.waitingForMyMove()) {
					color = this.game.getLocalPlayer().getColor();
				}
				else {
					color = this.game.getOppPlayer().getColor();
				}
			}
			else {
				if (this.moveList.length > 0) {
					var lastMove:String = this.moveList[this.moveList.length - 1];
					if (lastMove != "") {
						var fields:Array = lastMove.split(":");
						color = (fields[0] == "Red") ? "Black" : "Red";
					}
				}
			}
			return color;
		}
		public function stopTimer() : void {
			if (this.redTimer) {
				this.redTimer.stop();
			}
			if (this.blackTimer) {
				this.blackTimer.stop();
			}
		}
		public function resetTimer() : void {
			var color:String = this.getMoveColor();
			if (color === "Red") {
				this.blackTimes.resetMoveTime();
				this.blackTimer.stop();
				this.redTimer.start();
			}
			else {
				this.redTimes.resetMoveTime();
				this.redTimer.stop();
				this.blackTimer.start();
			}
		}

		public function timerHandler(event:Event) : void {
			var color:String = this.getMoveColor();
			if (color === "Red") {
				if (this.redTimes) {
					this.redTimes.gameTime--;
					if (this.redTimes.gameTime == 0) {
						this.gameTimeout(color);
                        return;
					}
					this.redTimes.moveTime--;
					if (this.redTimes.moveTime == 0) {
						this.moveTimeout(color);
						this.redTimer.stop();
						return;
					}
					this.view.updateTimers("Red", this.redTimes);
				}
			}
			else if (color === "Black") {
				if (this.blackTimes) {
					this.blackTimes.gameTime--;
					if (this.blackTimes.gameTime == 0) {
						this.gameTimeout(color);
                        return;
					}
					this.blackTimes.moveTime--;
					if (this.blackTimes.moveTime == 0) {
						this.moveTimeout(color);
						this.blackTimer.stop();
						return;
					}
					this.view.updateTimers("Black", this.blackTimes);
				}
			}
		}

		public function moveTimeout(color:String) : void {
			this.view.displayMessage(color + " move timeout");
			this.processTableEvent("MOVETIMEOUT_EVENT", color);
		}
		public function gameTimeout(color:String) : void {
			this.view.displayMessage(color + " game timeout");
			this.processTableEvent("GAMETIMEOUT_EVENT", color);
		}

		public function closeTable() : void {
		    this.stopTimer();
		}
		public function playMoveList(moveList:MoveListInfo) : void {
			for (var i:int = 0; i < moveList.moves.length; i++) {
				var curPos:Position = new Position(parseInt(moveList.moves[i].charAt(1)), parseInt(moveList.moves[i].charAt(0)));
				var newPos:Position = new Position(parseInt(moveList.moves[i].charAt(3)), parseInt(moveList.moves[i].charAt(2)));
				var piece:Piece = this.view.board.getPieceByPos(curPos);
				if (piece) {
					this.processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
				}
			}
		};
		
		public function playMove(moveData:MoveInfo) : void {
			Global.vars.app.playMoveSound();
			var curPos:Position = new Position(moveData.getCurrentPosRow(), moveData.getCurrentPosCol());
			var newPos:Position = new Position(moveData.getNewPosRow(), moveData.getNewPosCol());
			var piece:Piece = this.view.board.getPieceByPos(curPos);
			if (piece) {
				this.processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
			}
		}
		
		public function rewindLastMove() : void {
			if (this.moveList.length > 0) {
				var lastMove:String = this.moveList[this.moveList.length - 1];
				if (lastMove != "") {
					var fields:Array = lastMove.split(":");
					var piece:Piece = this..view.board.getPieceByIndex(fields[0], fields[1]);
					var move:String = fields[2];
					var capturePiece:Piece = null;
					if (fields[3] !== "") {
						capturePiece = this.view.board.getPieceByIndex((fields[0] === "Red") ? "Black" : "Red", fields[3]);
					}
					var prevPos:Position = new Position(parseInt(move.charAt(0)), parseInt(move.charAt(1)));
					var curPos:Position = new Position(parseInt(move.charAt(2)), parseInt(move.charAt(3)));
					this.view.board.rewindPieceByPos(piece, curPos, prevPos, capturePiece);
					//this.view.grid.dataProvider.removeItemAt(this.moveList.length - 1);
					this.moveList.splice(this.moveList.length - 1, 1);
					if (this.moveList.length > 1) {
						lastMove = this.moveList[this.moveList.length - 1];
						if (lastMove != "") {
							fields = lastMove.split(":");
							piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
							this.view.board.setFocus(piece);
						}
					}
				}
			}
		}

		public function processWrongMove(error:String) : void {
			rewindLastMove();
			this.view.displayMessage("Server rejected the move. " + error);
			if (this.game) {
				this.game.processEvent("move");
			}
		}

		public function parseMove(moveData:String) : Array {
			var fields:Array = moveData.split(":");
			var piece:Piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
			var move:String = fields[2];
			var capturePiece:Piece = null;
			if (fields[3] !== "") {
				capturePiece = this.view.board.getPieceByIndex((fields[0] === "Red") ? "Black" : "Red", fields[3]);
			}
			return [piece, move, capturePiece];
		}

		public function moveLocalPiece(piece:Piece, curPos:Position, newPos:Position) : void {
			if (tableState == "MOVEREVIEW_STATE" && curMoveIndex != moveList.length) {
				this.view.displayMessage("In review mode");
				piece.moveImage();
				return;
			}
			if (tableState == "MOVEREVIEW_STATE" && stateBeforeReview == "GAMEPLAY_STATE" && this.game.getLocalPlayer().getColor() == piece.getColor()) {
				stopReview();
				tableState = stateBeforeReview;
			}
			if (!this.game.waitingForMyMove()) {
				this.view.displayMessage("Invalid move. Waiting for " + this.game.getOppPlayer().getColor() + " move");
				piece.moveImage();
				return;
			}
			var resultObj:Array = this.game.validateMove(this.view.board, newPos, piece);
			if (resultObj[0] !== 1) {
				this.view.displayMessage("Invalid move. " + resultObj[1]);
				piece.moveImage();
				return;
			}
			this.processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
			if (this.game.isCheckMate(null)) {
				this.view.displayMessage("Invalid move. Check active");
				rewindLastMove();
				return;
			}
			Global.vars.app.playMoveSound();
			if (this.tableState === "GAMEPLAY_STATE") {
				if (this.game) {
					this.game.processEvent("move");
				}
				// Send request to the server
				Global.vars.app.sendMoveRequest(this.game.getLocalPlayer(), piece, curPos, newPos, this.tableId);
			}
		}

		public function movePiece(moveData:MoveInfo) : void {
			Global.vars.app.playMoveSound();
			var curPos:Position = new Position(moveData.getCurrentPosRow(), moveData.getCurrentPosCol());
			var newPos:Position = new Position(moveData.getNewPosRow(), moveData.getNewPosCol());
			var piece:Piece = this.view.board.getPieceByPos(curPos);
			if (piece) {
				this.processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
			}
			if (this.tableState === "GAMEPLAY_STATE" || this.tableState === "MOVEREVIEW_STATE"  ) {
                if (this.game) {
				    if (this.game.isCheckMate(piece)) {
					    this.view.displayMessage("Check by " + piece.getColor() + " " + piece.getType());
				    }
                }
				if (this.game) {
					this.game.processEvent("move");
				}
			}
		}
		public function updateMove(piece:Piece, curPos:Position, newPos:Position) : void {
			var curPiece:Piece = this.view.board.getPieceByPos(newPos);
			var mov:String = "" + piece.getColor() + ":" + piece.getIndex() + ":" + curPos.row + curPos.column + newPos.row + newPos.column + ":" + ((curPiece != null) ? curPiece.getIndex() : "");
			this.moveList[this.moveList.length] = mov;
			var i:int = 0;
			if (this.tableState == "GAMEPLAY_STATE" || this.tableState == "MOVEREVIEW_STATE") {
				if (this.moveList.length == 2) {
					if (this.view !== null) {
						Global.vars.app.showGameMenu();
					}
					this.startTimer();
				}
				else if (moveList.length == 1) {
					this.view.enableReviewButtons(true);
				}
	    	} else if (this.tableState == "OBSERVER_STATE") {
				this.view.enableReviewButtons(true);
				if (this.moveList.length == 2) {
					this.startTimer();
				}
			}
			if (this.moveList.length == 1) {
				Global.vars.app.showTableMenu(false, true);
			}
    		this.view.displayMoveData(mov, this.moveList.length);
		}

		public function processReviewMove(cmd:String) : void {
			if (moveList.length == 0) {
				return;
			}
			var moveIndex:int = 0;
			if (cmd == "start") {
				moveIndex = 0;
			} else if (cmd == "end") {
				moveIndex = moveList.length;
			} else if (cmd == "rewind") {
				moveIndex = curMoveIndex - 1;
				if (moveIndex < 0) {
					return;
				}
			} else {
				moveIndex = curMoveIndex + 1;
				if (moveIndex > moveList.length) {
					return;
				}
			}
			
			if (curMoveIndex == moveIndex ) {
				return;
			}
			//if ((curMoveIndex - 1) >= 0 && (curMoveIndex - 1) < moveList.length) {
			//	this.view.grid.dataProvider.getItemAt(curMoveIndex - 1).selected = false;
			//	this.view.grid.dataProvider.invalidateItemAt(curMoveIndex - 1);
			//}
			applyChangeSet(moveIndex);
		}

		public function applyChangeSet(moveIndex:int) : void {
			var i:int = 0;
			var changeSet:Array = new Array();
			var focusPiece:Piece = null;
			var mov:String = "";
			var fields:Array = null;
			var color:String = "";
			var pieceIndex:String = "";
			var oldRow:int = 0;
			var oldCol:int = 0;
			var newRow:int = 0;
			var newCol:int = 0;
			var capturedIndex:String = "";
			if (moveIndex < curMoveIndex) {
				for (i = curMoveIndex - 1; i >= moveIndex; i--) {
					mov = moveList[i];
					fields = mov.split(":");
					color = fields[0];
					pieceIndex = fields[1];
					oldRow = parseInt(fields[2].charAt(0));
					oldCol = parseInt(fields[2].charAt(1));
					newRow = parseInt(fields[2].charAt(2));
					newCol = parseInt(fields[2].charAt(3));
					capturedIndex = fields[3];
					if (color == "Red") {
						changeSet[changeSet.length] = [color, pieceIndex, oldRow, oldCol, false];
						if (capturedIndex != "") {
							changeSet[changeSet.length] = ["Black", capturedIndex, newRow, newCol, false];
						}
					}
					else {
						changeSet[changeSet.length] = [color, pieceIndex, oldRow, oldCol, false];
						if (capturedIndex != "") {
							changeSet[changeSet.length] = ["Red", capturedIndex, newRow, newCol, false];
						}
					}
					curMoveIndex--;
					if (curMoveIndex < moveList.length && curMoveIndex > 0) {
						mov = moveList[curMoveIndex - 1];
						fields = mov.split(":");
						color = fields[0];
						pieceIndex = fields[1];
						focusPiece = this.view.board.getPieceByIndex(color, pieceIndex);
					}
					else {
						focusPiece = null;
					}
				}
			}
			else {
				for (i = curMoveIndex; i < moveIndex; i++) {
					mov = moveList[i];
					fields = mov.split(":");
					color = fields[0];
					pieceIndex = fields[1];
					oldRow = parseInt(fields[2].charAt(0));
					oldCol = parseInt(fields[2].charAt(1));
					newRow = parseInt(fields[2].charAt(2));
					newCol = parseInt(fields[2].charAt(3));
					capturedIndex = fields[3];
					if (color == "Red") {
						changeSet[changeSet.length] = [color, pieceIndex, newRow, newCol, false];
						if (capturedIndex != "") {
							changeSet[changeSet.length] = ["Black", capturedIndex, newRow, newCol, true];
						}
					}
					else {
						changeSet[changeSet.length] = [color, pieceIndex, newRow, newCol, false];
						if (capturedIndex != "") {
							changeSet[changeSet.length] = ["Red", capturedIndex, newRow, newCol, true];
						}
					}
					curMoveIndex++;
					focusPiece = this.view.board.getPieceByIndex(color, pieceIndex);
				}
			}
//			if ((curMoveIndex - 1) >= 0 && (curMoveIndex - 1) < moveList.length) {
//				this.view.grid.dataProvider.getItemAt(curMoveIndex - 1).selected = true;
//				this.view.grid.dataProvider.invalidateItemAt(curMoveIndex - 1);
//				this.view.grid.scrollToIndex(curMoveIndex - 1);
//			}
			this.view.board.reDraw(changeSet, focusPiece);
		}
		public function stopReview() : void {
//			if ((curMoveIndex - 1) >= 0 && (curMoveIndex - 1) < moveList.length) {
//				this.view.grid.dataProvider.getItemAt(curMoveIndex - 1).selected = false;
//				this.view.grid.dataProvider.invalidateItemAt(curMoveIndex - 1);
//			}
			var moveIndex:int = moveList.length;
			if (curMoveIndex == moveIndex ) {
				return;
			}
//			if ((curMoveIndex - 1) >= 0 && (curMoveIndex - 1) < moveList.length) {
//				this.view.grid.dataProvider.getItemAt(curMoveIndex - 1).selected = false;
//				this.view.grid.dataProvider.invalidateItemAt(curMoveIndex - 1);
//			}
			applyChangeSet(moveIndex);
			curMoveIndex = -1;
		}
		
		public function handleDebugCmd(cmd:String) : void {
			var prefix:String = "/debug ";
			var arg:String = cmd.substring(prefix.length);
			var result:String = "" + arg + ":\n";
			var player:PlayerInfo = null;
			if (arg == "gamestate") {
				if (this.game) {
					result += this.game.state;
				} else {
					result += "";
				}
			} else if (arg == "tablestate") {
				result += this.tableState;
			} else if (arg == "piecemap") {
				result += this.view.board.getPieceMapInfo();
			} else if (arg == "movelist") {
				result += this.getMoveListInfo();
			} else if (arg == "redpieces") {
				result += this.view.board.getRedPiecesInfo();
			} else if (arg == "blackpieces") {
				result += this.view.board.getBlackPiecesInfo();
			} else if (arg == "redplayer") {
				player = this.redPlayer;
				if (player) {
					result += "redplayer: " + player.getPlayerID() + " " + player.getScore();
				}
			}  else if (arg == "blackplayer") {
				player = this.blackPlayer;
				if (player) {
					result += "blackplayer: " + player.getPlayerID() + " " + player.getScore();
				}
			} else if (arg == "all") {
				result += "tablestate: " + this.tableState;
				result += "\n";
				if (this.game) {
					result += "gamestate: " + this.game.state;
					result += "\n";
				} else {
					result += "gamestate: \n";
				}
				result += this.view.board.getPieceMapInfo();
				result += "\n";
				result += this.view.board.getRedPiecesInfo();
				result += "\n";
				result += this.view.board.getRedPiecesInfo();
				result += "\n";
				result += this.view.board.getBlackPiecesInfo();
				result += "\n";
				player = this.redPlayer;
				if (player) {
					result += "redplayer: " + player.getPlayerID() + " " + player.getScore();
					result += "\n";
				} else {
					result += "redplayer: \n";
				}
				player = this.blackPlayer;
				if (player) {
					result += "blackplayer: " + player.getPlayerID() + " " + player.getScore();
					result += "\n";
				} else {
					result += "redplayer: \n";
				}
			}
			trace(cmd + ":\n" + result);
			this.view.displayMessage(result);
		}

		public function joinTable(player:PlayerInfo):void {
			if (player.getColor() === "Black") {
				this.setBlackPlayer(player);
			}
			else if (player.getColor() === "Red") {
				this.setRedPlayer(player);
			}
			else {
				this.setObserver(player);
			}
			this.processTableEvent("JOINTABLE_EVENT", player);
			this.view.displayMessage("" + player.getPlayerID() + " joined");
		}

		public function isPlaying(pid:String):Boolean {
			if ((this.redPlayer && this.redPlayer.getPlayerID() == pid) ||
				(this.blackPlayer && this.blackPlayer.getPlayerID() == pid)) {
				return true;
			}
			return false;
		}
		public function leaveTable(pid:String): void {
			this.processTableEvent("LEAVETABLE_EVENT", pid);
			this.view.displayMessage("" + pid + " left");
		}

		public function processEvent_LEAVE(pid:String) : void {
			if (pid === Global.vars.app.getPlayerID()) {
				this.closeTable();
			}
			else {
				if (this.view !== null) {
					if (this.redPlayer && this.redPlayer.getPlayerID() == pid) {
						this.view.removePlayerData("Red");
						this.stopTimer();
					} else if (this.blackPlayer && this.blackPlayer.getPlayerID() == pid) {
						this.view.removePlayerData("Black");
						this.stopTimer();
					} 
				}
			}
		}

		/**
		 * @TODO: The 'data' parameter 'data' has type = "*" 
		 *         - meaning "untyped" under ActionScript 3.
		 *           This is a not a good practice and should be fixed
		 *           as soon as possbile.
		 */
		public function processTableEvent(type:String, data:*) : void {
			if (this.tableState === "IDLE_STATE") {
				if (type === "JOINTABLE_EVENT") {
					if (data.getPlayerID() === Global.vars.app.getPlayerID()) {
						if (data.getColor() !== "None") {
							this.setSideColors(data.getColor());
							this.createNewTableView();
							this.tableState = "NEWTABLE_STATE";
						}
						else {
							var joinColor:String = this.getJoinColor();
							this.setSideColors(joinColor);
							this.createObserveTableView(joinColor);
							if (joinColor === "") {
								this.tableState = "OBSERVER_STATE";
							}
							else {
								this.tableState = "VIEWTABLE_STATE";
							}
						}
					}
				}
				else if (type === "TABLEINFO_EVENT") {
					if (data.getRedPlayer().getPlayerID() === Global.vars.app.getPlayerID() ||
						data.getBlackPlayer().getPlayerID() === Global.vars.app.getPlayerID()) {
						if (data.getRedPlayer().getPlayerID() === Global.vars.app.getPlayerID()) {
							this.setSideColors("Red");
						}
						else if (data.getBlackPlayer().getPlayerID() === Global.vars.app.getPlayerID()) {
							this.setSideColors("Black");
						}
						this.createNewTableView();
						this.tableState = "NEWTABLE_STATE";
						this.view.displayMessage("" + Global.vars.app.getPlayerID() + " joined");
					}
					else {
						joinColor = this.getJoinColor();
						this.setSideColors(joinColor);
						this.createObserveTableView(joinColor);
						if (joinColor === "") {
							this.tableState = "OBSERVER_STATE";
						}
						else {
							this.tableState = "VIEWTABLE_STATE";
						}
					}
				}
			}
			else if (this.tableState === "NEWTABLE_STATE") {
				if (type == "JOINTABLE_EVENT") {
					if (data.getColor() !== "None") {
						if (this.view !== null) {
							// TODO: Clear palyer data
							this.view.displayPlayerData(data);
							if (this.redPlayer.getPlayerID() === Global.vars.app.playerId) {
								this.view.displayPlayerData(this.redPlayer);
							}
							else {
								this.view.displayPlayerData(this.blackPlayer);
							}
						}
						this.startGame();
						this.tableState = "GAMEPLAY_STATE";
					}
				}
				else if (type === "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
			}
			else if (this.tableState === "VIEWTABLE_STATE") {
				if (type == "JOINTABLE_EVENT") {
					if (this.view !== null) {
						this.displayPlayers();
						Global.vars.app.showTableMenu(true, true);
					}
					if (this.redPlayer.getPlayerID() === Global.vars.app.playerId ||
						this.blackPlayer.getPlayerID() === Global.vars.app.playerId) {
						this.startGame();
						this.tableState = "GAMEPLAY_STATE";
					}
					else {
						this.tableState = "OBSERVER_STATE";
					}
				}
				else if (type === "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
			}
			else if (this.tableState === "OBSERVER_STATE") {
				if (type === "MOVEPIECE_EVENT") {
					var piece:Piece = data[0];
					this.updateMove(piece, data[1], data[2]);
					if (this.view !== null) {
						this.view.board.movePieceByPos(piece, data[2], (this.view === null) ? false : true);
					}
					if (moveList.length > 2) {
						this.resetTimer();
					}
				}
				else if (type === "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type === "RESIGNGAME_EVENT") {
					this.stopTimer();
				}
				else if (type === "MOVEREVIEW_EVENT") {
					this.tableState = "MOVEREVIEW_STATE";
					processReviewMove(data);
				}
				else if (type == "MOVETIMEOUT_EVENT" || type == "GAMETIMEOUT_EVENT") {
                     this.stopTimer();
                }
			}
			else if (this.tableState === "GAMEPLAY_STATE") {
				if (type === "MOVEPIECE_EVENT") {
					piece = data[0];
					this.updateMove(piece, data[1], data[2]);
					if (this.view !== null) {
						this.view.board.movePieceByPos(piece, data[2], (this.view === null) ? false : true);
					}
					if (moveList.length > 2) {
						this.resetTimer();
					}
				}
				else if (type === "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type === "RESIGNGAME_EVENT") {
                    this.stopTimer();
					if (this.view !== null) {
						Global.vars.app.showTableMenu(false, false);
					}
					this.tableState = "ENDGAME_STATE";
				}
				else if (type === "MOVEREVIEW_EVENT") {
					this.tableState = "MOVEREVIEW_STATE";
					processReviewMove(data);
				}
				else if (type == "MOVETIMEOUT_EVENT" || type == "GAMETIMEOUT_EVENT") {
					if (this.view !== null) {
						Global.vars.app.showTableMenu(false, false);
					}
                    this.stopTimer();
					this.tableState = "ENDGAME_STATE";
				}
			}
			else if (this.tableState === "ENDGAME_STATE") {
				if (type === "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type == "MOVEREVIEW_EVENT") {
					this.tableState = "MOVEREVIEW_STATE";
					processReviewMove(data);
				}
			}
			else if (this.tableState === "MOVEREVIEW_STATE") {
				if (type == "MOVEREVIEW_EVENT") {
					processReviewMove(data);
					if (data == "end" || (data == "forward" && curMoveIndex == moveList.length)) {
						stopReview();
						tableState = stateBeforeReview;
					}
				}
				else if (type === "MOVEPIECE_EVENT") {
					piece = data[0];
					if (stateBeforeReview == "GAMEPLAY_STATE") {
						this.updateMove(piece, data[1], data[2]);
						if (this.view !== null) {
							this.view.board.updatePieceMapState(piece, data[1], data[2]);
						}
						if (moveList.length > 2) {
							this.resetTimer();
						}
					}
					else if (stateBeforeReview == "OBSERVER_STATE") {
						if (curMoveIndex == moveList.length) {
							stopReview();
							tableState = stateBeforeReview;
							processTableEvent(type, data);
						}
						else {
							this.updateMove(piece, data[1], data[2]);
							if (this.view !== null) {
								this.view.board.updatePieceMapState(piece, data[1], data[2]);
							}
							if (moveList.length > 2) {
								this.resetTimer();
							}							
						}
					}
				}
				else {
					stopReview();
					tableState = stateBeforeReview;
					processTableEvent(type, data);
				}
			}
		}

		public function getSettings() : Object {
			return this.settings;
		}
		public function getPreferences() : Object {
			return this.curPref;
		}
		public function getMoveList() : Array {
			return this.moveList;
		}
		public function updateSettings(newSettings:Object) : void {
			var bUpdated:Boolean = false;
			var times:String = newSettings["gametime"] + "/" + newSettings["movetime"] + "/" + newSettings["extratime"];
			if (settings["gametime"] != newSettings["gametime"] ||
				settings["movetime"] != newSettings["movetime"] ||
				settings["extratime"] != newSettings["extratime"]) {
				bUpdated = true;
			}
			if (settings["rated"] != newSettings["rated"]) {
				var msg:String = "Game type changed to ";
				msg += (newSettings["rated"] == true)? "Rated" : "Nonrated";
				this.view.displayMessage(msg);
				bUpdated = true;
			}
			settings = newSettings;
			if (bUpdated) {
				Global.vars.app.sendUpdateRequest(this.tableId, times, settings["rated"]);
			}
		}
		public function updatePref(newPref:Object) : void {
			if (curPref["boardcolor"] != newPref["boardcolor"]) {
				this.view.redrawBoard(newPref["boardcolor"], this.curPref["linecolor"], newPref["pieceskinindex"]);
			}
			else if (curPref["pieceskinindex"] != newPref["pieceskinindex"]) {
				this.view.changePieceSkin(newPref["pieceskinindex"]);
			}
			this.curPref = newPref;
		}
	}
}
