package {

	import flash.events.Event;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.resources.ResourceManager;

	public class AppMenu  {

		private var _toolBar:HBox;

		public function AppMenu(tb:HBox) : void {
			_toolBar = tb;
		}

		private function _clearAllAndShowTitle() : void {
			_toolBar.removeAllChildren();
			Util.createTextField(_toolBar, "PlayXiangqi", 20, 10, false, 0xFFFFFF, "Verdana", 18);
			
			const playerId:String = Global.vars.app.getPlayerID();
			if (playerId != "" )  // Already logged in?
			{
				Util.createTextField(_toolBar, playerId, 580, 12, false, 0xa09e9e, "Verdana", 12);
	
				var logoutBtn:Button = new Button();
				logoutBtn.label = ResourceManager.getInstance().getString('localization', 'logout');
				logoutBtn.x = 680;
				logoutBtn.y = 10;
				_toolBar.addChild(logoutBtn);
				logoutBtn.addEventListener("click", function(event:Event) : void {
					Global.vars.app.doLogout();
					});
			}
		}

		public function showStartMenu() : void {
			_clearAllAndShowTitle();
		}

		public function showNavMenu() : void {
			_clearAllAndShowTitle();
			var viewTablesBtn:Button = new Button();
			viewTablesBtn.label = ResourceManager.getInstance().getString('localization', 'view_tables');
			viewTablesBtn.x = 200;
			viewTablesBtn.y = 10;
			_toolBar.addChild(viewTablesBtn);
			viewTablesBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doViewTables();
				});
			var newTableBtn:Button = new Button();
			newTableBtn.label = ResourceManager.getInstance().getString('localization', 'new_table');
			newTableBtn.x = 320;
			newTableBtn.y = 10;
			_toolBar.addChild(newTableBtn);
			newTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doNewTable();
				});
		}

		public function showTableMenu(showSettings:Boolean, showPref:Boolean) : void {
			_clearAllAndShowTitle();
			if (showSettings) {
				var tableSettingsBtn:Button = new Button();
				tableSettingsBtn.label = ResourceManager.getInstance().getString('localization', 'settings');
				tableSettingsBtn.x = 200;
				tableSettingsBtn.y = 10;
				_toolBar.addChild(tableSettingsBtn);
				tableSettingsBtn.addEventListener("click", function(event:Event) : void {
					Global.vars.app.changeTableSettings();
					});
			}
			if (showPref) {
				var tablePrefBtn:Button = new Button();
				tablePrefBtn.label = ResourceManager.getInstance().getString('localization', 'preferences');
				tablePrefBtn.x = 320;
				tablePrefBtn.y = 10;
				_toolBar.addChild(tablePrefBtn);
				tablePrefBtn.addEventListener("click", function(event:Event) : void {
					Global.vars.app.changeTablePref();
					});
			}
			var closeTableBtn:Button = new Button();
			closeTableBtn.label = ResourceManager.getInstance().getString('localization', 'close');
			closeTableBtn.x = 440;
			closeTableBtn.y = 10;
			_toolBar.addChild(closeTableBtn);
			closeTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doCloseTable();
				});
		}

		public function showObserverMenu(color:String, tableId:String) : void {
			_clearAllAndShowTitle();
			if (color != "") {
				var playBtn:Button = new Button();
				playBtn.label = (color == "Red") ? ResourceManager.getInstance().getString('localization', 'play_red')
										         : ResourceManager.getInstance().getString('localization', 'play_black');
				playBtn.x = 340;
				playBtn.y = 10;
				_toolBar.addChild(playBtn);
				var tid:String = tableId;
				playBtn.addEventListener("click", function(event:Event) : void {
					trace("selected tid: " + tid + " color: " + color);
					Global.vars.app.playGame(tid, color);
					});

			}
			var closeTableBtn:Button = new Button();
			closeTableBtn.label = ResourceManager.getInstance().getString('localization', 'close');
			closeTableBtn.x = 460;
			closeTableBtn.y = 10;
			_toolBar.addChild(closeTableBtn);
			closeTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doCloseTable();
				});
		}

		public function showGameMenu() : void {
			_clearAllAndShowTitle();
			var tablePrefBtn:Button = new Button();
			tablePrefBtn.label = ResourceManager.getInstance().getString('localization', 'preferences');
			tablePrefBtn.x = 200;
			tablePrefBtn.y = 10;
			_toolBar.addChild(tablePrefBtn);
			tablePrefBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.changeTablePref();
				});
			var resignTableBtn:Button = new Button();
			resignTableBtn.label = ResourceManager.getInstance().getString('localization', 'resign');
			resignTableBtn.x = 320;
			resignTableBtn.y = 10;
			_toolBar.addChild(resignTableBtn);
			resignTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doResignTable();
				});
			var drawTableBtn:Button = new Button();
			drawTableBtn.label = ResourceManager.getInstance().getString('localization', 'draw');
			drawTableBtn.x = 440;
			drawTableBtn.y = 10;
			_toolBar.addChild(drawTableBtn);
			drawTableBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doDrawTable();
				});
		}
	}
}
