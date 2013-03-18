/* 
Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). 
Provided "as is" in public domain with no guarantees 
Adapted to HaXe by CrabLabs. March 2013.
*/
package realtimelib;

import flash.events.Event;

/**
 * Creates game on FMS server and allows RTMFP/RTMP bridge communication
 * Warning: not implemented yet
 */
class RealtimeGame// implements IRealtimeGame
{
	public function new()
	{
		RealtimeGame();
	}
	public function RealtimeGame()
	{
		//TODO: implement function
	}
	
	public function connect(userName:String, userDetails:Object=null):Void
	{
		//TODO: implement function
	}
	
	public function close():Void
	{
		//TODO: implement function
	}
	
	public function sendMessage(message:String):Void
	{
		//TODO: implement function
	}
	
	public function sendMousePositions(x:Int, y:Int):Void
	{
		//TODO: implement function
	}
	
	public function sendMovement(direction:Int, down:Bool):Void
	{
		//TODO: implement function
	}
	
	public function sendPosition(position:Dynamic):Void
	{
		//TODO: implement function
	}
	
	public function sendRotation(rotation:Float):Void
	{
		//TODO: implement function
	}
	
	public function sendSpeed(speed:Float):Void
	{
		//TODO: implement function
	}
	
	public function sendObject(object:*):Void
	{
		//TODO: implement function
	}
	
	public function receiveMovement(peerID:String, direction:Int, down:Bool):Void
	{
		//TODO: implement function
	}
	
	public function receivePosition(peerID:String, position:Dynamic):Void
	{
		//TODO: implement function
	}
	
	public function receiveMousePositions(peerID:String, x:Int, y:Int):Void
	{
		//TODO: implement function
	}
	
	public function receiveRotation(peerID:String, rotation:Float):Void
	{
		//TODO: implement function
	}
	
	public function receiveSpeed(peerID:String, speed:Float):Void
	{
		//TODO: implement function
	}
	
	public function setReceiveMovementCallback(fnc:Function):Void
	{
		//TODO: implement function
	}
	
	public function setReceivePositionCallback(fnc:Function):Void
	{
		//TODO: implement function
	}
	
	public function setReceiveMousePositionCallback(fnc:Function):Void
	{
		//TODO: implement function
	}
	
	public function setReceiveRotationCallback(fnc:Function):Void
	{
		//TODO: implement function
	}
	
	public function setReceiveSpeedCallback(fnc:Function):Void
	{
		//TODO: implement function
	}
	
	public function get myUser():Dynamic
	{
		//TODO: implement function
		return null;
	}
	
	public function get userList():Dynamic
	{
		//TODO: implement function
		return null;
	}
	
	public function get userListArray():Array<Dynamic>
	{
		//TODO: implement function
		return null;
	}
	
	public function get userListMap():Dynamic
	{
		//TODO: implement function
		return null;
	}
	
	public function addEventListener(type:String, listener:Function, useCapture:Bool=false, priority:Int=0, useWeakReference:Bool=false):Void
	{
		//TODO: implement function
	}
	
	public function removeEventListener(type:String, listener:Function, useCapture:Bool=false):Void
	{
		//TODO: implement function
	}
	
	public function dispatchEvent(event:Event):Bool
	{
		//TODO: implement function
		return false;
	}
	
	public function hasEventListener(type:String):Bool
	{
		//TODO: implement function
		return false;
	}
	
	public function willTrigger(type:String):Bool
	{
		//TODO: implement function
		return false;
	}
}