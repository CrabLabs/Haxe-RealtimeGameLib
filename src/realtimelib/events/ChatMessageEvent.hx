/* 
Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). 
Provided "as is" in public domain with no guarantees 
Adapted to HaXe by CrabLabs. March 2013.
*/
package realtimelib.events;

import realtimelib.session.UserObject;

import flash.events.Event;

/**
 * transmits chat messages in/out of a visual component to P2PSession
 */
class ChatMessageEvent extends Event
{
	
	public static const CHAT_MESSAGE:String = "chatMessage";
	public static const OPEN_PRIVATE_CHAT:String = "openPrivateChat";
	
	public var message:Dynamic;
	public var userName:String;
	public var details:Dynamic;
	public var receiver:Dynamic;
	
	public function new(type:String, message:Dynamic, bubbles:Bool=false, cancelable:Bool=false)
	{
		ChatMessageEvent(type, message, bubbles, cancelable);
	}

	public function ChatMessageEvent(type:String, message:Dynamic, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		
		this.message = message;/*
		this.userName = userName;
		this.receiver = receiver;
		this.details = details;*/
	}
}
