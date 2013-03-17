package realtimelib.session;

import flash.events.IEventDispatcher;
import flash.net.NetConnection;

interface ISession extends IEventDispatcher
{
	public var connection (getConnection, setConnection):NetConnection;
	public var myUser (getMyUser, setMyUser):UserObject;

	function connect(userName:String,userDetails:Dynamic=null):Void;
	function close():void;
	
	function getConnection():NetConnection;
	function setConnection(value:NetConnection):Void;
	
	function getMyUser():UserObject;
	function setMyUser(value:UserObject):Void;
}