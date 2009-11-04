﻿package {
	import flash.display.*;
	import flash.external.*;

	public class Util
	{
		/**
		 * Read the QueryString and FlashVars.
		 *
		 *  @References: This function is directly copied from "ShortFusion Blog":
		 *  http://blog.shortfusion.com/index.cfm/2009/1/14/Flex-and-Flash--Reading-The-Query-String-and-FlashVars
		 * 
		 */
		public static function readQueryString() : Array
		{
			var params:Array = [];
			try  {
				var all:String = ExternalInterface.call("window.location.href.toString");
				var queryString:String = ExternalInterface.call("window.location.search.substring", 1);
				if (queryString)
				{
					const allParams:Array = queryString.split('&');
					for (var i:int = 0, index:int = -1; i < allParams.length; i++) {
						var keyValuePair:String = allParams[i];
						if ( (index = keyValuePair.indexOf("=")) > 0 )
						{
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

        public static function sortNumeric(obj1:Object, obj2:Object, key:String) : int
        {
            const value1:Number = (obj1[key] == '' || obj1[key] == null) ? null : new Number(obj1[key]);
            const value2:Number = (obj2[key] == '' || obj2[key] == null) ? null : new Number(obj2[key]);

			if (value1 < value2) { return -1 };
			if (value1 > value2) { return 1; }
			return 0;
        }

	}
}
