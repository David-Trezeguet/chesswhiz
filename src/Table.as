package {
	import flash.display.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import hoxserver.*;
	
	import ui.TableBoard;
	
	public class Table
	{
		public var tableId:String;
		public var view:TableBoard  = null;

		private var _redPlayer:PlayerInfo = null;
		private var _blackPlayer:PlayerInfo = null;
		private var _observers:Array = [];
		private var _game:Game = null;
		private var _isTopSideBlack:Boolean = true;
		private var _tableState:String = "IDLE_STATE";
		private var _stateBeforeReview:String = "IDLE_STATE";
		private var _tableInfo:TableInfo = null;
		private var _redTimes:GameTimers = null;
		private var _blackTimes:GameTimers = null;
		private var _redTimer:Timer = null;
		private var _blackTimer:Timer = null;
		private var _moveList:Array = [];
		private var _curMoveIndex:int = -1;
		private var _settings:Object;
		private var _curPref:Object;

		public function Table(tableId:String, pref:Object)
		{
			this.tableId = tableId;
			_settings = {
					"gametime"  : 1200,
					"movetime"  : 300,
					"extratime" : 20,
					"rated"     : false
				};
			_curPref = pref;
		}

		public function getTopSideColor():String { return _isTopSideBlack ? "Black" : "Red"; }
		public function getGame():Game { return _game; }

		public function getTimers(color:String) : GameTimers {
			return new GameTimers( color == "Red" ? _tableInfo.redtime : _tableInfo.blacktime );			
		}

		private function _getJoinColor():String
		{
			if ( _blackPlayer != null && _redPlayer   == null ) { return "Red";   }
			if ( _redPlayer   != null && _blackPlayer == null ) { return "Black"; }
			return "";
		}

		public function newTable(tableInfo:TableInfo) : void
		{
			if ( tableInfo.redid != "" ) {
				_redPlayer = new PlayerInfo(tableInfo.redid, "Red", tableInfo.redscore);
			}
			if ( tableInfo.blackid != "" ) {
				_blackPlayer = new PlayerInfo(tableInfo.blackid, "Black", tableInfo.blackscore);
			}

			_tableInfo = tableInfo;

			const myPID:String = Global.app.getPlayerID();

			if ( tableInfo.redid == myPID || tableInfo.blackid == myPID )
			{
				_isTopSideBlack = (tableInfo.redid == myPID);
				_createNewTableView();
				Global.app.showTableMenu(true);
				_tableState = "NEWTABLE_STATE";
				this.view.displayMessage(myPID + " joined");
			}
			else {
				const joinColor:String = _getJoinColor();
				_isTopSideBlack = (joinColor != "Black");
				_createObserveTableView(joinColor);
				_tableState = (joinColor == "" ? "OBSERVER_STATE" : "VIEWTABLE_STATE");
			}
		}

		private function _createView () : void
		{
			this.view = new TableBoard();
			Global.app.addBoardToWindow(this.view);  // Realize the UI first!
			this.view.display(this);
		}

		public function reviewMove(cmd:String) : void
		{
			if (_tableState != "MOVEREVIEW_STATE")
			{
				if (_moveList.length > 0 && cmd != "end" && cmd != "forward") {
					_curMoveIndex = _moveList.length;
					_stateBeforeReview = _tableState;
				}
				else {
					return;
				}
			}

			_processReviewMove(cmd);

			if (_tableState != "MOVEREVIEW_STATE")
			{
				_tableState = "MOVEREVIEW_STATE";
			}
			else if (     cmd == "end"
					  || (cmd == "forward" && _curMoveIndex == _moveList.length) )
			{
				_stopReview();
				_tableState = _stateBeforeReview;
			}
		}

		private function _createNewTableView() : void
		{
			if (this.view == null) {
				_createView();
			}
			if (_redPlayer != null && _redPlayer.pid == Global.app.getPlayerID()) {
				this.view.displayPlayerData(_redPlayer);
			}
			else if (_blackPlayer != null && _blackPlayer.pid == Global.app.getPlayerID()) {
				this.view.displayPlayerData(_blackPlayer);
			}
		}
		
		private function _createObserveTableView(joinColor:String) : void
		{
			if (this.view == null) {
				_createView();
			}
			if (_redPlayer != null) {
				this.view.displayPlayerData(_redPlayer);
				this.view.displayMessage(_redPlayer.pid + " joined");
			}
			if (_blackPlayer != null) {
				this.view.displayPlayerData(_blackPlayer);
				this.view.displayMessage(_blackPlayer.pid + " joined");
			}
			trace("joinable color: [" + joinColor + "]");
			Global.app.showObserverMenu(joinColor, this.tableId);
		}

		public function displayChatMessage(pid:String, chatMsg:String) : void {
			this.view.displayChatMessage(pid, chatMsg);
		}

		private function _getMoveListInfo() : String
		{
			var result:String = "movelist: \n";
			var mov:String = "";
			var line:String = "";
			for (var i:int = 0; i < _moveList.length; i++) {
				mov = _moveList[i];
				var fields:Array = mov.split(":");
				line = fields[0] + " " + this.view.board.getPieceByIndex(fields[0], fields[1]).getType()
					+ " " + fields[2].charAt(0) + ","
					+ String.fromCharCode(97 + parseInt(fields[2].charAt(1)))
					+ "->" + fields[2].charAt(2) + "," + String.fromCharCode(97 + parseInt(fields[2].charAt(3))) + "\n";
				result += line;
			}
			return result;
		}

		private function _displayPlayers() : void
		{
			this.view.displayPlayerData(_redPlayer);
			this.view.displayPlayerData(_blackPlayer);
		}

		private function _startGame() : void
		{
			if ( _redPlayer != null && _blackPlayer != null )
			{
				if (_redPlayer.pid == Global.app.getPlayerID()) {
					_game = new Game(this);
					_game.setLocalPlayer(_redPlayer);
					_game.setOppPlayer(_blackPlayer);
					_game.processEvent("start");
				}
				else if (_blackPlayer.pid == Global.app.getPlayerID()) {
					_game = new Game(this);
					_game.setLocalPlayer(_blackPlayer);
					_game.setOppPlayer(_redPlayer);
					_game.processEvent("start");
				}
			}
		}
		
		public function stopGame(reason:String, winner:String) : void {
			if (_game) {
				this.view.board.disablePieceEvents(_game.getLocalPlayer().color);
				_game = null;
			}
			this.view.board.displayStatus("Game Over (" + reason + ")");
			this.view.displayMessage(winner);
			_stopTimer();

			Global.app.showTableMenu(false);
			_tableState = "ENDGAME_STATE";
		}
		
		public function drawGame(pid:String) : void {
			this.view.displayMessage(pid + " offering draw");
		}
		
		public function updateGameTimes(pid:String, times:String) : void
		{
			if (_moveList.length == 0)
			{
				_tableInfo.redtime = times;
				_tableInfo.blacktime = times;
				var timer:GameTimers = new GameTimers(times);
				this.view.updateTimers("Red", timer);
				this.view.updateTimers("Black", timer);
				var fields:Array = times.split("/");
				_settings["gametime"] = fields[0];
				_settings["movetime"] = fields[1];
				_settings["extratime"] = fields[2];
				this.view.displayMessage("timer changed to " + times);
			}
		}
	
		private function _startTimer() : void
		{
			_redTimes = new GameTimers(_tableInfo.redtime);
			_redTimer = new Timer(1000 /* 1 second */, _redTimes.gameTime);
			_redTimer.addEventListener(TimerEvent.TIMER, _timerHandler);

			_blackTimes = new GameTimers(_tableInfo.blacktime);
			_blackTimer = new Timer(1000 /* 1 second */, _blackTimes.gameTime);
			_blackTimer.addEventListener(TimerEvent.TIMER, _timerHandler);

			if (_getMoveColor() == "Red") { _redTimer.start();   }
			else                          { _blackTimer.start(); }
		}

		private function _getMoveColor() : String
		{
			var color:String = "";

			if (_game != null)
			{
				color = ( _game.waitingForMyMove() ? _game.getLocalPlayer().color
												   : _game.getOppPlayer().color );
			}
			else if (_moveList.length > 0)
			{
				var lastMove:String = _moveList[_moveList.length - 1];
				if (lastMove != "") {
					var fields:Array = lastMove.split(":");
					color = (fields[0] == "Red" ? "Black" : "Red");
				}
			}

			return color;
		}

		private function _stopTimer() : void
		{
			if (_redTimer) {
				_redTimer.stop();
			}
			if (_blackTimer) {
				_blackTimer.stop();
			}
		}

		/**
		 * This function is called after each Move is made to reset the MOVE-time.
		 */
		private function _resetMoveTimer(color:String) : void
		{
			if (color == "Red") {
				_redTimes.resetMoveTime();
				_redTimer.stop();
				_blackTimer.start();
			}
			else {
				_blackTimes.resetMoveTime();
				_blackTimer.stop();
				_redTimer.start();
			}
		}

		private function _timerHandler(event:Event) : void
		{
			const color:String = _getMoveColor();
			if (color == "Red") {
				if (_redTimes) {
					_redTimes.gameTime--;
					_redTimes.moveTime--;
					if (_redTimes.gameTime == 0 || _redTimes.moveTime == 0) {
						_handleTimeout(color);
                        return;
					}
					this.view.updateTimers("Red", _redTimes);
				}
			}
			else if (color == "Black") {
				if (_blackTimes) {
					_blackTimes.gameTime--;
					_blackTimes.moveTime--;
					if (_blackTimes.gameTime == 0 ||_blackTimes.moveTime == 0) {
						_handleTimeout(color);
                        return;
					}
					this.view.updateTimers("Black", _blackTimes);
				}
			}
		}

		private function _handleTimeout(color:String) : void
		{
			this.view.displayMessage(color + " timeout");
			Global.app.showTableMenu(false);
            _stopTimer();
			_tableState = "ENDGAME_STATE";
		}

		public function playMoveList(moves:Array) : void
		{
			for (var i:int = 0; i < moves.length; i++) {
				var curPos:Position = new Position( parseInt(moves[i].charAt(1)),
													parseInt(moves[i].charAt(0)) );
				var newPos:Position = new Position( parseInt(moves[i].charAt(3)),
													parseInt(moves[i].charAt(2)) );
				var piece:Piece = this.view.board.getPieceByPos(curPos);
				if (piece) {
					_processMoveEvent([piece, curPos, newPos]);
				}
			}
		}
		
		private function _rewindLastMove() : void
		{
			if (_moveList.length == 0) {
				return;
			}

			var lastMove:String = _moveList.pop();
			var fields:Array = lastMove.split(":");
			var piece:Piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
			var move:String = fields[2];
			var capturePiece:Piece = null;
			if (fields[3] != "") {
				capturePiece = this.view.board.getPieceByIndex((fields[0] == "Red" ? "Black" : "Red"), fields[3]);
			}
			var prevPos:Position = new Position(parseInt(move.charAt(0)), parseInt(move.charAt(1)));
			var curPos:Position = new Position(parseInt(move.charAt(2)), parseInt(move.charAt(3)));
			this.view.board.rewindPieceByPos(piece, curPos, prevPos, capturePiece);

			// Restore the focus on the previous Move, if any.
			if (_moveList.length > 1) {
				lastMove = _moveList[_moveList.length - 1];
				if (lastMove != "") {
					fields = lastMove.split(":");
					piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
					this.view.board.setFocusOnPiece(piece);
				}
			}
		}

		public function processWrongMove(error:String) : void
		{
			_rewindLastMove();
			this.view.displayMessage("Server rejected the move: " + error);
			if (_game) {
				_game.processEvent("move");
			}
		}

		public function parseMove(moveData:String) : Array
		{
			var fields:Array = moveData.split(":");
			var piece:Piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
			var move:String = fields[2];
			var capturePiece:Piece = null;
			if (fields[3] != "") {
				capturePiece = this.view.board.getPieceByIndex((fields[0] == "Red" ? "Black" : "Red"), fields[3]);
			}
			return [piece, move, capturePiece];
		}

		/**
		 * Callback function when a local Piece is moved by human. 
		 */
		public function onLocalPieceMoved(piece:Piece, curPos:Position, newPos:Position) : void
		{
			if ( _tableState == "MOVEREVIEW_STATE" && _curMoveIndex != _moveList.length ) {
				trace("Piece cannot be moved: In review mode");
				piece.moveImage();
				return;
			}

			if ( ! _game.waitingForMyMove() ) {
				trace("Piece cannot be moved: Waiting for move from the opponent.");
				piece.moveImage();
				return;
			}

			var validationResult:Array = _game.validateMove(this.view.board, newPos, piece);
			if ( validationResult[0] != 1 ) {
				trace("Piece cannot be moved: Invalid move: [" + validationResult[1] + "]");
				piece.moveImage();
				return;
			}

			// Apply the Move and then check if the 'own' King is in danger.
			// If yes, then undo the Move.
			_processMoveEvent([piece, curPos, newPos]);
			if ( _game.isCheckMate(null) ) {
				trace("Piece cannot be moved: 'Own' King is in danger.");
				_rewindLastMove();
				return;
			}
			
			// Upon reaching here, the Move has been determined to be valid.
			Global.app.playMoveSound();
			if ( _tableState == "GAMEPLAY_STATE" ) {
				if (_game) {
					_game.processEvent("move");
				}
				Global.app.sendMoveRequest(_game.getLocalPlayer(), piece, curPos, newPos, this.tableId);
			}
		}

		public function movePiece(curPos:Position, newPos:Position) : void
		{
			Global.app.playMoveSound();
			var piece:Piece = this.view.board.getPieceByPos(curPos);
			if (piece) {
				_processMoveEvent([piece, curPos, newPos]);
			}
			if (_tableState == "GAMEPLAY_STATE" || _tableState == "MOVEREVIEW_STATE"  ) {
                if (_game) {
				    if (_game.isCheckMate(piece)) {
					    this.view.displayMessage("Check by " + piece.getColor() + " " + piece.getType());
				    }
				    _game.processEvent("move");
                }
			}
		}

		private function _updateMove(piece:Piece, curPos:Position, newPos:Position) : void
		{
			var curPiece:Piece = this.view.board.getPieceByPos(newPos);
			const mov:String = "" + piece.getColor() + ":" + piece.getIndex()
				+ ":" + curPos.row + curPos.column + newPos.row + newPos.column
				+ ":" + ((curPiece != null) ? curPiece.getIndex() : "");
			_moveList[_moveList.length] = mov;
			if (_tableState == "GAMEPLAY_STATE" || _tableState == "MOVEREVIEW_STATE") {
				if (_moveList.length == 2) {
					if (this.view != null) {
						Global.app.showGameMenu();
					}
					_startTimer();
				}
				else if (_moveList.length == 1) {
					this.view.enableReviewButtons(true);
				}
	    	} else if (_tableState == "OBSERVER_STATE") {
				this.view.enableReviewButtons(true);
				if (_moveList.length == 2) {
					_startTimer();
				}
			}
			if (_moveList.length == 1) {
				Global.app.showTableMenu(false);
			}
		}

		private function _processReviewMove(cmd:String) : void
		{
			if (_moveList.length == 0) {
				return;
			}

			var moveIndex:int = 0;

			if      (cmd == "start")  { moveIndex = 0;                 }
			else if (cmd == "end")    { moveIndex = _moveList.length;  }
			else if (cmd == "rewind") { moveIndex = _curMoveIndex - 1; }
			else    /* forward */     { moveIndex = _curMoveIndex + 1; }

			if (    moveIndex < 0 || moveIndex > _moveList.length 
			     || moveIndex == _curMoveIndex )
			{
				return;
			}

			_applyChangeSet(moveIndex);
		}

		private function _applyChangeSet(moveIndex:int) : void
		{
			var i:int = 0;
			var changeSet:Array = [];
			var focusPiece:Piece = null;
			var fields:Array;
			var color:String;
			var pieceIndex:String;
			var oldRow:int;
			var oldCol:int;
			var newRow:int;
			var newCol:int;
			var capturedIndex:String;

			if (moveIndex < _curMoveIndex) {
				for (i = _curMoveIndex - 1; i >= moveIndex; i--) {
					fields = _moveList[i].split(":");
					color = fields[0];
					pieceIndex = fields[1];
					oldRow = parseInt(fields[2].charAt(0));
					oldCol = parseInt(fields[2].charAt(1));
					newRow = parseInt(fields[2].charAt(2));
					newCol = parseInt(fields[2].charAt(3));
					capturedIndex = fields[3];
					changeSet.push( [color, pieceIndex, oldRow, oldCol, false] );
					if (capturedIndex != "") {
						changeSet.push( [ (color == "Red" ? "Black" : "Red"),
						                  capturedIndex, newRow, newCol, false ] );
					}
					_curMoveIndex--;
					if (_curMoveIndex < _moveList.length && _curMoveIndex > 0) {
						fields = _moveList[_curMoveIndex - 1].split(":");
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
				for (i = _curMoveIndex; i < moveIndex; i++) {
					fields = _moveList[i].split(":");
					color = fields[0];
					pieceIndex = fields[1];
					oldRow = parseInt(fields[2].charAt(0));
					oldCol = parseInt(fields[2].charAt(1));
					newRow = parseInt(fields[2].charAt(2));
					newCol = parseInt(fields[2].charAt(3));
					capturedIndex = fields[3];
					changeSet.push( [color, pieceIndex, newRow, newCol, false] );
					if (capturedIndex != "") {
						changeSet.push( [ (color == "Red" ? "Black" : "Red"),
						                  capturedIndex, newRow, newCol, true ] );
					}
					_curMoveIndex++;
					focusPiece = this.view.board.getPieceByIndex(color, pieceIndex);
				}
			}
			this.view.board.reDraw(changeSet, focusPiece);
		}

		private function _stopReview() : void
		{
			var moveIndex:int = _moveList.length;
			if (_curMoveIndex == moveIndex ) {
				return;
			}
			_applyChangeSet(moveIndex);
			_curMoveIndex = -1;
		}

		public function handleDebugCmd(cmd:String) : void
		{
			var prefix:String = "/debug ";
			var arg:String = cmd.substring(prefix.length);
			var result:String = "" + arg + ":\n";
			var player:PlayerInfo = null;
			if (arg == "gamestate") {
				if (_game) {
					result += _game.getGameState();
				} else {
					result += "";
				}
			} else if (arg == "tablestate") {
				result += _tableState;
			} else if (arg == "piecemap") {
				result += this.view.board.getPieceMapInfo();
			} else if (arg == "movelist") {
				result += _getMoveListInfo();
			} else if (arg == "redpieces") {
				result += this.view.board.getRedPiecesInfo();
			} else if (arg == "blackpieces") {
				result += this.view.board.getBlackPiecesInfo();
			} else if (arg == "redplayer") {
				player = _redPlayer;
				if (player) {
					result += "redplayer: " + player.pid + " " + player.score;
				}
			}  else if (arg == "blackplayer") {
				player = _blackPlayer;
				if (player) {
					result += "blackplayer: " + player.pid + " " + player.score;
				}
			} else if (arg == "all") {
				result += "tablestate: " + _tableState;
				result += "\n";
				if (_game) {
					result += "gamestate: " + _game.getGameState();
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
				player = _redPlayer;
				if (player) {
					result += "redplayer: " + player.pid + " " + player.score;
					result += "\n";
				} else {
					result += "redplayer: \n";
				}
				player = _blackPlayer;
				if (player) {
					result += "blackplayer: " + player.pid + " " + player.score;
					result += "\n";
				} else {
					result += "redplayer: \n";
				}
			}
			trace(cmd + ":\n" + result);
			this.view.displayMessage(result);
		}

		public function joinTable(player:PlayerInfo) : void
		{
			if      (player.color == "Red")   { _redPlayer   = player;   }
			else if (player.color == "Black") { _blackPlayer = player;   }
			else                              { _observers.push(player); }

			if (_tableState == "NEWTABLE_STATE")
			{
				if (player.color != "None") {
					this.view.displayPlayerData(player);
					_startGame();
					_tableState = "GAMEPLAY_STATE";
				}
			}
			else if (_tableState == "VIEWTABLE_STATE")
			{
				this.view.displayPlayerData(player);
				Global.app.showTableMenu(true);
				if (   _redPlayer.pid   == Global.app.getPlayerID()
					|| _blackPlayer.pid == Global.app.getPlayerID() )
				{
					_startGame();
					_tableState = "GAMEPLAY_STATE";
				}
				else {
					_tableState = "OBSERVER_STATE";
				}
			}

			this.view.displayMessage(player.pid + " joined");
		}

		public function leaveTable(pid:String) : void
		{
			if (pid == Global.app.getPlayerID()) {
				_stopTimer();
			}
			else if (this.view != null)
			{
				if (_redPlayer && _redPlayer.pid == pid) {
					this.view.removePlayerData("Red");
					_stopTimer();
				} else if (_blackPlayer && _blackPlayer.pid == pid) {
					this.view.removePlayerData("Black");
					_stopTimer();
				} 
			}

			this.view.displayMessage(pid + " left");
		}

		private function _processMoveEvent(data:Array) : void
		{
			if (   _tableState == "OBSERVER_STATE" || _tableState == "GAMEPLAY_STATE"
			    || _tableState == "MOVEREVIEW_STATE" )
			{
				var piece:Piece = data[0];
				_updateMove(piece, data[1], data[2]);
				if (_tableState == "MOVEREVIEW_STATE") {
					this.view.board.updatePieceMapState(piece, data[1], data[2]);
				} else {
					this.view.board.movePieceByPos(piece, data[2]);
				}
				if (_moveList.length > 2) {
					_resetMoveTimer( piece.getColor() );
				}
			}
		}

		public function getSettings() : Object { return _settings; }
		public function getPreferences() : Object { return _curPref; }
		public function getMoveList() : Array { return _moveList; }

		public function updateSettings(newSettings:Object) : void
		{
			var bUpdated:Boolean = false;
			var times:String = newSettings["gametime"] + "/" + newSettings["movetime"] + "/" + newSettings["extratime"];
			if (_settings["gametime"] != newSettings["gametime"] ||
				_settings["movetime"] != newSettings["movetime"] ||
				_settings["extratime"] != newSettings["extratime"]) {
				bUpdated = true;
			}
			if (_settings["rated"] != newSettings["rated"]) {
				var msg:String = "Game type changed to ";
				msg += (newSettings["rated"] == true)? "Rated" : "Nonrated";
				this.view.displayMessage(msg);
				bUpdated = true;
			}
			_settings = newSettings;
			if (bUpdated) {
				Global.app.doUpdateTableSettings(this.tableId, times, _settings["rated"]);
			}
		}

		public function updatePreferences(newPref:Object) : void
		{
			if (_curPref["boardcolor"] != newPref["boardcolor"]) {
				this.view.redrawBoard(newPref["boardcolor"], _curPref["linecolor"]);
			}
			if (_curPref["pieceskinindex"] != newPref["pieceskinindex"]) {
				this.view.changePieceSkin(newPref["pieceskinindex"]);
			}
			_curPref = newPref;
		}
	}
}
