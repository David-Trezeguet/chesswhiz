package {

	import flash.display.*;
	import flash.events.Event;
	
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.NumericStepper;
	import mx.core.UIComponent;

	public class TableSettingsDialog extends Panel {
		public var tableId:String;
		public var mcParent:UIComponent;
		public var cbRated:CheckBox;
		public var nsGame:NumericStepper;
		public var nsMove:NumericStepper;
		public var nsExtra:NumericStepper;
		public var curSettings:Object;
		public var mcClose:Sprite;
		//public var dWidth;
		//public var dHeight;
		public function TableSettingsDialog(mc:UIComponent, tid:String) {
			this.mcParent = mc;
			this.name = "tableSettingsPanel";
			this.tableId = tid;
			this.x = 120;
			this.y = 120;
			mc.addChild(this);
			this.title = "Table Settings";

			this.curSettings = {}
			var tableObj:Table = Global.vars.app.getTable(tableId);
			if (tableObj) {
				this.curSettings = tableObj.getSettings();
			}
		}
		public function display() : void {
			var padding:uint = 10;
			var currHeight:uint = 0;
			var currWidth:uint = 0;
			var verticalSpacing:uint = 20;
			currHeight += 40;
			var hBox:HBox = new HBox();
			this.addChild(hBox);

			var p1:Panel = new Panel();
			hBox.addChild(p1);
			p1.title = "Timers";
			var hb1:VBox = new VBox();
			p1.addChild(hb1);
			Util.createTextField(hb1, "Game Time: ", padding*2, padding + currHeight, false, 0x000000, "Verdana", 12);
			var b1:HBox = new HBox();
			hb1.addChild(b1);
			var st:NumericStepper = Util.createStepper(b1, 5, 30, this.curSettings["gametime"]/60, padding*2, padding + currHeight, 50);
			this.nsGame = st;
			Util.createTextField(b1, "min", st.x + st.width, padding + currHeight, false, 0x000000, "Verdana", 12);
			currHeight += 2*verticalSpacing;
			Util.createTextField(hb1, "Move Time: ", padding*2, padding + currHeight, false, 0x000000, "Verdana", 12);
			currHeight += verticalSpacing;
			var b2:HBox = new HBox();
			hb1.addChild(b2);
			st = Util.createStepper(b2, 30, 300, this.curSettings["movetime"], padding*2, padding + currHeight, 50);
			this.nsMove = st;
			Util.createTextField(b2, "sec: ", st.x + st.width, padding + currHeight, false, 0x000000, "Verdana", 12);
			currHeight += 2*verticalSpacing;
			Util.createTextField(hb1, "Free Time: ", padding*2, padding + currHeight, false, 0x000000, "Verdana", 12);
			currHeight += verticalSpacing;
			var b3:HBox = new HBox();
			hb1.addChild(b3);
			st = Util.createStepper(b3, 10, 60, this.curSettings["extratime"], padding*2, padding + currHeight, 50);
			this.nsExtra = st;
			Util.createTextField(b3, "sec", st.x + st.width, padding + currHeight, false, 0x000000, "Verdana", 12);
			currHeight += 2*verticalSpacing;

			var p2:Panel = new Panel();
			p2.title = "Game Type";
			hBox.addChild(p2);
			this.cbRated = Util.createCheckBox(p2, "Rated", currWidth + padding*2, padding + currHeight);
			currHeight += 2*verticalSpacing;
			if (this.curSettings["rated"]) {
				this.cbRated.selected = true;
			}
			currHeight += 90;
			var cb:ControlBar = new ControlBar();
			this.addChild(cb);
			var btn:Button = Util.createButton(cb, "ok", LocaleMgr.instance().getResourceId("ID_OK"), currWidth + padding, currHeight + padding, 20, 50, true, handlerOK);
			Util.createButton(cb, "cancel", LocaleMgr.instance().getResourceId("ID_CANCEL"), btn.x + btn.width + padding, currHeight + padding, 20, 80, true, handlerCANCEL);
		}
		public function handlerOK(event:Event) : void {
			var settings:Object = {}
			settings["gametime"] = nsGame.value * 60;
			settings["movetime"] = nsMove.value;
			settings["extratime"] = nsExtra.value;
			settings["rated"] = cbRated.selected;
			mcParent.removeChild(mcParent.getChildByName("tableSettingsPanel"));
			var tableObj:Table = Global.vars.app.getTable(this.tableId);
			if (tableObj) {
				tableObj.updateSettings(settings);
			}
		}
		public function handlerCANCEL(event:Event) : void {
			mcParent.removeChild(mcParent.getChildByName("tableSettingsPanel"));
		}

	}
}
