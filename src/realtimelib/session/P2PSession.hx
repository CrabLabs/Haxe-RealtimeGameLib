/* Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). Provided "as is" in public domain with no guarantees */
package realtimelib.session;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.net.NetGroupReceiveMode;
import flash.net.NetGroupSendMode;
import flash.net.NetGroupSendResult;
import flash.net.NetStream;

import realtimelib.events.ChatMessageEvent;
import realtimelib.events.ConnectionStatusEvent;
import realtimelib.events.PeerStatusEvent;
import realtimelib.events.StatusInfoEvent;
import realtimelib.session.ISession;

[Event(name="statusInfo",type="realtimelib.events.StatusInfoEvent")]
[Event(name="chatMessage",type="realtimelib.events.ChatMessageEvent")]
[Event(name="openPrivateChat",type="realtimelib.events.ChatMessageEvent")]
[Event(name="connect", type="flash.events.Event")]
[Event(name="close", type="flash.events.Event")]
[Event(name="netStatus",type="flash.events.NetStatus")]
[Event(name="statusChange",type="flash.events.ConnectionStatusEvent")]
[Event(name="userAdded",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="userRemoved",type="com.adobe.fms.PeerStatusEvent")]
/**
 * controls a P2P session, NetConnection, NetGroup and all related management
 */
public class P2PSession extends EventDispatcher implements ISession
{		
	public static var debugMode:Bool = false;

	public var status:uint;
	public var userName:String;
	public var userDetails:Dynamic;
	
	private var _connection:NetConnection;
	private var _myUser:UserObject;		
	private var _mainChat:GroupChat;
	
	private var _chatSequence:uint = 0;
	private var _serverAddr:String;
	private var _groupName:String;
	private var _gameNetConnectionClient:Class;
	
