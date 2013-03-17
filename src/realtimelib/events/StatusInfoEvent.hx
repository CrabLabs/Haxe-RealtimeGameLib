/* 
Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). 
Provided "as is" in public domain with no guarantees 
Adapted to HaXe by CrabLabs. March 2013.
*/
package realtimelib.events;

import flash.events.Event;

class StatusInfoEvent extends Event
{
	public static const STATUS_INFO:String = "statusInfo";

	public var message:String;
	
	public function new(type:String, message:String, bubbles:Bool=false, cancelable:Bool=false)
	{
		StatusInfoEvent(type, message, bubbles, cancelable);
	}

	public function StatusInfoEvent(type:String, message:String, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
	
		this.message = message;
	}
}