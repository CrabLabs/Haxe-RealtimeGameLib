package realtimelib.session;

import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.net.NetGroup;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;
import flash.utils.setTimeout;

import realtimelib.events.PeerStatusEvent;

[Event(name="userAdded",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="userRemoved",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="userIdle",type="com.adobe.fms.PeerStatusEvent")]
[Event(name="connected",type="com.adobe.fms.PeerStatusEvent")]
public class UserList extends NetGroup
{		

	// members
	private var m_nearID:String;				// near id
	private var m_sequenceNumber:uint;			// sequence Float increment, ensures all posts sent to the group are unique
	private var m_neighbored:Bool;			// initialization flag to indicate participation in the group
	private var m_userName:String;				// user name assigned to this instance
	private var m_groupAddress:String;			// this peer's address in the group
	private var m_userList:Dynamic;				// list of all the known users in the group
	private var m_keepAliveTimer:Timer;			// handles announcement of user's presence to the group
	private var m_expireTimer:Timer;			// handles expiration of users who may have timed out or disconnected
	private var m_expired:Float;				// time to grant users before expiring them
	private var m_idle:Float;					// determines when to dispatch an idle event
	private var m_scaleFactor:Int = 0;			// current factor to test for scaling up or down
	private var m_scalePercent:Float = .25;	// percent to scale up or down
	private var m_userDetails:Dynamic;
	
	// member constants
	private const ANONYMOUS_USER_NAME:String = "lurker";
	
	/*
	private const DEFAULT_ANNOUNCE_TIME:Float = 120000;	// every 2 minutes
	private const DEFAULT_EXPIRE_TIME:Float = 60000;		// every minute
	private const DEFAULT_EXPIRE_TIMEOUT:Float = 300000;	// 5 minutes
	private const DEFAULT_IDLE_TIME:Float = 180000;		// 3 minutes
	*/
	private const DEFAULT_ANNOUNCE_TIME:Float = 3000;	// every 3 seconds
	private const DEFAULT_EXPIRE_TIME:Float = 3000;		// every 3 seconds
	private const DEFAULT_EXPIRE_TIMEOUT:Float = 10000;	// every 10 seconds
	private const DEFAULT_IDLE_TIME:Float = 3000;		// every 3 seconds
	
	/**
	 * Creates a new UserList Dynamic. 
	 * @param connection
	 * @param groupspec
	 * @param username
	 * 
	 */	
	public function UserList(connection:NetConnection, groupspec:String, username:String = null, userDetails:Dynamic=null)
	{
		// create the base NetGroup and add an internal event listener
		super(connection, groupspec);
		
		initializeUserList(connection, groupspec, username, userDetails);
	}
	
	protected function initializeUserList(connection:NetConnection, groupspec:String, username:String, userDetails:Dynamic):Void
	{
		// TODO Auto Generated method stub
		// add event listener for NetGroup.Connect.Success which is sent on the NetConnection's status handler
		connection.addEventListener(NetStatusEvent.NET_STATUS, this.connectionStatusHandler);
		
		// add local event listener for NetGroup status events
		addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		
		// capture the NetConnection which is used to access the nearID
		m_nearID = connection.nearID;
		m_sequenceNumber = 0;
		
		// set announce timer and frequency
		m_keepAliveTimer = new Timer(DEFAULT_ANNOUNCE_TIME);
		m_keepAliveTimer.addEventListener(TimerEvent.TIMER, announceSelf);
		
		// set the expiration timer
		m_expireTimer = new Timer(DEFAULT_EXPIRE_TIME);
		m_expireTimer.addEventListener(TimerEvent.TIMER, expireNames);
		
		// instantiate the default users container
		m_userList = new Dynamic();
		
		
		// give it a default username in case the username is not set on creation
		if( username )
		{
			m_userName = username;
		}
		else
		{
			m_userName = ANONYMOUS_USER_NAME;
		}
		
		// set the final expire value
		m_expired = DEFAULT_EXPIRE_TIMEOUT;
		
		// set the value for idling
		m_idle = DEFAULT_IDLE_TIME;
		
		// init group connectivity to false until we become aware of the first neighbor
		m_neighbored = false;
		
		// user details
		m_userDetails = userDetails;
	}
	
	/**
	 * The interval in which to check if users have expired. 
	 * @return 
	 * 
	 */
	public function get expireTimerDelay():Float				{ return m_expireTimer.delay; }
	public function set expireTimerDelay(delay:Float):Void	{ m_expireTimer.delay = delay; }
	
	/**
	 * Returns the group address for this peer. 
	 * @return 
	 * 
	 */		
	public function get groupAddress():String
	{
		if(!m_groupAddress)
		{
			m_groupAddress = convertPeerIDToGroupAddress(m_nearID);
		}
		return m_groupAddress;
	}

