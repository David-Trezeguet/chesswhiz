package {

	import flash.display.*;
	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.containers.VBox;
	import mx.controls.ColorPicker;
	import mx.controls.Image;
	import mx.controls.RadioButton;
	import mx.events.ColorPickerEvent;

	public class TablePrefDialog extends Panel {
		public var tableId:String;
		public var mcParent;
		public var dWidth;
		public var dHeight;
		public var rbgSound:Array;
		public var rbgPieces:Array;
		public var curPref:Object;
		public var mcClose:Sprite;
		public var colorPicker:ColorPicker;
		public var preview:Panel;
		public var selectedPieceSet:int;
		public function TablePrefDialog(mc, tid, pref) {
			this.mcParent = mc;
			this.name = "tablePrefPanel";
			this.tableId = tid;
			this.x = 120;
			this.y = 120;
			this.title = "Table Preferences";
			this.curPref = pref;
			this.selectedPieceSet = 1;
			mc.addChild(this);
		}
		public function display() {
			var hBox = new HBox();
			this.addChild(hBox);

			var p1:Panel = new Panel();
			hBox.addChild(p1);
			this.rbgSound = new Array();
			p1.title = "Sound";
			var hb1:HBox = new HBox();
			hb1.setStyle("padding", 4);
			p1.addChild(hb1);
			var rb:RadioButton = Util.createRadioButton(hb1, "On", "sound", 0, 0);
            rb.value = 0;
            this.rbgSound[0] = rb;
            var img:Image = new Image();
            img.source = Global.vars.app.baseURI + "images/player_volume.png";
            hb1.addChild(img);
			
			var hb2 = new HBox();
			p1.addChild(hb2);
			rb = Util.createRadioButton(hb2, "Off", "sound", 0, 0);
            rb.value = 1;
            this.rbgSound[1] = rb;
            img = new Image();
            img.source = Global.vars.app.baseURI + "images/volume_mute.png";
            hb2.addChild(img);
			if (this.curPref["sound"]) {
				this.rbgSound[0].selected = true;
			} else {
				this.rbgSound[1].selected = true;
			}

			var p2 = new Panel();
			hBox.addChild(p2);
			p2.title = "Pieces";
			this.rbgPieces = new Array();
			var hb3 = new HBox();
			p2.addChild(hb3);
			rb = Util.createRadioButton(hb3, "", "pieceset", 0, 0);
            rb.value = 1;
            this.rbgPieces[0] = rb;
            img = new Image();
            img.source = Global.vars.app.baseURI + "images/pieces/1/rking.png";
            hb3.addChild(img);
			
			var hb4 = new HBox();
			p2.addChild(hb4);
			rb = Util.createRadioButton(hb4, "", "pieceset", 0, 0);
            rb.value = 2;
            this.rbgPieces[1] = rb;
            img = new Image();
            img.source = Global.vars.app.baseURI + "images/pieces/2/rking.png";
            hb4.addChild(img);

			var hb5 = new HBox();
			p2.addChild(hb5);
			rb = Util.createRadioButton(hb5, "", "pieceset", 0, 0);
            rb.value = 3;
			this.rbgPieces[2] = rb;
            img = new Image();
            img.source = Global.vars.app.baseURI + "images/pieces/3/rking.png";
            hb5.addChild(img);
            selectedPieceSet = this.curPref["pieceskinindex"];
            this.rbgPieces[selectedPieceSet - 1].selected = true;

			var vBox = new VBox();
			hBox.addChild(vBox);
			var p3 = new Panel();
			vBox.addChild(p3);
			p3.title = "Board Color";
			colorPicker = new ColorPicker();
			colorPicker.editable = false;
			colorPicker.x = 0;
			colorPicker.y = 0;
			colorPicker.selectedColor = this.curPref["boardcolor"];
			p3.addChild(colorPicker);
			
			this.preview = new Panel();
			this.preview.width = 100;
			this.preview.height = 120;
			this.preview.title = "Preview";
			vBox.addChild(this.preview);
			displayPreview(0, 0, this.curPref["boardcolor"]);

			var hBox2 = new HBox();
			this.addChild(hBox2);
			var btn = Util.createButton(hBox2, "ok", LocaleMgr.instance().getResourceId("ID_OK"), 0, 0, 20, 50, true, handlerOK);
			Util.createButton(hBox2, "cancel", LocaleMgr.instance().getResourceId("ID_CANCEL"), btn.x + btn.width, 0, 20, 80, true, handlerCANCEL);

			for (var i:int = 0; i < this.rbgPieces.length; i++) {
				this.rbgPieces[i].addEventListener(Event.CHANGE, handleChangePieceSet);
			}
			this.colorPicker.addEventListener(ColorPickerEvent.CHANGE, handleChangePreview);
		}

		public function handleChangePieceSet(event:Event) {
			this.selectedPieceSet = (RadioButton)(event.target).value;
			trace("selected piece index: " + this.selectedPieceSet);
			this.displayPreview(this.preview.x, this.preview.y, this.colorPicker.selectedColor);
		}

		public function handleChangePreview(event:Event) {
			this.displayPreview(this.preview.x, this.preview.y, this.colorPicker.selectedColor);
		}
		public function displayPreview(x, y, color) {
			if (this.preview) {
				while(this.preview.numChildren) {
					this.preview.removeChildAt(0);
				}
			}
			var canvas = new Canvas();
			this.preview.addChild(canvas);
			canvas.graphics.beginFill(color);
			canvas.graphics.drawRect(canvas.x, canvas.y, 80,80);
			Util.drawLine(canvas, 40, 0, 40, 80, 1, 0xFFFFFF);
			Util.drawLine(canvas, 0, 40, 80, 40, 1, 0xFFFFFF);
            var img:Image = new Image();
            img.source = Global.vars.app.baseURI + "images/pieces/" + this.selectedPieceSet + "/rking.png";
            img.x = 20;
            img.y = 20;
            canvas.addChild(img);
			canvas.graphics.endFill();
		}

		public function handlerOK(event:Event) {
			var pref:Object = {};
			if (rbgSound[0].selected) {
				pref["sound"] = true;
			} else {
				pref["sound"] = false;
			}
			pref["pieceskinindex"] = this.selectedPieceSet;
			pref["boardcolor"] = this.colorPicker.selectedColor;
			mcParent.removeChild(mcParent.getChildByName("tablePrefPanel"));
			var tableObj = Global.vars.app.getTable(this.tableId);
			if (tableObj) {
				tableObj.updatePref(pref);
			}
			Global.vars.app.updatePref(pref);
		}
		public function handlerCANCEL(event:Event) {
			mcParent.removeChild(mcParent.getChildByName("tablePrefPanel"));
		}
	}
}
