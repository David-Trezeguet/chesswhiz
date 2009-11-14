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

		private var _view:TableBoard  = new TableBoard();

		private var _redPlayer:PlayerInfo   = null;
		private var _blackPlayer:PlayerInfo = null;

		private var _redTimes:GameTimers   = new GameTimers();
		private var _blackTimes:GameTimers = new GameTimers();
		private var _redClock:Timer        = new Timer(1000 /* 1s interval */);
		private var _blackClock:Timer      = new Timer(1000 /* 1s interval */);

		private var _inReviewMode:Boolean = false;
		private var _moveList:Array = [];
		private var _curMoveIndex:int = -1;

		private var _settings:Object;
		private var _curPref:Object;

		public function Table(tableId:String, preferences:Object, settings:Object)
		{
			this.tableId = tableId;

			_redClock.addEventListener(TimerEvent.TIMER, _timerHandler);
			_blackClock.addEventListener(TimerEvent.TIMER, _timerHandler);

			_settings = settings;
			_curPref  = preferences;
		}

		public function getTimers(color:String) : GameTimers
		{
			return ( color == "Red" ? _redTimes : _blackTimes );
		}

		/**
		 * This function is called when the server returns the Table-Info as
		 * the response to one of the two requests sent by the local Player:
		 *     (1) Open a new Table.
		 *     (2) Join an existing Table.
		 */
		public function newTable(tableInfo:Object) : void
		{
			_redTimes.initWithTimes(tableInfo.initialtime, tableInfo.redtime);
			_blackTimes.initWithTimes(tableInfo.initialtime, tableInfo.blacktime);

			Global.app.addBoardToWindow(_view); // Realize the UI first!
			_view.display(this, _curPref["boardcolor"], _curPref["linecolor"], _curPref["pieceskin"]);
			
			if ( tableInfo.redid != "" )
			{
				_redPlayer = new PlayerInfo(tableInfo.redid, "Red", tableInfo.redscore);
				_view.onPlayerJoined(_redPlayer);
				if ( Global.player.pid == tableInfo.redid ) {
					Global.player.color = "Red";
				}
			}

			if ( tableInfo.blackid != "" )
			{
				_blackPlayer = new PlayerInfo(tableInfo.blackid, "Black", tableInfo.blackscore);
				_view.onPlayerJoined(_blackPlayer);
				if ( Global.player.pid == tableInfo.blackid ) {
					Global.player.color = "Black";
				}
			}

			if ( Global.player.color == "None" )
			{
				_view.onPlayerJoined( Global.player );
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

		public function displayChatMessage(pid:String, chatMsg:String) : void {
			_view.displayChatMessage(pid, chatMsg);
		}
		
		public function stopGame(reason:String, winner:String) : void
		{
			if ( Global.player.color != "None" )
			{
				_view.board.disablePieceEvents(Global.player.color);
				Global.player.color = "None";
			}
			
			_view.board.displayStatus("Game Over (" + reason + ")");
			_stopTimers();

			Global.app.showObserverMenu();
		}
		
		public function drawGame(pid:String) : void
		{
			_view.displayMessage(pid + " offering draw");
		}
		
		public function updateTableSettings(itimes:String, bRated:Boolean) : void
		{
			if (_moveList.length == 0)
			{
				_redTimes.initWithTimes(itimes, itimes);
				_blackTimes.initWithTimes(itimes, itimes);

				var timer:GameTimers = new GameTimers(itimes);
				_view.updateTimers("Red", timer);
				_view.updateTimers("Black", timer);
				const fields:Array = itimes.split("/");
				_settings["gametime"]  = fields[0];
				_settings["movetime"]  = fields[1];
				_settings["extratime"] = fields[2];
				_view.displayMessage("Timer: " + itimes);
				
				_settings["rated"] = bRated;
				_view.displayMessage("Type: " + (bRated ? "Rated" : "Nonrated"));
			}
		}

		public function resetTable() : void
		{
			_stopTimers();
			_redTimes.resetAll();
			_blackTimes.resetAll();

			_inReviewMode = false;
			_moveList = [];
			_curMoveIndex = -1;

			_view.onReset();

			/* Get the Table in the "ready" state if there are enough players. */

			if ( _redPlayer && _redPlayer.pid == Global.player.pid ) {
				Global.player.color = "Red";
			} else if ( _blackPlayer && _blackPlayer.pid == Global.player.pid ) {
				Global.player.color = "Black";
			} else {
				Global.player.color = "None";
			}

			if (   Global.player.color != "None" 
				&& ( _redPlayer && _blackPlayer ) )
			{
				_view.board.enablePieceEvents(Global.player.color);
			}
		}

		private function _startTimer() : void
		{
			if (_view.board.nextColor() == "Red") { _redClock.start();   }
			else                                  { _blackClock.start(); }
		}

		private function _stopTimers() : void
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
			// NOTE: Let the server determine and handle the "timedout" event!

			const nextColor:String = _view.board.nextColor();

			if (nextColor == "Red")
			{
				_redTimes.decrementTime();
				_view.updateTimers("Red", _redTimes);
			}
			else if (nextColor == "Black")
			{
				_blackTimes.decrementTime();
				_view.updateTimers("Black", _blackTimes);
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
				var piece:Piece = _view.board.getPieceByPos(curPos);
				if (piece) {
					_processMoveEvent(piece, curPos, newPos);
		            _view.board.onNewMove();
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
			var piece:Piece = _view.board.getPieceByIndex(fields[0], fields[1]);
			var move:String = fields[2];
			var capturePiece:Piece = null;
			if (fields[3] != "") {
				capturePiece = _view.board.getPieceByIndex((fields[0] == "Red" ? "Black" : "Red"), fields[3]);
			}
			var prevPos:Position = new Position(parseInt(move.charAt(0)), parseInt(move.charAt(1)));
			var curPos:Position = new Position(parseInt(move.charAt(2)), parseInt(move.charAt(3)));
			_view.board.rewindPieceByPos(piece, curPos, prevPos, capturePiece);

			// Restore the focus on the previous Move, if any.
			if (_moveList.length > 1) {
				lastMove = _moveList[_moveList.length - 1];
				if (lastMove != "") {
					fields = lastMove.split(":");
					piece = _view.board.getPieceByIndex(fields[0], fields[1]);
					_view.board.setFocusOnPiece(piece);
				}
			}
		}

		public function processWrongMove(error:String) : void
		{
			_rewindLastMove();
			_view.displayMessage("Server rejected the move: " + error);
			_view.board.onNewMove();
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

			if ( Global.player.color != _view.board.nextColor() ) {
				trace("Piece cannot be moved: It is not your turn.");
				piece.moveImage();
				return;
			}

			if ( ! _view.board.validateMove(piece, newPos) ) {
				trace("Piece cannot be moved: Invalid move.");
				piece.moveImage();
				return;
			}

			// Apply the Move and then check if the 'own' King is in danger.
			// If yes, then undo the Move.
			_processMoveEvent(piece, curPos, newPos);
			if ( _view.board.isMyKingBeingChecked(piece.getColor()) ) {
				trace("Piece cannot be moved: 'Own' King is in danger.");
				_rewindLastMove();
				return;
			}
			
			// Upon reaching here, the Move has been determined to be valid.
			Global.app.playMoveSound();
			_view.board.onNewMove();
			Global.app.doSendMove(piece, curPos, newPos, this.tableId);
		}

		/**
		 * Function to handle a Move coming from the remote server. 
		 */
		public function handleRemoteMove(curPos:Position, newPos:Position) : void
		{
			const piece:Piece = _view.board.getPieceByPos(curPos);
			if (piece)
			{
				Global.app.playMoveSound();
				_processMoveEvent(piece, curPos, newPos);
	            _view.board.onNewMove();
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
						focusPiece = _view.board.getPieceByIndex(color, pieceIndex);
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
					focusPiece = _view.board.getPieceByIndex(color, pieceIndex);
				}
			}
			_view.board.reDraw(changeSet, focusPiece);
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

		/**
		 * Handler for a remote event in which a Player just joined the Table
		 * or changed his/her color (e.g., the playing role).
		 */
		public function joinTable(player:PlayerInfo) : void
		{
			if      (player.color == "Red")   { _redPlayer   = player; }
			else if (player.color == "Black") { _blackPlayer = player; }
			else    /* "None" */
			{
				if ( _redPlayer && _redPlayer.pid == player.pid ) {
					_redPlayer = null;
				}
				else if ( _blackPlayer && _blackPlayer.pid == player.pid ) {
					_blackPlayer = null;
				}
			}

			var bMyColorChanged:Boolean = false;
			if ( player.pid == Global.player.pid  )
			{
				Global.player.color = player.color;
				bMyColorChanged = true;
			}

			_view.onPlayerJoined(player);

			/* Start the Game if there are enough players. */

			if (    bMyColorChanged && Global.player.color != "None"
				&& ( _redPlayer && _blackPlayer ) )
			{
				_view.board.enablePieceEvents(Global.player.color);
				Global.app.showObserverMenu();
			}
		}

		public function leaveTable(pid:String) : void
		{
			_view.onPlayerLeft(pid);

			if (pid == Global.player.pid)
			{
				Global.player.color = "None";
			}

			if (   _redPlayer && _redPlayer.pid == pid
				|| _blackPlayer && _blackPlayer.pid == pid )
			{
				_stopTimers();
			}
		}

		/**
		 * Function to perform common tasks on each new Move.
		 */
		private function _processMoveEvent(piece:Piece, curPos:Position, newPos:Position) : void
		{
			// Store the new Move in the Move-List.
			const capturedPiece:Piece = _view.board.getPieceByPos(newPos);
			const move:String = piece.getColor() + ":" + piece.getIndex()
				+ ":" + curPos.row + curPos.column + newPos.row + newPos.column
				+ ":" + (capturedPiece ? capturedPiece.getIndex() : "");

			const nMoves:uint = _moveList.push(move);

			// Update the Piece Map.
			if ( _inReviewMode ) {
				_view.board.updatePieceMapState(piece, curPos, newPos);
			} else {
				_view.board.movePieceByPos(piece, newPos);
			}

			// Update the menu.
			if (nMoves == 1)
			{
				_view.enableReviewButtons(true);
				Global.app.showObserverMenu();
			}
			else if (nMoves == 2)
			{
				_startTimer();
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
			var bSettingsChanged:Boolean = false;

			if (    _settings["gametime"]  != newSettings["gametime"]
				 || _settings["movetime"]  != newSettings["movetime"]
				 || _settings["extratime"] != newSettings["extratime"] )
			{
				bSettingsChanged = true;
			}
			else if ( _settings["rated"] != newSettings["rated"] )
			{
				bSettingsChanged = true;
			}

			if ( bSettingsChanged )
			{
				const itimes:String = newSettings["gametime"]
					+ "/" + newSettings["movetime"] + "/" + newSettings["extratime"];
				Global.app.doUpdateTableSettings(this.tableId, itimes, newSettings["rated"]);
			}
		}

		public function updatePreferences(newPref:Object) : void
		{
			if (_curPref["boardcolor"] != newPref["boardcolor"]) {
				_view.redrawBoard(newPref["boardcolor"], _curPref["linecolor"]);
			}
			if (_curPref["pieceskin"] != newPref["pieceskin"]) {
				_view.changePieceSkin(newPref["pieceskin"]);
			}
			_curPref = newPref;
		}
		
		public function isPlayerPlaying(playerId:String) : Boolean
		{
			return (    (_redPlayer && _redPlayer.pid == playerId)
					 || (_blackPlayer && _blackPlayer.pid == playerId ) );
		}
	}
}
