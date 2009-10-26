package {
	import flash.display.*;
	import flash.events.Event;
	import flash.external.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
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
	import mx.core.UIComponent;

	public class Util {

		public static function createButton(panel:UIComponent, name:String, label:String, x:Number, y:Number, h:Number, w:Number, enabled:Boolean, handler:Function) : Button
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
			if (handler != null) {
				button.addEventListener("click", handler);
			}
			return button;
		}
				
		public static function createTextField(panel:UIComponent, text:String, x:Number, y:Number, border:Boolean, color:uint, font:String, fontSize:uint) : Label {
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
		public static function createTextInput(panel:UIComponent, maxChars:int, x:Number, y:Number, h:Number, w:Number, border:Boolean, color:uint, font:String, fontSize:int) : TextInput {
			var unameInput:TextInput = new TextInput();
			unameInput.x = x;
			unameInput.y = y;
			unameInput.height = h;
			unameInput.width = w;
			unameInput.maxChars = maxChars;
            panel.addChild(unameInput);
			return unameInput;
		}
		public static function createTextArea(panel:UIComponent, text:String, x:Number, y:Number, height:Number, width:Number, border:Boolean, color:uint, bgColor:uint, font:String, fontSize:int, editable:Boolean, alpha:int):TextArea {
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
		public static function createList(panel:UIComponent, x:Number, y:Number, height:Number, width:Number, border:Boolean, color:uint, bgColor:uint, font:String, fontSize:int ):List {
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
		public static function createMessageBox(panel:UIComponent, msg:String, callback:Function):void {
			var msgbox:Panel = new Panel();
			Util.createTextField(msgbox, msg, 20, 10, false, 0xa09e9e, "Verdana", 12);
			var okBtn:Button = new Button();
			okBtn.label = "ok";
			okBtn.x = 150;
			okBtn.y = 40;
			msgbox.addChild(okBtn);

			function okBtnClickHandler(event:Event) : void {
				callback();
			}
			okBtn.addEventListener("click", okBtnClickHandler);
			panel.addChild(msgbox);
		}

		/**
		 * Read the QueryString and FlashVars.
		 *
		 *  @References: This function is directly copied from "ShortFusion Blog":
		 *  http://blog.shortfusion.com/index.cfm/2009/1/14/Flex-and-Flash--Reading-The-Query-String-and-FlashVars
		 * 
		 */
		public static function readQueryString():Array {
			var params:Array = new Array();
			try  {
				var all:String = ExternalInterface.call("window.location.href.toString");
				var queryString:String = ExternalInterface.call("window.location.search.substring", 1);
				if(queryString) {
					var allParams:Array = queryString.split('&');
					for (var i:int = 0, index:int = -1; i < allParams.length; i++) {
						var keyValuePair:String = allParams[i];
						if((index = keyValuePair.indexOf("=")) > 0) {
							var paramKey:String = keyValuePair.substring(0,index);
							var paramValue:String = keyValuePair.substring(index+1);
							var decodedValue:String = decodeURIComponent(paramValue);
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
		public static function createCheckBox(mcParent:UIComponent, cbText:String, x:uint, y:uint) : CheckBox {
			var cb1:CheckBox = new CheckBox();
			cb1.label = cbText;
			cb1.x = x;
			cb1.y = y;
			mcParent.addChild(cb1);
			return cb1;
		}
		public static function createImage(mcParent:UIComponent, imageSrc:String, x:Number, y:Number) : Image {
			var image:Image = new Image();
			image.source = imageSrc;
			image.y = y;
			image.x = x;
			mcParent.addChild(image);
			return image;
		}
		public static function createRadioButton(mcParent:UIComponent, rbLabel:String, rbg:String, x:Number, y:Number):RadioButton {
            var rb:RadioButton = new RadioButton();
            rb.label = rbLabel;
            mcParent.addChild(rb);
            //rb.move(x, y);
            rb.groupName  = rbg;
			return rb;
        }

		public static function createStepper(mcParent:UIComponent, step:Number, max:Number, initValue:Number, x:Number, y:Number, width:Number):NumericStepper {
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

		public static function createLabel(mcParent:UIComponent, labelText:String, x:uint, y:uint):Label {
			var label:Label = new Label();
            label.text = labelText;
            //label.autoSize = TextFieldAutoSize.LEFT;
            label.move(x, y);
			mcParent.addChild(label);
			return label;
		}
		public static function drawLine(panel:Sprite, startX:int, startY:int, endX:int, endY:int, w:Number, color:uint):void
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
