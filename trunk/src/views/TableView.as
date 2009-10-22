package views
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.Image;
	import mx.controls.List;
	import mx.controls.TextArea;
	import mx.controls.dataGridClasses.DataGridColumn;
	import hoxserver.*;
	import views.*;
	
	public class TableView extends Panel
	{
		private var mcTopPanel:HBox;
		private var mcBottomPanel:HBox;
		private var rightPanel:VBox;
		private var mcTopPlayer:HBox;
		private var mcBottomPlayer:HBox;
		private var mcTopTimers:HBox;
		private var mcBottomTimers:HBox;
		private var taMessages:TextArea;
		private var taChat:TextArea;
		private var dpChat:ArrayCollection;
		private var taChatInput:TextArea;
		private var mcMoves:Panel;
		private var mcChat:Panel;
		private var mcMessages:Panel;
		private var timerIcon:String;
		private var redPlayerIcon:String;
		private var blackPlayerIcon:String;
		private var dpMoves:ArrayCollection;
		public var grid:DataGrid;
		private var tableObj;
		public var board:Board;
		private var boardPanelWidth:int;
		private var boardPanelHeight:int;
		private var boardHeight:int;
		private var boardWidth:int;
		private var topMargin:int;
		private var leftMargin:int;

		public function TableView(parent, tObj)
		{
			this.layout = "absolute";
			this.id = "tablePanel";
			this.title = "Table #" + tObj.tableId;
			parent.addChild(this);
			this.redPlayerIcon = "images/redplayer.png";
			this.blackPlayerIcon =  "images/blackplayer.png";
			this.timerIcon = "images/player_time.png";
			this.tableObj = tObj;
			this.boardHeight = 560;
			this.boardWidth = 560;
			this.boardPanelHeight = 30;
			this.boardPanelWidth = 560;
			this.leftMargin = 10;
			this.topMargin = 10;
			this.board = new Board(this.boardHeight, this.boardWidth, this.tableObj);
		}

		public function display()
		{
			this.displayTopPanel();
			this.displayBoard();
			this.displayBottomPanel();
			Global.vars.app.showTableMenu(true, true);
			this.rightPanel = new VBox();
			this.rightPanel.x = 20 + this.boardWidth;
			this.rightPanel.y = 10;
			this.addChild(this.rightPanel);
			this.displayMessages();
			this.displayMoves();
			this.displayChatBox();
		}
		
		public function displayTopPanel():void {
			this.mcTopPanel = new HBox();
			mcTopPanel.x = leftMargin;
			mcTopPanel.y = topMargin;
			mcTopPanel.width = this.boardPanelWidth;
			mcTopPanel.height = this.boardPanelHeight;
			this.addChild(this.mcTopPanel);
			this.mcTopPlayer = new HBox();
			this.mcTopPlayer.name = "topplayer";
			this.mcTopPanel.addChild(this.mcTopPlayer);
			this.mcTopTimers = new HBox();
			this.mcTopTimers.name = "topiimers";
			this.mcTopPanel.addChild(this.mcTopTimers);
		}
		public function displayBottomPanel():void {
			this.mcBottomPanel = new HBox();
			mcBottomPanel.x = leftMargin;
			mcBottomPanel.y = this.topMargin + this.boardHeight + this.boardPanelHeight;
			mcBottomPanel.width = this.boardPanelWidth;
			mcBottomPanel.height = this.boardPanelHeight;
			this.addChild(this.mcBottomPanel);
			this.mcBottomPlayer = new HBox();
			this.mcBottomPlayer.name = "bottomplayer";
			this.mcBottomPanel.addChild(this.mcBottomPlayer);
			this.mcBottomTimers = new HBox();
			this.mcBottomTimers.name = "bottomtimers";
			this.mcBottomPanel.addChild(this.mcBottomTimers);
		}

		public function displayPlayerData(player):void {
			if (this.mcTopPanel == null || this.mcBottomPanel == null || player == null) {
				return;
			}
			var mcPlayer:HBox = (player.getColor() === this.tableObj.getTopSideColor()) ? this.mcTopPlayer : this.mcBottomPlayer;
			while (mcPlayer.numChildren > 0) {
				mcPlayer.removeChildAt(0);
			}
			var mcPlayerImage:Image = new Image();
			mcPlayerImage.y = 5;
			mcPlayerImage.x = 5;
			mcPlayerImage.source = Global.vars.app.baseURI;
			if (player.getColor() == "Red") {
				mcPlayerImage.source += this.redPlayerIcon;
			} else {
				mcPlayerImage.source += this.blackPlayerIcon;
			}
			mcPlayerImage.width = 20;
			mcPlayer.addChild(mcPlayerImage);
			Util.createTextField(mcPlayer, player.getPlayerID() + "(" + player.getScore() + ")", 45, 5, false, 0xa09e9e, "Verdana", 12);

			var timer:GameTimers = this.tableObj.getTimers(player.getColor());
			this.displayTimers(player.getColor(), timer);
		}

		public function removePlayerData(color:String):void {
			if (this.mcTopPanel == null || this.mcBottomPanel == null) {
				return;
			}
			var mcPlayer:HBox = (color === this.tableObj.getTopSideColor()) ? this.mcTopPlayer : this.mcBottomPlayer;
			if (color === this.tableObj.getTopSideColor()) {
				if (mcTopPanel != null) {
					while (mcTopPanel.numChildren > 0) {
						mcTopPanel.removeChildAt(0);
					}
				}
			} else {
				if (mcBottomPanel != null) {
					while (mcBottomPanel.numChildren > 0) {
						mcBottomPanel.removeChildAt(0);
					}
				}
			}
		}

		public function displayTimers(color, timer) {
			var mcPlayer:HBox = (color === this.tableObj.getTopSideColor()) ? this.mcTopPlayer : this.mcBottomPlayer;
			var mcTimers:HBox = (color === this.tableObj.getTopSideColor()) ? this.mcTopTimers : this.mcBottomTimers;
			while (mcTimers.numChildren > 0) {
				mcTimers.removeChildAt(0);
			}
			var bounds:Object = mcTopPanel.getBounds(this);
			trace("x: " + bounds.x + " y: " + bounds.y + " w: " + bounds.width + " h: " + bounds.height);
			var mcTimeImage = new Image();
			mcTimeImage.y = 5;
			mcTimeImage.x = 4;
			mcTimeImage.source = Global.vars.app.baseURI + this.timerIcon;
			mcTimeImage.width = 20;
			mcTimers.addChild(mcTimeImage);
			var tfTime = Util.createTextField(mcTimers, timer.getTimer("game"), 30, 5, false, 0xa09e9e, "Verdana", 12);
			tfTime.name = color + "game";
			tfTime = Util.createTextField(mcTimers, timer.getTimer("move"), 70, 5, false, 0xa09e9e, "Verdana", 12);
			tfTime.name = color + "move";
			tfTime = Util.createTextField(mcTimers, timer.getTimer("extra"), 110, 5, false, 0xa09e9e, "Verdana", 12);
			tfTime.name = color + "extra";
			var mcTimerBounds:Object = mcTimers.getBounds(this.mcTopPanel);
			trace("timer clip wifth: " + mcTimers.width + "bounds width: " + mcTimerBounds.width);
			mcTimers.x = bounds.x + bounds.width - 180;
		}
		public function updateTimers(color, timer) {
			var mcTimers:HBox = (color === this.tableObj.getTopSideColor()) ? this.mcTopTimers : this.mcBottomTimers;
			if (mcTimers == null || mcTimers.numChildren == 0) {
				return;
			}
			var tfTime = mcTimers.getChildByName(color + "game");
			if (tfTime) {
				tfTime.text = timer.getTimer("game");
			}
			tfTime = mcTimers.getChildByName(color + "move");
			if (tfTime) {
				tfTime.text = timer.getTimer("move");
			}
			tfTime = mcTimers.getChildByName(color + "extra");
			if (tfTime) {
				tfTime.text = timer.getTimer("extra");
			}
		}
		
		public function displayMessages():void {
			this.mcMessages = new Panel();
			this.mcMessages.layout = "absolute";
			this.mcMessages.title = "Messages";
			this.taMessages = Util.createTextArea(this.mcMessages, "", 0, 0, 150, 200, true, 0x0000ff, 0x5b5d5b, "Verdana", 10, false, 1);
			this.rightPanel.addChild(this.mcMessages);
		}
		public function displayMessage(msg):void {
			this.taMessages.text += msg + "\n";
		}

		public function displayMoves():void {
			this.mcMoves = new Panel();
			this.mcMoves.layout = "absolute";
			this.mcMoves.title = "Moves";
			grid= new DataGrid();
			grid.x = 4;
			grid.y = 0;
			grid.width = 200;
			grid.height = 150;

			// add Table header column names
			var colNames:Array = [
			"piece",
			"move",
			"captured"];
			var columnName:DataGridColumn;
            var cols:Array = null;
			for (var j:String in colNames) {
				trace(colNames[j]);
				columnName = new DataGridColumn(colNames[j]);
                cols = grid.columns;
                cols.push(columnName);
                grid.columns = cols;
			}
			// add move data
			dpMoves = new ArrayCollection();
			var moveInfo:Object = {}
			var moveList = this.tableObj.getMoveList();
			if (moveList.length > 0) {
				for (var i:int = 0; i < moveList.length; i++) {
					displayMoveData(moveList[i], moveList.length);
				}
				grid.rowCount = moveList.length;
			}
			grid.dataProvider = dpMoves;
			grid.sortableColumns = false;
			mcMoves.addChild(grid);
			this.rightPanel.addChild(this.mcMoves);
			Util.createButton(this.mcMoves, "start", "|<", grid.x, grid.height + 2, 20, 40, false,  this.reviewMove);
			Util.createButton(this.mcMoves, "rewind", "<", grid.x + 50, grid.height + 2, 20, 40, false, this.reviewMove);
			Util.createButton(this.mcMoves, "forward", ">", grid.x + 100, grid.height + 2, 20, 40, false, this.reviewMove);
			Util.createButton(this.mcMoves, "end", ">|", grid.x + 150, grid.height + 2, 20, 40, false, this.reviewMove);
		}
		
		public function enableReviewButtons() {
			for (var i = 0; i < this.mcMoves.numChildren; i++) {
				if (this.mcMoves.getChildAt(i) is Button) {
					var button = (Button)(this.mcMoves.getChildAt(i));
					button.enabled = true;
				}
			}
		}
		public function displayMoveData(mov:String, moveList:Array):void {
			var moveInfo:Object = {};
			var fields:Array = mov.split(":");
			moveInfo["piece"] = fields[0] + " " + this.board.getPieceByIndex(fields[0], fields[1]).getType();
			moveInfo["move"] = fields[2].charAt(0) + "," + String.fromCharCode(97 + parseInt(fields[2].charAt(1))) + "->" + fields[2].charAt(2) + "," + String.fromCharCode(97 + parseInt(fields[2].charAt(3)));
			if (fields[3] != "") {
				moveInfo["captured"] = this.board.getPieceByIndex((fields[0] === "Red") ? "Black" : "Red", fields[3]).getType();
			}
			moveInfo["selected"] = false;
			dpMoves.addItem(moveInfo);
			grid.scrollToIndex(moveList.length - 1);
		}
		public function reviewMove(event:Event):void {
			var button:Button = Button(event.target);
			trace("button name: " + button.name);
			tableObj.reviewMove(button.name);
		}

		public function displayChatBox():void {
			this.mcChat = new Panel();
			this.mcChat.layout = "absolute";
			this.mcChat.title = "Chat";
			this.taChat = Util.createTextArea(this.mcChat, "", 4, 0, 100, 200, true, 0x0000ff, 0x5b5d5b, "Verdana", 11, false, 1);
			this.taChatInput = Util.createTextArea(this.mcChat, "", 4, this.taChat.height + 2, 35, 200, true, 0x0000ff, 0x5b5d5b, "Verdana", 11, true, 1);
			this.taChatInput.addEventListener(KeyboardEvent.KEY_UP , postChatMessage);
			this.rightPanel.addChild(this.mcChat);
		}
		public function displayChatMessage(pid, chatMsg) {
			this.taChat.text  += "[" + pid + "] " + chatMsg + "\n";
		}
        public function postChatMessage(event:KeyboardEvent):void
        {
        	if (event.keyCode != Keyboard.ENTER) {
        		return;
        	}
        	var temp:String;
			var chatMsg:String = this.taChatInput.text
			if (chatMsg.charAt(chatMsg.length - 1) == "\n") {
				temp = chatMsg.substr(0, chatMsg.length - 1);
				chatMsg = temp;
			}
			if (chatMsg.charAt(chatMsg.length - 1) == "\r") {
				temp = chatMsg.substr(0, chatMsg.length - 1);
				chatMsg = temp;
			}
			trace("chat input msg: " + chatMsg);
			if (chatMsg.search("/debug") == 0) {
				tableObj.handleDebugCmd(chatMsg);
				this.taChatInput.text = "";
				return;
			}
			Global.vars.app.doTableChat(chatMsg);
			this.taChatInput.text = "";
			this.displayChatMessage(Global.vars.app.getPlayerID(), chatMsg);
        }

		public function displayBoard():void {
			var pref = this.tableObj.getPreferences();
			this.board.createBoard(this, pref["boardcolor"], pref["linecolor"], pref["pieceskinindex"], this.leftMargin, this.topMargin + this.boardPanelHeight);
		}
		public function getBoard():Board {
			return this.board;
		}
		public function redrawBoard(boardColor, lineColor, pieceSkin) {
			this.board.drawBoard(this, boardColor, lineColor, pieceSkin, this.leftMargin, this.topMargin + this.boardPanelHeight);
			this.board.changePiecesSkin(pieceSkin);
			var piece = this.board.getFocusPiece();
			if (piece) {
				piece.setFocus();
			}
		}
		
		public function changePieceSkin(pieceSkin) {
			this.board.changePiecesSkin(pieceSkin);
			var piece = this.board.getFocusPiece();
			if (piece) {
				piece.setFocus();
			}
		}

	}
}