	/**
	 * Time when a user's age indicates they are likely to expire. 
	 * @return 
	 * 
	 */		
	public function get idleTime():Float			{ return m_idle; }
	public function set idleTime(time:Float):Void	{ m_idle = time; }

	/**
	 * Time to send a keep-alive message to the group to inform them you are still present. 
	 * @return 
	 * 
	 */		
	public function get keepAliveTimerDelay():Float			{ return m_keepAliveTimer.delay; }
	public function set keepAliveTimerDelay(delay:Float):Void	{ m_keepAliveTimer.delay = delay; }
	
	/**
	 * User name for this instance. 
	 * @param name
	 * 
	 */		
	public function get userName():String			{ return m_userName; }
	public function set userName(name:String):Void	{ m_userName = name; }		
	
	/**
	 * Returns the Dynamic containing all of the known users in the group. 
	 * @return 
	 * 
	 */
	public function get userList():Dynamic			{ return m_userList; }


	/**
	 * Handles status events received for the NetConnection.
	 * Used to determine when the NetGroup.Connect.Success event is dispatched. 
	 * @param evt
	 * 
	 */
	private function connectionStatusHandler(evt:NetStatusEvent):Void
	{
		if( evt.info.code == "NetGroup.Connect.Success" )
		{
			// removes the EventListener as we no longer need it
			const netConnection:NetConnection = cast (evt.target, NetConnection);
			netConnection.removeEventListener(NetStatusEvent.NET_STATUS, this.connectionStatusHandler);
			
			// ok we're connected, create a new user list entry for self
			if (netConnection.connected)
			{
				var uo:UserObject = new UserObject();
					uo.id = m_nearID;
					uo.name = m_userName;
					uo.stamp = getTimer();
					uo.address = groupAddress;
					uo.details = m_userDetails;
					
				m_userList[m_nearID] = uo;
				
				// dispatch user added event for self
				dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_ADDED, true, false, uo) );
			}
		}
	}
	
	/**
	 * Handles status events received to the NetGroup. 
	 * @param evt
	 * 
	 */		
	protected function netStatusHandler(evt:NetStatusEvent):Void 
	{
		
		switch( evt.info.code ) {
			
			case "NetGroup.Neighbor.Connect":
				trace(evt.info.code);
				// don't start timers and attempt group calls until we have at least one neighbor
				if( !m_neighbored ) 
				{					
					m_neighbored = true;
					
					// start timers
					m_keepAliveTimer.start();
					m_expireTimer.start();
					
					// immediately send a keep-alive to the group
					announceSelf();
					
					// announce one more keep-alive 30 seconds later
					var announceFollowUp:uint = setTimeout(announceSelf, 30000);
					
					// request a current snapshot of the known users from the first neighbor
					requestUsers(evt.info.neighbor);
					dispatchEvent(new PeerStatusEvent(PeerStatusEvent.CONNECTED, true, false));
				}
				
			
			case "NetGroup.Neighbor.Disconnect":
				trace(evt.info.code);
				var fields = Reflect.fields (m_userList);
				for( i in fields )
				{
					if(i == evt.info.peerID){
						dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_REMOVED, true, false, m_userList[i]) );
						delete m_userList[i];
					}
				}
				
			
			case "NetGroup.Posting.Notify":
				
				// ignore any posts that are not relevant to updating users information
				var postObj:Dynamic = evt.info.message;
				
				if( postObj.id != null &&  postObj.name != null) 
				{
					updateUser(postObj);
				}
				
			
			case "NetGroup.SendTo.Notify":
				
				// process directed routing events (user list requests and replies)
				processRouting(evt.info);
				
		}
	}
	
	/**
	 * Updates the time stamp for a user when acknowledgement is received of their presence. 
	 * @param user
	 * 
	 */		
	protected function updateUser(user:Dynamic):Void
	{
		// grab the current timestamp
		user.stamp = getTimer();
		
		// no record of the user
		if( m_userList[user.id] == null )
		{
			
			// create a new user Dynamic (so we're not wasting memory saving the sequence Float)
			var uo:UserObject = new UserObject();
				uo.id = user.id;
				uo.name = user.name;
				uo.address = user.address;
				uo.details = user.details;
				
			m_userList[user.id] = uo;
			
			// dispatch user added event
			dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_ADDED, true, false, uo) );
		}

		// update user list entry with a new timestamp
		m_userList[user.id].stamp = getTimer();

	}
	
	/**
	 * Timer event handler to announce your presence to the group. 
	 * @param te
	 * 
	 */		
	protected function announceSelf(te:TimerEvent=null):Void 
	{

		// create a new Dynamic to be sent to other participants
		// notifying them of your presence.
		var msg:KeepAlive = new KeepAlive();
			msg.seq = m_sequenceNumber++;
			msg.id = m_nearID;
			msg.name = m_userName;
			
		// NetGroup.post will return the messageID of the post if successful
		// otherwise it will return null on error
		// If this returns a null, then make sure you selected postingEnabled
		// on your GroupSpecifier Dynamic
		if( post(msg) == null )
		{
			throw new Error("Your GroupSpecifier must have posting enabled in order to use the UserList class.");
		}
		
		// update time stamp for self
		m_userList[m_nearID].stamp = getTimer();
	}
	
	/**
	 * Timer event handler to loop through the names and see who may no longer be present in the group. 
	 * @param te
	 * 
	 */		
	protected function expireNames(te:TimerEvent=null):Void {
		
		// get current time stamp so we can calculate the time elapased since last post
		var currentStamp:uint = getTimer();
		var age:Float = 0;
		
		// loop through the user list Dynamic
		var fields = Reflect.fields (m_userList);
		for( i in fields )
		{
			
			// no need to check yourself
			if( i == m_nearID )
			{
				continue;
			}
		
			// calculate age
			age = currentStamp - m_userList[i].stamp;
			
			// purge users who have expired
			if( age > m_expired ) 
			{
				dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_REMOVED, true, false, m_userList[i]) );
				delete m_userList[i];
				continue;
			}
			
			// dispatch an event for idle users
			if( age > m_idle )
			{
				dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_IDLE, true, false, m_userList[i]) );
				continue;
			}
			
		}
	}

	
	// /////////////////////////////////////////////////////////// 
	// Directed Routing User List Request
	// This is the process by which a new joiner would ask a
	// neighbor for a copy of their users list.
	//
	// /////////////////////////////////////////////////////////// 
	
	
	protected function processRouting(info:Dynamic):Void {
		
		// info properties...
		// message - Dynamic that was sent
		// from - group address of neighbor info was received from
		// fromLocal - if true, then from self and process, else pass along
		
		if( info.message.destination == groupAddress )
		{
			// neighbor has requested a copy of user list
			if( info.message.type == ListRoutingObject.REQEUST )
			{
				var response:ListRoutingObject = new ListRoutingObject();
					response.destination = info.message.sender;
					response.time = getTimer();
					response.users = m_userList;
					response.type = ListRoutingObject.RESPONSE;
				
				// send the requester a copy of user list
				sendToNearest(response, response.destination);
			} 

			// neighbor has responded with a copy of their user list
			if( info.message.type == ListRoutingObject.RESPONSE )
			{
				var users:Dynamic = info.message.users;
				var neighborsTime:Float = info.message.time;
				var neighborsAge:Float = 0;
				var localAge:Float = 0;
				
				// loop through and calculate new stamp relative to known age and this system's clock
				var fields = Reflect.fields (users);
				for( i in fields ) 
				{
					
					neighborsAge = neighborsTime - users[i].stamp + 1000;
					
					// dispatch new user added event
					if( m_userList[i] == null )
					{
						dispatchEvent( new PeerStatusEvent(PeerStatusEvent.USER_ADDED, true, false, users[i]) );
						
						// update entry in user list
						m_userList[i] = users[i];					

						// calculate age, relevant to neighbors clock, and subtract age from this clock
						// add one second to account for request and processing time
						m_userList[i].stamp = getTimer() - neighborsAge;
					}
					else
					{
						// calculate the age relative to this instance's clock
						localAge = getTimer() - m_userList[i].stamp;
						
						// if neighbor has a record with a more recent age, use their's
						if( neighborsAge < localAge )
						{
							m_userList[i].stamp = getTimer() - neighborsAge;
						}
					}
					
				} // for
				
			} // if RESPONSE
			
			
		}
		else if( !info.fromLocal )
		{
			// not from local, pass it along
			sendToNearest(info.message, info.message.destination);
		}
	}
	
	/**
	 * Sumits a request for a snapshot of the first neighbor's users list. 
	 * @param id
	 * 
	 */
	protected function requestUsers(id:String):Void {
		
		var request:ListRoutingObject = new ListRoutingObject();
			request.destination = id;
			request.sender = groupAddress;
			request.type = ListRoutingObject.REQEUST;
		sendToNearest(request, request.destination);
	}		

	public function get userDetails():Dynamic
	{
		return m_userDetails;
	}

	public function set userDetails(value:Dynamic):Void
	{
		m_userDetails = value;
	}

	
} // UserList


/**
 * Internal Dynamic used for sending presence data about a user.
 * 
 */
internal class KeepAlive extends Dynamic
{
	
	public var seq:uint;
	public var id:String;
	public var name:String;
	
} // KeepAlive




/**
 * Internal Dynamic used for requesting, and responding with, a snapshot of the users list.
 * 
 */
internal class ListRoutingObject extends Dynamic
{
	public static const REQEUST:String = "request";
	public static const RESPONSE:String = "response";
	
	public var users:Dynamic;
	public var time:uint;
	public var type:String;
	public var sender:String;
	public var destination:String;
	
} // ListRoutingObject
