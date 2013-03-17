package realtimelib.events;

import flash.events.Event;

class ConnectionStatusEvent extends Event
{
	
	// EVENT
	public static const STATUS_CHANGE:String = "statusChange";
	
	// STATUSES
	public static const UNINITIALIZED:UInt = 0xCCCCCC;
	public static const DISCONNECTED:UInt = 0xFF0000;
	public static const CONNECTING:UInt = 0xFFFF00;
	public static const CONNECTED:uint = 0x008000;
	public static const CONNECTED_GROUP:UInt = 0x00FF00;
	public static const FAILED:UInt = 0x800000;	
	
	public var status:UInt = UNINITIALIZED;
	
	public function ConnectionStatusEvent(type:String, status:UInt, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		this.status = status;
	}	
	
	override public function clone():Event
	{
		return new ConnectionStatusEvent(type, status, bubbles, cancelable);
	}
}