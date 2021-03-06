package realtimelib; 

import realtimelib.session.ISession;
import realtimelib.session.P2PSession;
import realtimelib.session.UserList;
import realtimelib.session.UserObject;

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

/**
 * Manages realtime connections among peers in a full mesh P2P network scenario.
 * Creates RealtimeChannel between two peers for every new member in the group.
 * E.g. if there are 5 peers in the group, RealtimeChannelManager handels 5 RealtimeChannel instances (5 receive streams).
 * Also creates one send stream (publish) for data distribution to all clients in the group, who subscribe to it - in this scenario everyone.
 */
class RealtimeChannelManager
{
	public var realtimeChannels:Array<RealtimeChannel>;
	
	private var session:ISession
	public var sendStream:NetStream;
	public var streamMethod:String;
	
	public function new(session:ISession, streamMethod:String=NetStream.DIRECT_CONNECTIONS)
	{
		RealtimeChannelManager(session, streamMethod);
	}

	public function RealtimeChannelManager(session:ISession, streamMethod:String=NetStream.DIRECT_CONNECTIONS)
	{
		this.session = session;
		this.streamMethod = streamMethod;
		realtimeChannels = new Array<RealtimeChannel>();
		initSendStream();
	}
	/**
	 * Adds new RealtimeChannel
	 * @param peerID peerID to connect to
	 * @param clientObject user details
	 */
	public function addRealtimeChannel(peerID:String, clientObject:Object):Void
	{
		var realtimeChannel:RealtimeChannel = new RealtimeChannel(session.connection, peerID, session.myUser.id,clientObject);
		realtimeChannels.push(realtimeChannel);
	}
	
	/**
	 * Removes RealtimeChannel by peerID.
	 * @param peerID Remove RealtimeChannel by peerID.
	 */
	public function removeRealtimeChannel(peerID:String):Void
	{
		for(var i:uint = 0;i<realtimeChannels.length;i++){
			if(realtimeChannels[i].peerID == peerID){
				realtimeChannels[i].close();
				realtimeChannels.splice(i,1);
				break;
			}
		}
	}
	
	public function netStatus(event:NetStatusEvent):Void
	{
		Logger.log("SendStream: "+event.info.code);
	}
	
	public function initSendStream():Void
	{
		sendStream = new NetStream(session.connection,streamMethod);
		sendStream.addEventListener(NetStatusEvent.NET_STATUS, netStatus,false,0,true);
		sendStream.publish("media");
		
		var sendStreamClient:Dynamic = {};
		sendStreamClient.onPeerConnect = function(callerns:NetStream):Bool
		{
			Logger.log("onPeerConnect "+callerns.farID);
			return true;
		}
		sendStream.client = sendStreamClient;
	}
}