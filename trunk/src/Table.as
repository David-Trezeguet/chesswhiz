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
		private var _sides:Object;
		private var _tableState:String = "IDLE_STATE";
		private var _tableData:TableInfo = null;
		private var _redTimes:GameTimers = null;
		private var _blackTimes:GameTimers = null;
		private var _redTimer:Timer = null;
		private var _blackTimer:Timer = null;
		private var _moveList:Array = [];
		private var _curMoveIndex:int = -1;
		private var _stateBeforeReview:String = "IDLE_STATE";
		private var _settings:Object;
		private var _curPref:Object;

		public function Table(tableId:String, pref:Object)
		{
			this.tableId = tableId;
			_sides = {
				top:  new Side("top", "Red", null),
				bottom: new Side("bottom", "Black", null)
			};
			_settings = {};
			_settings["gametime"] = 1200;
			_settings["movetime"] = 300;
			_settings["extratime"] = 20;
			_settings["rated"] = false;
			_curPref = pref;
		}

		private function _setTableData(tableData:TableInfo) : void {
			_tableData = tableData.clone();
		}
		
		private function _setRedPlayer(player:PlayerInfo) : void {
			_redPlayer = player.clone();
		}
		
		private function _setBlackPlayer(player:PlayerInfo) : void {
			_blackPlayer =  player.clone();
		}
		
		private function _setObserver(player:PlayerInfo) : void {
			_observers[_observers.length] = player.clone();
		}
		
		public function getTopSideColor():String { return _sides.top.color; }
		public function getBottomSideColor():String { return _sides.bottom.color; }		
		public function getGame():Game { return _game; }

		private function _setSideColors(color:String) : void
		{
			if (color == "Red") {
				_sides.top.color = "Black";
				_sides.bottom.color = "Red";
			}
			else if (color == "Black") {
				_sides.top.color = "Red";
				_sides.bottom.color = "Black";
			}
			else if (color == "") {
				_sides.top.color = "Black";
				_sides.bottom.color = "Red";
			}
		}

		public function getTimers(color:String) : GameTimers {
			return new GameTimers(_tableData.getTime(color));			
		}

		private function _getJoinColor():String
		{
			var joinColor:String = "";
			if ( (_redPlayer != null && _redPlayer.pid != "") && 
				 (_blackPlayer == null || _blackPlayer.pid == "") ) {
				joinColor = "Black";
			}
			else if ( (_blackPlayer != null && _blackPlayer.pid != "") &&
					  (_redPlayer == null || _redPlayer.pid == "") ) {
				joinColor = "Red";
			}
			return joinColor;
		}

		public function newTable(tableData:TableInfo) : void
		{
			if ( tableData.getRedPlayer() != null ||
				 tableData.getRedPlayer().pid != "" ) {
				_setRedPlayer(tableData.getRedPlayer());
			}
			if ( tableData.getBlackPlayer() != null ||
				 tableData.getBlackPlayer().pid != "" ) {
				_setBlackPlayer(tableData.getBlackPlayer());
			}
			_setTableData(tableData);
			_processTableEvent("TABLEINFO_EVENT", tableData);
		}

		private function _createView () : void
		{
			this.view = new TableBoard();
			Global.app.addBoardToWindow(this.view);  // Realize the UI first!
			this.view.display(this);
		}

		public function reviewMove(cmd:String) : void
		{
			if (_tableState != "MOVEREVIEW_STATE") {
				if (_moveList.length > 0 && cmd != "end" && cmd != "forward") {
					_curMoveIndex = _moveList.length;
					_stateBeforeReview = _tableState;
				}
				else {
					return;
				}
			}
			_processTableEvent("MOVEREVIEW_EVENT", cmd);
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
			if (_redPlayer != null && _redPlayer.pid != "") {
				this.view.displayPlayerData(_redPlayer);
				this.view.displayMessage("" + _redPlayer.pid + " joined");
			}
			if (_blackPlayer != null && _blackPlayer.pid != "") {
				this.view.displayPlayerData(_blackPlayer);
				this.view.displayMessage("" + _blackPlayer.pid + " joined");
			}
			trace("joinable color: " + joinColor);
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
			if (this.view == null) {
				return;
			}
			if (_sides.top.color == "Red") {
				this.view.displayPlayerData(_redPlayer);
			}
			else {
				this.view.displayPlayerData(_blackPlayer);
			}
			if (_sides.bottom.color == "Red") {
				this.view.displayPlayerData(_redPlayer);
			}
			else {
				this.view.displayPlayerData(_blackPlayer);
			}
		}

		private function _startGame() : void
		{
			if ( (_redPlayer != null && _redPlayer.pid != "") &&
				 (_blackPlayer != null && _blackPlayer.pid != "") )
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
				this.view.board.disableEvents(_game.getLocalPlayer().color);
				_game = null;
			}
			this.view.board.displayStatus("Game Over (" + reason + ")");
			this.view.displayMessage(winner);
			_stopTimer();
			_processTableEvent("RESIGNGAME_EVENT", null);
		}
		
		public function drawGame(pid:String) : void {
			this.view.displayMessage("" + pid + " offering draw");
		}
		
		public function updateGameTimes(pid:String, times:String) : void
		{
			if (_moveList.length == 0) {
				var timer:GameTimers = null;
				_tableData.updateTimes(times);
				timer = new GameTimers(times);
				this.view.updateTimers(getTopSideColor(), timer);
				this.view.updateTimers(getBottomSideColor(), timer);
				var fields:Array = times.split("/");
				_settings["gametime"] = fields[0];
				_settings["movetime"] = fields[1];
				_settings["extratime"] = fields[2];
				this.view.displayMessage("timer changed to " + times);
			}
		}
	
		private function _startTimer() : void
		{
			_redTimes = new GameTimers(_tableData.getRedTime());
			_redTimer = new Timer(1000, _redTimes.gameTime);
			_redTimer.addEventListener(TimerEvent.TIMER, _timerHandler);

			_blackTimes = new GameTimers(_tableData.getBlackTime());
			_blackTimer = new Timer(1000, _blackTimes.gameTime);
			_blackTimer.addEventListener(TimerEvent.TIMER, _timerHandler);

			if (_getMoveColor() == "Red") {
				_redTimer.start();
			} else {
				_blackTimer.start();
			}
		}

		private function _getMoveColor() : String
		{
			var color:String = "";
			if (_game != null) {
				if (_game.waitingForMyMove()) {
					color = _game.getLocalPlayer().color;
				}
				else {
					color = _game.getOppPlayer().color;
				}
			}
			else {
				if (_moveList.length > 0) {
					var lastMove:String = _moveList[_moveList.length - 1];
					if (lastMove != "") {
						var fields:Array = lastMove.split(":");
						color = (fields[0] == "Red") ? "Black" : "Red";
					}
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

		private function _resetTimer() : void
		{
			if (_getMoveColor() == "Red") {
				_blackTimes.resetMoveTime();
				_blackTimer.stop();
				_redTimer.start();
			}
			else {
				_redTimes.resetMoveTime();
				_redTimer.stop();
				_blackTimer.start();
			}
		}

		private function _timerHandler(event:Event) : void
		{
			const color:String = _getMoveColor();
			if (color == "Red") {
				if (_redTimes) {
					_redTimes.gameTime--;
					if (_redTimes.gameTime == 0) {
						_gameTimeout(color);
                        return;
					}
					_redTimes.moveTime--;
					if (_redTimes.moveTime == 0) {
						_moveTimeout(color);
						_redTimer.stop();
						return;
					}
					this.view.updateTimers("Red", _redTimes);
				}
			}
			else if (color == "Black") {
				if (_blackTimes) {
					_blackTimes.gameTime--;
					if (_blackTimes.gameTime == 0) {
						_gameTimeout(color);
                        return;
					}
					_blackTimes.moveTime--;
					if (_blackTimes.moveTime == 0) {
						_moveTimeout(color);
						_blackTimer.stop();
						return;
					}
					this.view.updateTimers("Black", _blackTimes);
				}
			}
		}

		private function _moveTimeout(color:String) : void {
			this.view.displayMessage(color + " move timeout");
			_processTableEvent("MOVETIMEOUT_EVENT", color);
		}

		private function _gameTimeout(color:String) : void {
			this.view.displayMessage(color + " game timeout");
			_processTableEvent("GAMETIMEOUT_EVENT", color);
		}

		private function _closeTable() : void {
		    _stopTimer();
		}

		public function playMoveList(moveList:MoveListInfo) : void
		{
			for (var i:int = 0; i < moveList.moves.length; i++) {
				var curPos:Position = new Position(parseInt(moveList.moves[i].charAt(1)), parseInt(moveList.moves[i].charAt(0)));
				var newPos:Position = new Position(parseInt(moveList.moves[i].charAt(3)), parseInt(moveList.moves[i].charAt(2)));
				var piece:Piece = this.view.board.getPieceByPos(curPos);
				if (piece) {
					_processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
				}
			}
		};
		
		private function _rewindLastMove() : void
		{
			if (_moveList.length > 0) {
				var lastMove:String = _moveList[_moveList.length - 1];
				if (lastMove != "") {
					var fields:Array = lastMove.split(":");
					var piece:Piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
					var move:String = fields[2];
					var capturePiece:Piece = null;
					if (fields[3] != "") {
						capturePiece = this.view.board.getPieceByIndex((fields[0] == "Red") ? "Black" : "Red", fields[3]);
					}
					var prevPos:Position = new Position(parseInt(move.charAt(0)), parseInt(move.charAt(1)));
					var curPos:Position = new Position(parseInt(move.charAt(2)), parseInt(move.charAt(3)));
					this.view.board.rewindPieceByPos(piece, curPos, prevPos, capturePiece);
					_moveList.splice(_moveList.length - 1, 1);
					if (_moveList.length > 1) {
						lastMove = _moveList[_moveList.length - 1];
						if (lastMove != "") {
							fields = lastMove.split(":");
							piece = this.view.board.getPieceByIndex(fields[0], fields[1]);
							this.view.board.setFocusOnPiece(piece);
						}
					}
				}
			}
		}

		public function processWrongMove(error:String) : void
		{
			_rewindLastMove();
			this.view.displayMessage("Server rejected the move. " + error);
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
				capturePiece = this.view.board.getPieceByIndex((fields[0] == "Red") ? "Black" : "Red", fields[3]);
			}
			return [piece, move, capturePiece];
		}

		public function moveLocalPiece(piece:Piece, curPos:Position, newPos:Position) : void
		{
			if (_tableState == "MOVEREVIEW_STATE" && _curMoveIndex != _moveList.length) {
				this.view.displayMessage("In review mode");
				piece.moveImage();
				return;
			}
			if (   _tableState == "MOVEREVIEW_STATE" && _stateBeforeReview == "GAMEPLAY_STATE"
				&& _game.getLocalPlayer().color == piece.getColor() )
			{
				_stopReview();
				_tableState = _stateBeforeReview;
			}
			if (!_game.waitingForMyMove()) {
				this.view.displayMessage("Invalid move. Waiting for " + _game.getOppPlayer().color + " move");
				piece.moveImage();
				return;
			}
			var resultObj:Array = _game.validateMove(this.view.board, newPos, piece);
			if (resultObj[0] != 1) {
				this.view.displayMessage("Invalid move. " + resultObj[1]);
				piece.moveImage();
				return;
			}
			_processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
			if (_game.isCheckMate(null)) {
				this.view.displayMessage("Invalid move. Check active");
				_rewindLastMove();
				return;
			}
			Global.app.playMoveSound();
			if (_tableState == "GAMEPLAY_STATE") {
				if (_game) {
					_game.processEvent("move");
				}
				// Send request to the server
				Global.app.sendMoveRequest(_game.getLocalPlayer(), piece, curPos, newPos, this.tableId);
			}
		}

		public function movePiece(moveData:MoveInfo) : void
		{
			Global.app.playMoveSound();
			var curPos:Position = new Position(moveData.getCurrentPosRow(), moveData.getCurrentPosCol());
			var newPos:Position = new Position(moveData.getNewPosRow(), moveData.getNewPosCol());
			var piece:Piece = this.view.board.getPieceByPos(curPos);
			if (piece) {
				_processTableEvent("MOVEPIECE_EVENT", [piece, curPos, newPos]);
			}
			if (_tableState == "GAMEPLAY_STATE" || _tableState == "MOVEREVIEW_STATE"  ) {
                if (_game) {
				    if (_game.isCheckMate(piece)) {
					    this.view.displayMessage("Check by " + piece.getColor() + " " + piece.getType());
				    }
                }
				if (_game) {
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
				Global.app.showTableMenu(false, true);
			}
		}

		private function _processReviewMove(cmd:String) : void
		{
			if (_moveList.length == 0) {
				return;
			}

			var moveIndex:int = 0;
			if (cmd == "start") {
				moveIndex = 0;
			} else if (cmd == "end") {
				moveIndex = _moveList.length;
			} else if (cmd == "rewind") {
				moveIndex = _curMoveIndex - 1;
				if (moveIndex < 0) {
					return;
				}
			} else {
				moveIndex = _curMoveIndex + 1;
				if (moveIndex > _moveList.length) {
					return;
				}
			}
			
			if (_curMoveIndex == moveIndex ) {
				return;
			}
			_applyChangeSet(moveIndex);
		}

		private function _applyChangeSet(moveIndex:int) : void
		{
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
			if (moveIndex < _curMoveIndex) {
				for (i = _curMoveIndex - 1; i >= moveIndex; i--) {
					mov = _moveList[i];
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
					_curMoveIndex--;
					if (_curMoveIndex < _moveList.length && _curMoveIndex > 0) {
						mov = _moveList[_curMoveIndex - 1];
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
				for (i = _curMoveIndex; i < moveIndex; i++) {
					mov = _moveList[i];
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
			if (player.color == "Black") {
				_setBlackPlayer(player);
			}
			else if (player.color == "Red") {
				_setRedPlayer(player);
			}
			else {
				_setObserver(player);
			}
			_processTableEvent("JOINTABLE_EVENT", player);
			this.view.displayMessage("" + player.pid + " joined");
		}

		public function leaveTable(pid:String) : void
		{
			_processTableEvent("LEAVETABLE_EVENT", pid);
			this.view.displayMessage("" + pid + " left");
		}

		public function processEvent_LEAVE(pid:String) : void
		{
			if (pid == Global.app.getPlayerID()) {
				_closeTable();
			}
			else {
				if (this.view != null) {
					if (_redPlayer && _redPlayer.pid == pid) {
						this.view.removePlayerData("Red");
						_stopTimer();
					} else if (_blackPlayer && _blackPlayer.pid == pid) {
						this.view.removePlayerData("Black");
						_stopTimer();
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
		private function _processTableEvent(type:String, data:*) : void
		{
			if (_tableState == "IDLE_STATE") {
				if (type == "JOINTABLE_EVENT") {
					if (data.pid == Global.app.getPlayerID()) {
						if (data.color != "None") {
							_setSideColors(data.color);
							_createNewTableView();
							_tableState = "NEWTABLE_STATE";
						}
						else {
							var joinColor:String = _getJoinColor();
							_setSideColors(joinColor);
							_createObserveTableView(joinColor);
							if (joinColor == "") {
								_tableState = "OBSERVER_STATE";
							}
							else {
								_tableState = "VIEWTABLE_STATE";
							}
						}
					}
				}
				else if (type == "TABLEINFO_EVENT") {
					if (data.getRedPlayer().pid == Global.app.getPlayerID() ||
						data.getBlackPlayer().pid == Global.app.getPlayerID()) {
						if (data.getRedPlayer().pid == Global.app.getPlayerID()) {
							_setSideColors("Red");
						}
						else if (data.getBlackPlayer().pid == Global.app.getPlayerID()) {
							_setSideColors("Black");
						}
						_createNewTableView();
						Global.app.showTableMenu(true, true);
						_tableState = "NEWTABLE_STATE";
						this.view.displayMessage("" + Global.app.getPlayerID() + " joined");
					}
					else {
						joinColor = _getJoinColor();
						_setSideColors(joinColor);
						_createObserveTableView(joinColor);
						if (joinColor == "") {
							_tableState = "OBSERVER_STATE";
						}
						else {
							_tableState = "VIEWTABLE_STATE";
						}
					}
				}
			}
			else if (_tableState == "NEWTABLE_STATE") {
				if (type == "JOINTABLE_EVENT") {
					if (data.color != "None") {
						if (this.view != null) {
							// TODO: Clear palyer data
							this.view.displayPlayerData(data);
							if (_redPlayer.pid == Global.app.getPlayerID()) {
								this.view.displayPlayerData(_redPlayer);
							}
							else {
								this.view.displayPlayerData(_blackPlayer);
							}
						}
						_startGame();
						_tableState = "GAMEPLAY_STATE";
					}
				}
				else if (type == "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
			}
			else if (_tableState == "VIEWTABLE_STATE") {
				if (type == "JOINTABLE_EVENT") {
					if (this.view != null) {
						_displayPlayers();
						Global.app.showTableMenu(true, true);
					}
					if (_redPlayer.pid == Global.app.getPlayerID() ||
						_blackPlayer.pid == Global.app.getPlayerID()) {
						_startGame();
						_tableState = "GAMEPLAY_STATE";
					}
					else {
						_tableState = "OBSERVER_STATE";
					}
				}
				else if (type == "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
			}
			else if (_tableState == "OBSERVER_STATE") {
				if (type == "MOVEPIECE_EVENT") {
					var piece:Piece = data[0];
					_updateMove(piece, data[1], data[2]);
					if (this.view != null) {
						this.view.board.movePieceByPos(piece, data[2], (this.view == null) ? false : true);
					}
					if (_moveList.length > 2) {
						_resetTimer();
					}
				}
				else if (type == "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type == "RESIGNGAME_EVENT") {
					_stopTimer();
				}
				else if (type == "MOVEREVIEW_EVENT") {
					_tableState = "MOVEREVIEW_STATE";
					_processReviewMove(data);
				}
				else if (type == "MOVETIMEOUT_EVENT" || type == "GAMETIMEOUT_EVENT") {
                     _stopTimer();
                }
			}
			else if (_tableState == "GAMEPLAY_STATE") {
				if (type == "MOVEPIECE_EVENT") {
					piece = data[0];
					_updateMove(piece, data[1], data[2]);
					if (this.view != null) {
						this.view.board.movePieceByPos(piece, data[2], (this.view == null) ? false : true);
					}
					if (_moveList.length > 2) {
						_resetTimer();
					}
				}
				else if (type == "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type == "RESIGNGAME_EVENT") {
                    _stopTimer();
					if (this.view != null) {
						Global.app.showTableMenu(false, false);
					}
					_tableState = "ENDGAME_STATE";
				}
				else if (type == "MOVEREVIEW_EVENT") {
					_tableState = "MOVEREVIEW_STATE";
					_processReviewMove(data);
				}
				else if (type == "MOVETIMEOUT_EVENT" || type == "GAMETIMEOUT_EVENT") {
					if (this.view != null) {
						Global.app.showTableMenu(false, false);
					}
                    _stopTimer();
					_tableState = "ENDGAME_STATE";
				}
			}
			else if (_tableState == "ENDGAME_STATE") {
				if (type == "LEAVETABLE_EVENT") {
					this.processEvent_LEAVE(data);
				}
				else if (type == "MOVEREVIEW_EVENT") {
					_tableState = "MOVEREVIEW_STATE";
					_processReviewMove(data);
				}
			}
			else if (_tableState == "MOVEREVIEW_STATE") {
				if (type == "MOVEREVIEW_EVENT") {
					_processReviewMove(data);
					if (data == "end" || (data == "forward" && _curMoveIndex == _moveList.length)) {
						_stopReview();
						_tableState = _stateBeforeReview;
					}
				}
				else if (type == "MOVEPIECE_EVENT") {
					piece = data[0];
					if (_stateBeforeReview == "GAMEPLAY_STATE") {
						_updateMove(piece, data[1], data[2]);
						if (this.view != null) {
							this.view.board.updatePieceMapState(piece, data[1], data[2]);
						}
						if (_moveList.length > 2) {
							_resetTimer();
						}
					}
					else if (_stateBeforeReview == "OBSERVER_STATE") {
						if (_curMoveIndex == _moveList.length) {
							_stopReview();
							_tableState = _stateBeforeReview;
							_processTableEvent(type, data);
						}
						else {
							_updateMove(piece, data[1], data[2]);
							if (this.view != null) {
								this.view.board.updatePieceMapState(piece, data[1], data[2]);
							}
							if (_moveList.length > 2) {
								_resetTimer();
							}							
						}
					}
				}
				else {
					_stopReview();
					_tableState = _stateBeforeReview;
					_processTableEvent(type, data);
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
