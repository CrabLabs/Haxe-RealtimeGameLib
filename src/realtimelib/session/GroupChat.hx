/* Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). Provided "as is" in public domain with no guarantees */
package realtimelib.session;

import realtimelib.events.PeerStatusEvent;
import realtimelib.events.StatusInfoEvent;

import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.net.GroupSpecifier;
import flash.net.NetConnection;
import flash.net.NetGroup;


[Event(name="statusInfo",type="realtimelib.events.StatusInfoEvent")]
/**
 * Dispatched when groupUserList changes
 */
[Event(name="change",type="flash.events.Event")]
[Event(name="userAdded",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="userRemoved",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="userIdle",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="connected",type="com.adobe.fms.PeerStatusEvent")]
public class GroupChat extends UserList
{
	
	/**
	 * chat sequence to make messages unique
	 */
	private var chatSequence:uint = 0;
	
	/**
	 * contains list of users, maintained by UserList class
	 */
	public var groupUserList:Array;
	
	public var userNames:Array;
	
	public var userNamesString:String;
	
	private var session:P2PSession;
	
	public function GroupChat(session:P2PSession, groupspec:String,username:String=null,userDetails:Dynamic=null)
	{
		super(session.connection, groupspec,username,userDetails);
		
		setupUserList();
	}
	
	public function chatSend(message:String):Void{
		var msgObj:Dynamic = new Dynamic();
		msgObj.message = message;
		msgObj.username = session.myUser.name;
		msgObj.type = "chat";
		msgObj.sequence = chatSequence++;
		
		this.post(msgObj);
		chatReceive(msgObj);
	}
	
	public function chatReceive(msg:Dynamic):Void{
		dispatchEvent(new StatusInfoEvent(StatusInfoEvent.STATUS_INFO, msg.username+": "+msg.message));
	}
	
	protected function updateUserNames():Void{
		userNames = new Array();
		for(j in 0...groupUserList.length){
			userNames.push(groupUserList[j].name);
		}
		
		userNamesString = userNames.join(', ');
		
	}
	
	protected function onPosting(message:Dynamic):Void{			
		switch(message.type){
			case "chat":
				chatReceive(message);
				
			
			default:
				
		}
	}
	
	/**
	 * handles all net status events covering NetConnection and NetGroup
	 */ 
	protected function netStatus(e:NetStatusEvent):Void{
		switch(e.info.code)
		{
			case "NetGroup.Connect.Success": // e.info.group
				statusWrite("Connected to private chat group");
								
			case "NetGroup.Connect.Rejected": // e.info.group
			case "NetGroup.Connect.Failed": // e.info.group
				
			
			case "NetGroup.Posting.Notify": // e.info.message, e.info.messageID
				onPosting(e.info.message);
				
			case "NetGroup.SendTo.Notify": // e.info.message, e.info.from, e.info.fromLocal
							
			case "NetGroup.LocalCoverage.Notify": //					
				
			case "NetGroup.Neighbor.Connect": // e.info.neighbor
				
			case "NetGroup.Neighbor.Disconnect": // e.info.neighbor
				
			default:
				
		}
	}
	
	
	/// USER LIST
	
	/**
	 * setup UserList instance and all handlers (connected, userAdded, userRemoved, userIdle)
	 */
	protected function setupUserList():Void{
		groupUserList = new Array();
		
		addEventListener(PeerStatusEvent.CONNECTED, userListUpdate,false,0,true);
		addEventListener(PeerStatusEvent.USER_ADDED, userListUpdate,false,0,true);
		addEventListener(PeerStatusEvent.USER_REMOVED, userListUpdate,false,0,true);
		addEventListener(PeerStatusEvent.USER_IDLE, userListUpdate,false,0,true);
		
		// GROUP
		addEventListener(NetStatusEvent.NET_STATUS, netStatus,false,0,true);

	}
	
	/**
	 * handlers (connected, userAdded, userRemoved, userIdle)
	 */
	public function userListUpdate(msg:PeerStatusEvent):Void {
		switch(msg.type) {
			case "connected":
				
			case "userAdded":
									
				var userObject:UserObject = new UserObject();
				userObject.address = msg.info.address;
				userObject.id = msg.info.id;
				userObject.name = msg.info.name;
				userObject.stamp = msg.info.stamp;
				userObject.details = msg.info.details;
				userObject.idle = new Date();
				
				groupUserList.push(userObject);
				
				updateUserNames();
				
			case "userRemoved":
				
				for(j in 0...groupUserList.length){
					if(groupUserList[j].id == msg.info.id) {
						groupUserList.splice(j,1);
						
						
					}
				}
				
				updateUserNames();
				
				
			case "userIdle":
								
				for(k in 0...groupUserList.length){
					if(groupUserList[k].id == msg.info.id) {
						groupUserList[k].idle = new Date();
						
					}
				}
				
		}
		dispatchEvent(new Event(Event.CHANGE));
	}
	
	
	/**
	 * dispaches event, which is supposed to be written - debug and message info
	 */
	protected function statusWrite(str:String):Void{
		dispatchEvent(new StatusInfoEvent(StatusInfoEvent.STATUS_INFO,str));
	}		
}
