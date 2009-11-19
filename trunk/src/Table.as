package {
	import flash.display.*;
	
	import hoxserver.*;
	
	import ui.TableBoard;
	
	public class Table
	{
		public var tableId:String = "";

		private var _view:TableBoard  = null;
		private var _referee:Referee  = new Referee();

		private var _redPlayer:PlayerInfo   = null;
		private var _blackPlayer:PlayerInfo = null;

		private var _settings:Object;
		private var _curPref:Object;

		public function Table(tableId:String, preferences:Object, view:TableBoard)
		{
			this.tableId = tableId;

			_settings =
				{
					"gametime"  : 0,
					"movetime"  : 0,
					"freetime"  : 0,
					"rated"     : false
				};

			_curPref  = preferences;

			_view = view;
			_view.setPreferences(this, _curPref["boardcolor"], _curPref["linecolor"], _curPref["pieceskin"]);
		}

		public function valid() : Boolean { return tableId != ""; }
		public function setTableId(id:String) : void { tableId = id; }

		public function setSettings(settings:Object) : void { _settings = settings; }

		public function displayEmptyTable() : void
		{
			_redPlayer = null;
			_blackPlayer = null;

			_view.clearDisplay();

			_view.board.disablePieceEvents("Red");
			_view.board.disablePieceEvents("Black");
		}

		/**
		 * This function is called when the server returns the Table-Info as
		 * the response to one of the two requests sent by the local Player:
		 *     (1) Open a new Table.
		 *     (2) Join an existing Table.
		 */
		public function newTable(tableInfo:Object) : void
		{
			this.displayEmptyTable(); // Reset the previous table, if any.

			// TODO: This "reset" action can be called TWICE!!!!
			_referee.resetGame();

			// Setup the Table with new table-info.

			_view.initializeTimers(tableInfo.initialtime, tableInfo.redtime, tableInfo.blacktime);

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

			// Add the list of observers, if any.
			for each (var observerInfo:PlayerInfo in tableInfo.observers)
			{
				_view.onPlayerJoined( observerInfo );
			}
		}

		public function displayChatMessage(pid:String, msg:String, bPrivate:Boolean = false) : void
		{
			_view.onBoardMessage(msg, pid, bPrivate);
		}
		
		public function stopGame(winner:String, reason:String) : void
		{
			if ( Global.player.color != "None" )
			{
				_view.board.disablePieceEvents(Global.player.color);
				Global.player.color = "None";
			}

			_view.onGameOverEventFromTable(winner, reason);
		}

		public function drawGame(pid:String) : void
		{
			_view.onBoardMessage(pid + " is offering a DRAW.", "***");
		}

		public function updateTableSettings(itimes:String, bRated:Boolean) : void
		{
			_view.initializeTimers(itimes);

			const fields:Array = itimes.split("/");
			_settings["gametime"]  = fields[0];
			_settings["movetime"]  = fields[1];
			_settings["freetime"]  = fields[2];
			_settings["rated"]     = bRated;

			_view.onBoardMessage("Timer: " + itimes, "***");
			_view.onBoardMessage("Game-Type: " + (bRated ? "Rated" : "Nonrated"), "***");
		}

		public function resetTable() : void
		{
			_view.onReset();
			_referee.resetGame();

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

		public function playMoveList(moves:Array) : void
		{
			for (var i:int = 0; i < moves.length; i++)
			{
				var oldPos:Position = new Position( parseInt(moves[i].charAt(1)),
													parseInt(moves[i].charAt(0)) );
				var newPos:Position = new Position( parseInt(moves[i].charAt(3)),
													parseInt(moves[i].charAt(2)) );

				const pieceInfo:PieceInfo = _referee.findPieceAtPosition(oldPos);
				if ( pieceInfo == null )
				{
					_view.onErrorMessage("Invalid network Move: " + oldPos + " -> " + newPos);
					return;
				}

				const result:Array = _referee.validateAndRecordMove(oldPos, newPos);
				if ( ! result[0] )
				{
					_view.onErrorMessage("Invalid Network Move.");
					return;	
				}

				const bCapturedMove:Boolean = result[1];
				_view.onNewMoveFromTable(pieceInfo.color, oldPos, newPos, bCapturedMove, true /* in Setup mode */ );
			}
		}

		public function processWrongMove(error:String) : void
		{
			/* NOTE: Not implement the "undo move" because this Client should
			 *       validate the Move properly before submiting to the server.
			 *
			 */
			_view.onErrorMessage("Server rejected the last move: " + error);
		}

		/**
		 * Callback function to check if a Move made by
		 * the local (physical) Player is valid. 
		 */
		public function onLocalPieceMoved(piece:Piece, newPos:Position) : Boolean
		{
			// Validate.
			const oldPos:Position = piece.getPosition();
			const result:Array = _referee.validateAndRecordMove(oldPos, newPos);
			if ( ! result[0] )
			{
				trace("Piece cannot be moved: Invalid move.");
				return false;	
			}

			// Upon reaching here, the Move has been determined to be valid.
			const bCapturedMove:Boolean = result[1];
			_view.onNewMoveFromTable(piece.getColor(), oldPos, newPos, bCapturedMove);
			Global.app.playMoveSound();

			Global.app.doSendMove(oldPos, newPos); // TODO: This one delays the pieces' movements!
			return true;
		}

		/**
		 * Function to handle a Move coming from the remote server. 
		 */
		public function handleRemoteMove(oldPos:Position, newPos:Position) : void
		{
			const pieceInfo:PieceInfo = _referee.findPieceAtPosition(oldPos);
			if ( pieceInfo == null )
			{
				_view.onErrorMessage("Invalid network Move: " + oldPos + " -> " + newPos);
				return;
			}

			const result:Array = _referee.validateAndRecordMove(oldPos, newPos);
			if ( ! result[0] )
			{
				_view.onErrorMessage("Invalid Network Move.");
				return;	
			}

			const bCapturedMove:Boolean = result[1];
			_view.onNewMoveFromTable(pieceInfo.color, oldPos, newPos, bCapturedMove);
			Global.app.playMoveSound();
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

			if ( player.pid == Global.player.pid  )
			{
				// If I no longer play, disable my pieces.
				if ( Global.player.color != "None" && player.color == "None" )
				{
					_view.board.disablePieceEvents(Global.player.color);
				}
				Global.player.color = player.color;
			}

			_view.onPlayerJoined(player);

			/* Start the Game if there are enough players. */

			if (   player.color != "None"
				&& Global.player.color != "None"
				&& ( _redPlayer && _blackPlayer ) )
			{
				_view.board.enablePieceEvents(Global.player.color);
			}
		}

		public function leaveTable(pid:String) : void
		{
			_view.onPlayerLeft(pid);

			if (pid == Global.player.pid)
			{
				Global.player.color = "None";
			}
		}

		public function getSettings() : Object { return _settings; }

		public function updateSettings(newSettings:Object) : void
		{
			if (    _settings["gametime"] != newSettings["gametime"]
				 || _settings["movetime"] != newSettings["movetime"]
				 || _settings["freetime"] != newSettings["freetime"]
				 || _settings["rated"]    != newSettings["rated"] )
			{
				const itimes:String = newSettings["gametime"]
					+ "/" + newSettings["movetime"] + "/" + newSettings["freetime"];
				Global.app.doUpdateTableSettings(itimes, newSettings["rated"]);
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

		public function displayPlayerInfo(playerInfo:Object) : void
		{
			const infoString:String = playerInfo.pid + " " + playerInfo.score
				+ " W" + playerInfo.wins + "D" + playerInfo.draws + "L" + playerInfo.losses;
			_view.onBoardMessage("*INFO: " + infoString);
		}

		public function displayInvitation(inviteInfo:Object) : void
		{
			const tableId:String = (inviteInfo.tid ? inviteInfo.tid : "?");
			const inviteString:String = "From [" + inviteInfo.pid + " (" + inviteInfo.score + ")]"
				+ " @ [" + tableId + "]";
			_view.onBoardMessage("*INVITE: " + inviteString);
		}

		public function updatePlayerScore(scoreInfo:Object) : void
		{
			if ( _redPlayer && _redPlayer.pid == scoreInfo.pid ) {
				_redPlayer.score = scoreInfo.score;
			}
			else if ( _blackPlayer && _blackPlayer.pid == scoreInfo.pid ) {
				_blackPlayer.score = scoreInfo.score;
			}

			_view.onNewPlayerScore(scoreInfo.pid, scoreInfo.score);
		}
	}
}
