package {
	import flash.display.*;
	import flash.events.Event;
	import flash.external.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.NumericStepper;
	import mx.controls.RadioButton;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.ScrollPolicy;

	public class Util {

		public static function createButton(panel, name, label, x, y, h, w, enabled, handler) 
		{
			var button:Button = new Button();
			button.label = label;
			button.name = name;
			button.x = x;
			button.y = y;
			button.width = w;
			button.height = h;
			button.enabled = enabled;
			panel.addChild(button);
			if (handler) {
				button.addEventListener("click", handler);
			}
			return button;
		}
				
		public static function createTextField(panel, text, x, y, border, color, font, fontSize) {
			var label:Label = new Label();
            var format:TextFormat = new TextFormat();
            if (panel) {
                panel.addChild(label);
            }
			label.x = x;
			label.y = y;
			label.text = text;
			label.setStyle("color", color);
			label.setStyle("fontFamily", font);
			label.setStyle("fontSize", fontSize);
			
			return label;
		}
		public static function createTextInput(panel, maxChars, x, y, h, w, border, color, font, fontSize) {
			var unameInput:TextInput = new TextInput();
			unameInput.x = x;
			unameInput.y = y;
			unameInput.height = h;
			unameInput.width = w;
			unameInput.maxChars = maxChars;
            panel.addChild(unameInput);
			return unameInput;
		}
		public static function createTextArea(panel, text, x, y, height, width, border, color, bgColor, font, fontSize, editable, alpha):TextArea {
		    var myTextArea:TextArea = new TextArea();
			myTextArea.wordWrap = true;
			myTextArea.text = text;
			myTextArea.width = width;
            myTextArea.height = height;
			myTextArea.editable = editable;
			myTextArea.x = x;
			myTextArea.y = y;
			myTextArea.alpha = alpha;
			var format:TextFormat = new TextFormat();
            format.font = font;
            format.color = color;
            format.size = fontSize;
			myTextArea.setStyle("textFormat", format);
			//myTextArea.setStyle("backgroundColor", bgColor);
			myTextArea.verticalScrollPolicy = ScrollPolicy.AUTO;
			myTextArea.horizontalScrollPolicy = ScrollPolicy.AUTO;
			panel.addChild(myTextArea);
			return myTextArea;
		}
		public static function createList(panel, x, y, height, width, border, color, bgColor, font, fontSize ):List {
		    var myList:List = new List();
			myList.width = width;
            myList.height = height;
			myList.x = x;
			myList.y = y;
			var format:TextFormat = new TextFormat();
            format.font = font;
            format.color = color;
            format.size = fontSize;
			myList.setStyle("textFormat", format);
			myList.setStyle("backgroundColor", bgColor);
			myList.verticalScrollPolicy = ScrollPolicy.AUTO;
			myList.horizontalScrollPolicy = ScrollPolicy.AUTO;
			panel.addChild(myList);
			return myList;
		}

		public static function createGlowFilter():GlowFilter {
            var color:Number = 0x33CCFF;
            var alpha:Number = 0.8;
            var blurX:Number = 10;
            var blurY:Number = 10;
            var strength:Number = 2;
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = BitmapFilterQuality.HIGH;

            return new GlowFilter(color,
                                  alpha,
                                  blurX,
                                  blurY,
                                  strength,
                                  quality,
                                  inner,
                                  knockout);
        }
		public static function createMessageBox(panel, msg, callback):void {
			
			var msgbox:Panel = new Panel();
			Util.createTextField(msgbox, msg, 20, 10, false, 0xa09e9e, "Verdana", 12);
			var okBtn:Button = new Button();
			okBtn.label = "ok";
			okBtn.x = 150;
			okBtn.y = 40;
			msgbox.addChild(okBtn);

			function okBtnClickHandler(event:Event) {
				callback();
			}
			okBtn.addEventListener("click", okBtnClickHandler);
			panel.addChild(msgbox);
		}
		
		public static function readQueryString():Array {
			var params = new Array();
			try  {
				var all = ExternalInterface.call("window.location.href.toString");
				var queryString = ExternalInterface.call("window.location.search.substring", 1);
				if(queryString) {
					var allParams:Array = queryString.split('&');
					for (var i = 0, index = -1; i < allParams.length; i++) {
						var keyValuePair:String = allParams[i];
						if((index = keyValuePair.indexOf("=")) > 0) {
							var paramKey:String = keyValuePair.substring(0,index);
							var paramValue:String = keyValuePair.substring(index+1);
							var decodedValue = decodeURIComponent(paramValue);
							params[paramKey] = decodedValue;
						}
					}
				}
			}
			catch(e:Error) {
				trace("Running in Standalone player.");
			}
			return params;
		}
		public static function createCheckBox(mcParent, cbText, x:uint, y:uint) {
			var cb1:CheckBox = new CheckBox();
			cb1.label = cbText;
			cb1.x = x;
			cb1.y = y;
			mcParent.addChild(cb1);
			return cb1;
		}
		public static function createImage(mcParent, imageSrc, x, y) {
			var image:Image = new Image();
			image.source = imageSrc;
			image.y = y;
			image.x = x;
			mcParent.addChild(image);
			return image;
		}
		public static function createRadioButton(mcParent, rbLabel:String, rbg:String, x, y):RadioButton {
            var rb:RadioButton = new RadioButton();
            rb.label = rbLabel;
            mcParent.addChild(rb);
            //rb.move(x, y);
            rb.groupName  = rbg;
			return rb;
        }

		public static function createStepper(mcParent, step, max, initValue, x, y, width):NumericStepper {
            var ns:NumericStepper = new NumericStepper();
            ns.stepSize = step;
            ns.minimum = 0;
            ns.maximum = max;
            ns.width = width;
			ns.value = initValue;
            ns.move(x, y);
            mcParent.addChild(ns);
			return ns;
        }

		public static function createLabel(mcParent, labelText:String, x:uint, y:uint):Label {
			var label = new Label();
            label.text = labelText;
            label.autoSize = TextFieldAutoSize.LEFT;
            label.move(x, y);
			mcParent.addChild(label);
			return label;
		}
		public static function drawLine(panel:Sprite, startX:int, startY:int, endX:int, endY:int, w, color):void
		{
			panel.graphics.lineStyle(w, color);
			panel.graphics.moveTo(startX, startY);
			panel.graphics.lineTo(endX, endY);
		}

        public static function sortNumeric(obj1:Object, obj2:Object, key:String):int {
            var value1:Number = (obj1[key] == '' || obj1[key] == null) ? null : new Number(obj1[key]);
            var value2:Number = (obj2[key] == '' || obj2[key] == null) ? null : new Number(obj2[key]);

            if (value1 < value2) {
                return -1;
            } else if (value1 > value2) {
                return 1;
            } else {
                return 0;
            }
        }

	}
}
