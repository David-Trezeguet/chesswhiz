/***************************************************************************
 *  Copyright 2009-2010 Bharatendra Boddu <bharathendra@yahoo.com>         *
 *                      Huy Phan  <huyphan@playxiangqi.com>                *
 *                                                                         * 
 *  This file is part of ChessWhiz.                                        *
 *                                                                         *
 *  ChessWhiz is free software: you can redistribute it and/or modify      *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, either version 3 of the License, or      *
 *  (at your option) any later version.                                    *
 *                                                                         *
 *  ChessWhiz is distributed in the hope that it will be useful,           *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with ChessWhiz.  If not, see <http://www.gnu.org/licenses/>.     *
 ***************************************************************************/

package
{
	import flash.external.ExternalInterface;

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

	    /**
	     * A helper to escape invalid characters:
	     *  + Percent    ("%") => "%25"
	     *  + Ampersand  ("&") => "%26"
	     *  + Semi-colon (";") => "%3B" 
	     */
		public static function escapeURL(value:String) : String
		{
		    var sResult:String = "";
		    var aChar:String;
		    for (var i:int = 0; i < value.length; ++i)
		    {
		        aChar = value.charAt(i);
		        switch ( aChar )
		        {
		            case '%': sResult += "%25"; break;
		            case '&': sResult += "%26"; break;
		            case ';': sResult += "%3B"; break;
		            default:  sResult += aChar; break;
		        }
		    }
		    return sResult;
		}

	    /**
	     * A helper to unescape invalid characters:
	     *  + "%25" => Percent    ("%")
	     *  + "%26" => Ampersand  ("&")
	     *  + "%3B" => Semi-colon (";")
	     */
		public static function unescapeURL(value:String) : String
		{
		    var sResult:String = "";
		    var aChar:String;
		    var token:String;
		    for (var i:int = 0; i < value.length; ++i)
		    {
		        aChar = value.charAt(i);
		        if ( aChar != '%' )
		        {
		            sResult += aChar;
		            continue;
		        }
		        token = aChar; // Reset.
		        
		        if ( ++i == value.length )
		        {
		            sResult += token;
		            break;
		        }
		        token += value.charAt(i);

		        if ( ++i == value.length )
		        {
		            sResult += token;
		            break;
		        }
		        token += value.charAt(i);

		        if      ( token == "%25" ) { sResult += '%';   }
		        else if ( token == "%26" ) { sResult += '&';   }
		        else if ( token == "%3B" ) { sResult += ';';   }
		        else                       { sResult += token; }
		    }

		    return sResult;
		}
	}
}
