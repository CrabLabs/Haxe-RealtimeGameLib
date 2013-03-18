/* 
Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). 
Provided "as is" in public domain with no guarantees 
Adapted to HaXe by CrabLabs. March 2013.
*/
package realtimelib;

import flash.text.TextField;
import flash.utils.getTimer;

/**
 * Logger class
 * define txtArea and display logs
 */
class Logger
{
	
	public static var txtArea:TextField;
	
	public function new()
	{
		Logger();
	}

	public function Logger()
	{
	}
	
	public static function log(str:String):Void
	{
		//trace(str);
		if(txtArea!=null){
			txtArea.appendText(getTimer()+": "+str+"\n");
			txtArea.scrollV = txtArea.maxScrollV;
		}
	}
	
	public static function write(str:String):Void
	{
		if(txtArea!=null){
			txtArea.appendText(str);
			txtArea.scrollV = txtArea.maxScrollV;
		}
	}
}