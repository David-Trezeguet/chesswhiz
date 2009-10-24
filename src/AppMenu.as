package {

	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.controls.Button;

	public class AppMenu  {

		public var toolBar:HBox;
		public var name:String;
		public var x:int;
		public var y:int;
		public function AppMenu(tb:HBox, x:int, y:int, h:int, w:int) : void {
			this.toolBar = tb;
			name = "Menu";
			this.x = x;
			this.y = y;
		}

		public function showTitle() : void {
			Util.createTextField(this.toolBar, "PlayXiangqi", 20, 10, false, 0xFFFFFF, "Verdana", 18);
			Util.createTextField(this.toolBar, Global.vars.app.getPlayerID(), 580, 12, false, 0xa09e9e, "Verdana", 12);

			var logoutBtn:Button = new Button();
			logoutBtn.label = LocaleMgr.instance().getResourceId("ID_LOGOUT");
			logoutBtn.x = 680;
			logoutBtn.y = 10;
			this.toolBar.addChild(logoutBtn);

			function logoutBtnClickHandler(event:Event) : void {
				Global.vars.app.doLogout();
			}
			logoutBtn.addEventListener("click", logoutBtnClickHandler);
		}
		public function showStartMenu() : void {
			while (this.toolBar.numChildren > 0) {
				this.toolBar.removeChildAt(0);
			}
			Util.createTextField(this.toolBar, "PlayXiangqi", 20, 10, false, 0xFFFFFF, "Verdana", 18);
		}
		public function showNavMenu() : void {
			while (this.toolBar.numChildren > 0) {
				this.toolBar.removeChildAt(0);
			}
			showTitle();
			var viewTablesBtn:Button = new Button();
			viewTablesBtn.label = LocaleMgr.instance().getResourceId("ID_VIEWTABLES");
			viewTablesBtn.x = 200;
			viewTablesBtn.y = 10;
			this.toolBar.addChild(viewTablesBtn);
			viewTablesBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doViewTables();
				});
			var NewTableBtn:Button = new Button();
			NewTableBtn.label = LocaleMgr.instance().getResourceId("ID_NEWTABLE");;
			NewTableBtn.x = 320;
			NewTableBtn.y = 10;
			this.toolBar.addChild(NewTableBtn);
			NewTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doNewTable();
				});
		}
		public function showTableMenu(showSettings:Boolean, showPref:Boolean) : void {
			while (this.toolBar.numChildren > 0) {
				this.toolBar.removeChildAt(0);
			}
			showTitle();
			if (showSettings) {
				var tableSettingsBtn:Button = new Button();
				tableSettingsBtn.label = LocaleMgr.instance().getResourceId("ID_SETTINGS");
				tableSettingsBtn.x = 200;
				tableSettingsBtn.y = 10;
				this.toolBar.addChild(tableSettingsBtn);
				tableSettingsBtn.addEventListener("click", function(event:Event) : void {
					Global.vars.app.changeTableSettings();
					});
			}
			if (showPref) {
				var tablePrefBtn:Button = new Button();
				tablePrefBtn.label = LocaleMgr.instance().getResourceId("ID_PREFERENCES");
				tablePrefBtn.x = 320;
				tablePrefBtn.y = 10;
				this.toolBar.addChild(tablePrefBtn);
				tablePrefBtn.addEventListener("click", function(event:Event) : void {
					Global.vars.app.changeTablePref();
					});
			}
			var closeTableBtn:Button = new Button();
			closeTableBtn.label = LocaleMgr.instance().getResourceId("ID_CLOSE");
			closeTableBtn.x = 440;
			closeTableBtn.y = 10;
			this.toolBar.addChild(closeTableBtn);
			closeTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doCloseTable();
				});
		}
		public function showObserverMenu(color:String, tableId:String) : void {
			while (this.toolBar.numChildren > 0) {
				this.toolBar.removeChildAt(0);
			}
			showTitle();
			if (color != "") {
				var playBtn:Button = new Button();
				playBtn.label = (color == "Red") ? LocaleMgr.instance().getResourceId("ID_PLAYRED") : LocaleMgr.instance().getResourceId("ID_PLAYBLACK");
				playBtn.name = "playgame";
				playBtn.x = 340;
				playBtn.y = 10;
				this.toolBar.addChild(playBtn);
				var tid:String = tableId;
				playBtn.addEventListener("click", function(event:Event) : void {
					trace("selected tid: " + tid + " color: " + color);
					Global.vars.app.playGame(tid, color);
					});

			}
			var closeTableBtn:Button = new Button();
			closeTableBtn.label = LocaleMgr.instance().getResourceId("ID_CLOSE");
			closeTableBtn.x = 460;
			closeTableBtn.y = 10;
			this.toolBar.addChild(closeTableBtn);
			closeTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doCloseTable();
				});
		}
		public function showGameMenu() : void {
			while (this.toolBar.numChildren > 0) {
				this.toolBar.removeChildAt(0);
			}
			showTitle();
			var tablePrefBtn:Button = new Button();
			tablePrefBtn.label = LocaleMgr.instance().getResourceId("ID_PREFERENCES");
			tablePrefBtn.x = 200;
			tablePrefBtn.y = 10;
			this.toolBar.addChild(tablePrefBtn);
			tablePrefBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.changeTablePref();
				});
			var resignTableBtn:Button = new Button();
			resignTableBtn.label = LocaleMgr.instance().getResourceId("ID_RESIGN");
			resignTableBtn.x = 320;
			resignTableBtn.y = 10;
			this.toolBar.addChild(resignTableBtn);
			resignTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doResignTable();
				});
			var drawTableBtn:Button = new Button();
			drawTableBtn.label = LocaleMgr.instance().getResourceId("ID_DRAW");
			drawTableBtn.x = 440;
			drawTableBtn.y = 10;
			this.toolBar.addChild(drawTableBtn);
			drawTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doDrawTable();
				});
		}
	}
}
