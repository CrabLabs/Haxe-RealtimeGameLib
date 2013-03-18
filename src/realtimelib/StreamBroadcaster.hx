package realtimelib;

import realtimelib.session.ISession;

class StreamBroadcaster
{
	private var _realtimeChannelManager(getRealtimeChannelManager, null):RealtimeChannelManager;
	private var _session:ISession;
	
	public function new(manager:RealtimeChannelManager, session:ISession)
	{
		StreamBroadcaster(manager, session);
	}

	public function StreamBroadcaster(manager:RealtimeChannelManager, session:ISession)
	{
		_initialize(realtimeChannelManager, session);
	}
	
	private function _initialize(realtimeChannelManager:RealtimeChannelManager, session:ISession):Void
	{
		_realtimeChannelManager = realtimeChannelManager;
		_session = session;
	}
	
	public function sendToPeers(command:String, rest:Array<Dynamic>):Void
	{
		// Reflect.makeVarArgs (test) (1, 2, 3);
		rest.unshift(_session.myUser.id);
		rest.unshift(command);
		_realtimeChannelManager.sendStream.send.apply(this, rest);
	}
	
	public function sendToAllPeers(command:String, ...rest):Void
	{
		rest.unshift(command);
		_realtimeChannelManager.sendStream.send.apply(this, rest);
	}
	
	public function getRealtimeChannelManager():RealtimeChannelManager
	{
		return _realtimeChannelManager;
	}
}