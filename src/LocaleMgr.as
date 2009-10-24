package {
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;

	public class LocaleMgr {
		private static var _instance:LocaleMgr = null;
		private var _locale:String;
		private var _languages:Array;
		private var _defResources:Object;

		public function LocaleMgr() {
			_locale = "en_US";
			_languages = [];
			_defResources = {};
		}
		public static function instance():LocaleMgr {
			if (_instance == null) {
				_instance = new LocaleMgr();
			}
			return _instance;
		}
		public function setLocale(locale:String) : void {
			_locale = locale;
		}
		public function getLocale() : String {
			return _locale;
		}
		public function setLanguage(lang:String, res:Array ) : void {
			this._locale = lang;
			trace("_locale: " + _locale);
			this._languages[lang] = res;
			if (lang == "en_US") {
				_defResources = res;
			}
			Global.vars.app.initLoginPanel();
		}
		public function getResourceId(id:String) :String {
			var label:String = "";
			label = _languages[_locale][id];
			if (label == null || label == "") {
				label = _defResources[id];
				if (label == null || label == "") {
					var text:String = id.substr(4);
					label = id.charAt(3);
					label += text.toLowerCase();
				}
			}
			return label;
		}
		public function loadTextXML() : void {
			var xmlData:String = '<?xml version="1.0" encoding="utf-8"?>' + 
								 '<language id="en_US" description="English">' +  
								 '<resource id="ID_VIEWTABLES">View Tables</resource>' + 
								 '<resource id="ID_NEWTABLE">New Table</resource>' + 
								 '<resource id="ID_LOGIN">Login</resource>' + 
								 '<resource id="ID_GUESTLOGIN">Login As Guest</resource>' + 
								 '<resource id="ID_LOGOUT">Logout</resource>' + 
								 '<resource id="ID_REFRESH">Refresh</resource>' + 
								 '<resource id="ID_JOINTABLE">Join Table</resource>' + 
								 '<resource id="ID_PLAYRED">Play Red</resource>' + 
								 '<resource id="ID_PLAYBLACK">Play Black</resource>' + 
								 '<resource id="ID_CLOSE">Close</resource>' + 
								 '<resource id="ID_RESIGN">Resign</resource>' + 
								 '<resource id="ID_DRAW">Draw</resource>' + 
								 '<resource id="ID_SETTINGS">Settings</resource>' + 
								 '<resource id="ID_OK">Ok</resource>' + 
								 '<resource id="ID_CANCEL">Cancel</resource>' + 
								 '<resource id="ID_PREFERENCES">Preferences</resource>' + 
								 '</language>';
			this.parseXMLData(xmlData);
		}

		public function loadLocaleFile(locale:String) : void {
			var localeResFile:String = "http://www.playxiangqi.com/flex/locales/" + locale + ".xml";
			trace("locale file: " + localeResFile);
			Security.allowDomain("www.playxiangqi.com");
			var xmlLoader:URLLoader = new URLLoader();  
			xmlLoader.addEventListener(Event.COMPLETE, this.loadXML);  
			xmlLoader.load(new URLRequest(localeResFile));  
		}
		public function loadXML(evt:Event) : void {
			this.parseXMLData(evt.target.data);
		}
		
		public function parseXMLData(xmlData:String) : void {
			var resources:Array = new Array();
			var xmlDoc:XML = new XML(xmlData);
			trace("locale: " + xmlDoc.@id);
			var ids:XMLList = xmlDoc.resource;
			trace("number of resources: " + ids.length());
			for (var i:int = 0; i < ids.length(); i++) {
				trace(ids[i].@id + " = " + ids[i]);
				resources[ids[i].@id] = ids[i];
			}
			this.setLanguage(xmlDoc.@id, resources);
		}
	}
}
