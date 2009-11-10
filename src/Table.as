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

		private var _isTopSideBlack:Boolean = true; // Normal view of Table.

		private var _localPlayerColor:String = "None";

		private var _inReviewMode:Boolean = false;

		private var _redTimes:GameTimers   = new GameTimers();
		private var _blackTimes:GameTimers = new GameTimers();
		private var _redClock:Timer        = new Timer(1000 /* 1s interval */);
		private var _blackClock:Timer      = new Timer(1000 /* 1s interval */);

		private var _moveList:Array = [];
		private var _curMoveIndex:int = -1;
		private var _settings:Object;
		private var _curPref:Object;

		public function Table(tableId:String, pref:Object)
		{
			this.tableId = tableId;

			_redClock.addEventListener(TimerEvent.TIMER, _timerHandler);
			_blackClock.addEventListener(TimerEvent.TIMER, _timerHandler);

			_settings = {
					"gametime"  : 1200,
					"movetime"  : 300,
					"extratime" : 20,
					"rated"     : false
				};
			_curPref = pref;
		}

		public function getTopSideColor():String { return _isTopSideBlack ? "Black" : "Red"; }

		public function getTimers(color:String) : GameTimers
		{
			return ( color == "Red" ? _redTimes : _blackTimes );
		}

		/**
		 * Determine which Color/Side is open.
		 */
		private function _getOpenColor():String
		{
			if ( _redPlayer   == null && _blackPlayer ) { return "Red";   }
			if ( _blackPlayer == null && _redPlayer   ) { return "Black"; }
			return "None";
		}

		public function newTable(tableInfo:TableInfo) : void
		{
			if ( tableInfo.redid != "" ) {
				_redPlayer = new PlayerInfo(tableInfo.redid, "Red", tableInfo.redscore);
			}
			if ( tableInfo.blackid != "" ) {
				_blackPlayer = new PlayerInfo(tableInfo.blackid, "Black", tableInfo.blackscore);
			}

			_redTimes.initWithTimes(tableInfo.initialtime, tableInfo.redtime);
			_blackTimes.initWithTimes(tableInfo.initialtime, tableInfo.blacktime);

			const myPID:String = Global.app.getPlayerID();

			if ( tableInfo.redid == myPID || tableInfo.blackid == myPID )
			{
				_isTopSideBlack = (tableInfo.redid == myPID);
				_createTableView();
				Global.app.showNewTableMenu();
			}
			else {
				const openColor:String = _getOpenColor();
				_isTopSideBlack = (openColor != "Black");
				_createTableView();
				Global.app.showOpenTableMenu(openColor, this.tableId);
			}
		}

		public function reviewMove(cmd:String) : void
		{
			if ( !_inReviewMode )
			{
				if (_moveList.length > 0 && cmd != "end" && cmd != "forward") {
					_curMoveIndex = _moveList.length;
				}
				else {
					return;
				}
			}

			_processReviewMove(cmd);

			if ( !_inReviewMode )
			{
				_inReviewMode = true;
			}
			else if (     cmd == "end"
					  || (cmd == "forward" && _curMoveIndex == _moveList.length) )
			{
				_stopReview();
				_inReviewMode = false;
			}
		}
		
		private function _createTableView() : void
		{
			if (this.view == null)
			{
				this.view = new TableBoard();
				Global.app.addBoardToWindow(this.view); // Realize the UI first!
				this.view.display(this, _curPref["boardcolor"], _curPref["linecolor"], _curPref["pieceskinindex"]);
			}

			if (_redPlayer) {
				this.view.displayPlayerData(_redPlayer);
				this.view.displayMessage(_redPlayer.pid + " joined");
			}

			if (_blackPlayer) {
				this.view.displayPlayerData(_blackPlayer);
				this.view.displayMessage(_blackPlayer.pid + " joined");
			}
		}

		public function displayChatMessage(pid:String, chatMsg:String) : void {
			this.view.displayChatMessage(pid, chatMsg);
		}

		private function _startGame() : void
		{
			if (_redPlayer.pid == Global.app.getPlayerID())
			{
				_localPlayerColor = "Red";
				this.view.board.enablePieceEvents("Red");
			}
			else if (_blackPlayer.pid == Global.app.getPlayerID())
			{
				_localPlayerColor = "Black";
				this.view.board.enablePieceEvents("Black");
			}
		}
		
		public function stopGame(reason:String, winner:String) : void {
			this.view.board.disablePieceEvents(_localPlayerColor);
			_localPlayerColor = "None";
			
			this.view.board.displayStatus("Game Over (" + reason + ")");
			_stopTimer();

			Global.app.showObserverMenu();
		}
		
		public function drawGame(pid:String) : void {
			this.view.displayMessage(pid + " offering draw");
		}
		
		public function updateGameTimes(times:String) : void
		{
			if (_moveList.length == 0)
			{
				_redTimes.initWithTimes(times, times);
				_blackTimes.initWithTimes(times, times);

				var timer:GameTimers = new GameTimers(times);
				this.view.updateTimers("Red", timer);
				this.view.updateTimers("Black", timer);
				const fields:Array = times.split("/");
				_settings["gametime"]  = fields[0];
				_settings["movetime"]  = fields[1];
				_settings["extratime"] = fields[2];
				this.view.displayMessage("Timer: " + times);
			}
		}
	
		private function _startTimer() : void
		{
			_redClock.repeatCount = _redTimes.gameTime + _redTimes.extraTime;
			_blackClock.repeatCount = _blackTimes.gameTime + _blackTimes.extraTime;

			if (this.view.board.nextColor() == "Red") { _redClock.start();   }
			else                                      { _blackClock.start(); }
		}

		private function _stopTimer() : void
		{
			_redClock.stop();
			_blackClock.stop();
		}

		/**
		 * This function is called after each Move is made to reset the MOVE-time.
		 */
		private function _resetMoveTimer(lastMoveColor:String) : void
		{
			if (lastMoveColor == "Red")
			{
				_redClock.stop();
				_blackTimes.resetMoveTime();
				_blackClock.start();
			}
			else
			{
				_blackClock.stop();
				_redTimes.resetMoveTime();
				_redClock.start();
			}
		}

		private function _timerHandler(event:Event) : void
		{
			var bTimedOut:Boolean = false;
			const nextColor:String = this.view.board.nextColor();

			if (nextColor == "Red")
			{
				_redTimes.decrementTime();
				bTimedOut = _redTimes.isTimedout();
				this.view.updateTimers("Red", _redTimes);
			}
			else if (nextColor == "Black")
			{
				_blackTimes.decrementTime();
				bTimedOut = _blackTimes.isTimedout();
				this.view.updateTimers("Black", _blackTimes);
			}

			if ( bTimedOut )
			{
				this.view.displayMessage(nextColor + " timedout");
				Global.app.showObserverMenu();
	            _stopTimer();
			}
		}

		public function playMoveList(moves:Array) : void
		{
			for (var i:int = 0; i < moves.length; i++)
			{
				var curPos:Position = new Position( parseInt(moves[i].charAt(1)),
													parseInt(moves[i].charAt(0)) );
				var newPos:Position = new Position( parseInt(moves[i].charAt(3)),
													parseInt(moves[i].charAt(2)) );
				var piece:Piece = this.view.board.getPieceByPos(curPos);
				if (piece) {
					_processMoveEvent(piece, curPos, newPos);
		            this.view.board.onNewMove();
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
			this.view.board.onNewMove();
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
			if ( _inReviewMode ) {
				trace("Piece cannot be moved: In review mode");
				piece.moveImage();
				return;
			}

			if ( _localPlayerColor != this.view.board.nextColor() ) {
				trace("Piece cannot be moved: It is not your turn.");
				piece.moveImage();
				return;
			}

			if ( ! this.view.board.validateMove(piece, newPos) ) {
				trace("Piece cannot be moved: Invalid move.");
				piece.moveImage();
				return;
			}

			// Apply the Move and then check if the 'own' King is in danger.
			// If yes, then undo the Move.
			_processMoveEvent(piece, curPos, newPos);
			if ( this.view.board.isMyKingBeingChecked(piece.getColor()) ) {
				trace("Piece cannot be moved: 'Own' King is in danger.");
				_rewindLastMove();
				return;
			}
			
			// Upon reaching here, the Move has been determined to be valid.
			Global.app.playMoveSound();
			this.view.board.onNewMove();
			Global.app.doSendMove(piece, curPos, newPos, this.tableId);
		}

		/**
		 * Function to handle a Move coming from the remote server. 
		 */
		public function handleRemoteMove(curPos:Position, newPos:Position) : void
		{
			const piece:Piece = this.view.board.getPieceByPos(curPos);
			if (piece)
			{
				Global.app.playMoveSound();
				_processMoveEvent(piece, curPos, newPos);
	            this.view.board.onNewMove();
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
			const moveIndex:int = _moveList.length;
			if (_curMoveIndex == moveIndex ) {
				return;
			}
			_applyChangeSet(moveIndex);
			_curMoveIndex = -1;
		}

		public function joinTable(player:PlayerInfo) : void
		{
			if      (player.color == "Red")   { _redPlayer   = player;   }
			else if (player.color == "Black") { _blackPlayer = player;   }
			else    /* "None" */              { _observers.push(player); }

			if (player.color == "Red" || player.color == "Black") {
				this.view.displayPlayerData(player);
			}
			this.view.displayMessage(player.pid + " joined");

			if (    _localPlayerColor == "None"
				&& ( _redPlayer && _blackPlayer )
				&& (     _redPlayer.pid   == Global.app.getPlayerID()
				 	  || _blackPlayer.pid == Global.app.getPlayerID() ) )
			{
				_startGame();
				Global.app.showNewTableMenu();
			}
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

		/**
		 * Function to perform common tasks on each new Move.
		 */
		private function _processMoveEvent(piece:Piece, curPos:Position, newPos:Position) : void
		{
			// Store the new Move in the Move-List.
			const capturedPiece:Piece = this.view.board.getPieceByPos(newPos);
			const move:String = piece.getColor() + ":" + piece.getIndex()
				+ ":" + curPos.row + curPos.column + newPos.row + newPos.column
				+ ":" + (capturedPiece ? capturedPiece.getIndex() : "");

			const nMoves:uint = _moveList.push(move);

			// Update the Piece Map.
			if ( _inReviewMode ) {
				this.view.board.updatePieceMapState(piece, curPos, newPos);
			} else {
				this.view.board.movePieceByPos(piece, newPos);
			}

			// Update the menu.
			if (nMoves == 1)
			{
				this.view.enableReviewButtons(true);
				Global.app.showObserverMenu();
			}
			else if (nMoves == 2)
			{
				_startTimer();
				if (    ( _redPlayer && _blackPlayer )
					 && (    _redPlayer.pid   == Global.app.getPlayerID()
				 	      || _blackPlayer.pid == Global.app.getPlayerID() ) )
				{
					Global.app.showInGameMenu();
				}
			}

			// Reset Move-time.
			if (nMoves > 2)
			{
				_resetMoveTimer( piece.getColor() );
			}
		}

		public function getSettings() : Object { return _settings; }

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