	public function new(serverAddr:String,groupName:String="defaultGroup", gameNetConnectionClient:Class=null)
	{
		P2PSession(serverAddr,groupName, gameNetConnectionClient));
	}
	
	public function P2PSession(serverAddr:String,groupName:String="defaultGroup", gameNetConnectionClient:Class=null)
	{
		_initialize(serverAddr, groupName, gameNetConnectionClient);
	}
	private function _initialize(serverAddr:String, groupName:String="defaultGroup", gameNetConnectionClient:Class=null):Void
	{
		_serverAddr = serverAddr;
		_groupName = groupName;
		_gameNetConnectionClient = gameNetConnectionClient;
	}
	
	/**
	 * Connect to Rendezvous Service
	 */
	public function connect(userName:String,userDetails:Dynamic=null):Void
	{
		_storeUserInformation(userName, userDetails);
		
		_startNetConnection();
		
		changeStatus(ConnectionStatusEvent.CONNECTING);
	}
	private function _startNetConnection():Void
	{
		connection = new NetConnection();
		
		if (_gameNetConnectionClient)
		{
			connection.client = new _gameNetConnectionClient(connection, this);
		}
		
		connection.addEventListener(NetStatusEvent.NET_STATUS, netStatus, false, 0, true);
		connection.connect(_serverAddr, userName, userDetails);
	}
	private function _storeUserInformation(userName:String, userDetails:Dynamic):Void
	{
		this.userName = userName;
		this.userDetails = userDetails;
	}
	
	
	
	/**
	 * Close connection and reset
	 */
	public function close():Void
	{
		connection.close();
		connection = null;
	}
	
	/**
	 * Join group
	 */
	public function join(groupName:Float):Void
	{
		_groupName = groupName.toString();
		
		const userObject:UserObject = _getUserObject();
		
		_startMainChat(userObject);
	}
	private function _startMainChat(userObject:UserObject):Void
	{
		const groupspec:String = getGroupSpec().groupspecWithAuthorizations();
		
		mainChat = new GroupChat(this, groupspec, userObject.name, userObject.details);			
		mainChat.addEventListener(NetStatusEvent.NET_STATUS, netStatus, false, 0, true);
		mainChat.addEventListener(PeerStatusEvent.USER_ADDED, _handlePeerStatusEvent, false, 0, true);
		mainChat.addEventListener(PeerStatusEvent.USER_REMOVED, _handlePeerStatusEvent, false, 0, true);
	}
	private function _getUserObject():UserObject
	{
		if (null == myUser)
		{
			myUser = new UserObject();
			myUser.name = userName;
			myUser.details = userDetails;
		}
		
		return myUser;
	}
	private function _handlePeerStatusEvent(event:PeerStatusEvent):Void
	{
		dispatchEvent(event);
	}
	
	/**
	 * calls other users using Directed Routing and opens chat
	 */
	public function openPrivateChat(withUsers:Vector.<UserObject>):Void{
		
		var groupName:String = "GROUP"+Math.round(Math.random()*100000);
		
		var arr:Array = new Array();
		for(ia in 0...withUsers.length){
			arr.push(withUsers[ia].name);
		}
		arr.sort();
		groupName = arr.join("/");
		
		for(i in 0...withUsers.length){
			
			var msgObj:Dynamic = new Dynamic();
			msgObj.username = myUser.name;
			msgObj.type = "openPrivateChat";
			msgObj.sender = myUser;
			msgObj.sequence = _chatSequence++;
			msgObj.withUsers = withUsers;
			msgObj.groupName = groupName;
			
			debugWrite("chatSendPrivate "+withUsers[i].address+" - "+msgObj.type)
			
			debugWrite(mainChat.sendToNearest(msgObj,mainChat.convertPeerIDToGroupAddress(withUsers[i].id)));
		}
	}
	
	/**
	 * this is getting called by openPrivateChat through Directed Routing
	 */
	public function openPrivateChatReceive(message:Dynamic):Void{
		statusWrite("openPrivateChatReceive")
		
		dispatchEvent(new ChatMessageEvent(ChatMessageEvent.OPEN_PRIVATE_CHAT, message));
	}
	
	public function getUserCount():Float{
		if(mainChat==null){
			return 0;
		}
		return mainChat.estimatedMemberCount;
	}
	
	public function getNeighborCount():Float{
		if(mainChat==null){
			return 0;
		}
		return mainChat.neighborCount;
	}
	
	// Handlers
	/**
	 * Dispatched when user disconnects from Stratus
	 */
	protected function onDisconnect():Void{
		dispatchEvent(new Event(Event.CLOSE));
	}
	
	/**
	 * when user connects to a group, create a user Dynamic and assign groupAddress, peerID...
	 */
	public function onNetGroupConnect():Void{
		
		myUser.id = connection.nearID;
		myUser.address = mainChat.convertPeerIDToGroupAddress(connection.nearID);

		// DEVEL TRACE
		debugWrite("_");
		debugWrite("groupAddress: "+myUser.address);
		debugWrite("_");
		debugWrite("peerID: "+myUser.id);
		debugWrite("_");
		
		dispatchEvent(new Event(Event.CONNECT));
	}
	
	public function returnUser():UserObject{
		return myUser;
	}
	
	public function get isConnected():Bool{
		if(status == ConnectionStatusEvent.CONNECTED_GROUP){
			return true;
		}
		return false;
	}
	
	public function set isConnected(value:Bool):Void{ }
	
	/**
	 * returns GroupSpecifier String, here you can enable, disable group params
	 */
	public function getGroupSpec():GroupSpecifier{
		var groupspec:GroupSpecifier = new GroupSpecifier(this.groupName);
		groupspec.postingEnabled = true;
		groupspec.serverChannelEnabled = true;
		groupspec.routingEnabled = true;
		
		return groupspec;
	}
	
	/**
	 * dispaches event, which is supposed to be written - debug and message info
	 */
	protected function statusWrite(str:String):Void{
		dispatchEvent(new StatusInfoEvent(StatusInfoEvent.STATUS_INFO,str));
	}
	
	protected function debugWrite(str:String):Void{
		if(debugMode){
			statusWrite(str);
		}
	}
	
	protected function changeStatus(status:uint):Void{
		this.status = status;
		dispatchEvent(new ConnectionStatusEvent(ConnectionStatusEvent.STATUS_CHANGE,status));
	}
	
	/**
	 * handles all net status events covering NetConnection and NetGroup
	 */ 
	public function netStatus(e:NetStatusEvent):Void{
		trace(e.info.code);
		
		if(debugMode){
			statusWrite(e.info.code);
		}
		switch(e.info.code)
		{
			case "NetConnection.Connect.Success":
				
				
				statusWrite("- Connected to Adobe Stratus -");
				
				changeStatus(ConnectionStatusEvent.CONNECTED);
				
			
			case "NetConnection.Connect.Closed":
				
				changeStatus(ConnectionStatusEvent.DISCONNECTED);
				
				statusWrite("- Disconnected -");
				
				onDisconnect();
				
				
			
			case "NetConnection.Connect.Failed":
				
				changeStatus(ConnectionStatusEvent.FAILED);
				
				
			
			case "NetConnection.Connect.Rejected":
			case "NetConnection.Connect.AppShutdown":
			case "NetConnection.Connect.InvalidApp":    
				onDisconnect();
				
			
			case "NetStream.Connect.Success": // e.info.stream
				//					onNetStreamConnect();
				
			
			case "NetStream.Connect.Rejected": // e.info.stream
			case "NetStream.Connect.Failed": // e.info.stream
				//doDisconnect();
				
			
			case "NetGroup.Connect.Success": // e.info.group
				onNetGroupConnect();
				
				statusWrite("- Joined Group -");
				
				changeStatus(ConnectionStatusEvent.CONNECTED_GROUP);
				
				
			
			case "NetGroup.Connect.Rejected": // e.info.group
				
				trace("Rejected group: "+e.info.group);
				
			case "NetGroup.Connect.Failed": // e.info.group
				
				changeStatus(ConnectionStatusEvent.CONNECTED);
				
				onDisconnect();
				
			
			case "NetGroup.Posting.Notify": // e.info.message, e.info.messageID
				//					onPosting(e.info.message);
				
			
			
			case "NetStream.MulticastStream.Reset":
			case "NetStream.Buffer.Full":
				
			
			case "NetGroup.SendTo.Notify": // e.info.message, e.info.from, e.info.fromLocal
				
				switch(e.info.message.type){
					case "openPrivateChat":
						openPrivateChatReceive(e.info.message);
						
				}
				
				
			
			case "NetGroup.LocalCoverage.Notify": //
				
				
			case "NetGroup.Neighbor.Connect": // e.info.neighbor
				//					onNeighborConnect(e.info)
			//	statusWrite(e.info.code);
				
			case "NetGroup.Neighbor.Disconnect": // e.info.neighbor
				//					onNeighborDisconnect(e.info);
			//	statusWrite(e.info.code);
				
			case "NetGroup.MulticastStream.PublishNotify": // e.info.name
			case "NetGroup.MulticastStream.UnpublishNotify": // e.info.name
			case "NetGroup.Replication.Fetch.SendNotify": // e.info.index
			case "NetGroup.Replication.Fetch.Failed": // e.info.index
			case "NetGroup.Replication.Fetch.Result": // e.info.index, e.info.Dynamic
			case "NetGroup.Replication.Request": // e.info.index, e.info.requestID
			default:
				
		}
	}
	
	public function get connection():NetConnection{
		return _connection;
	}
	public function set connection(value:NetConnection):Void{
		_connection = value;
	}
	
	public function get myUser():UserObject{
		return _myUser;
	}
	public function set myUser(value:UserObject):Void{
		_myUser = value;
	}
	
	public function get mainChat():GroupChat{
		return _mainChat;
	}
	public function set mainChat(value:GroupChat):Void{
		_mainChat = value;
	}
}
