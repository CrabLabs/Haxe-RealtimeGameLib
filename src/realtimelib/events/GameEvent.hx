package realtimelib.events;

import flash.events.Event;

/**
 * Game status event
 */
class GameEvent extends Event
{
	public static const START_GAME:String = "startGame";
	public static const GAME_OVER:String = "gameOver";
	public static const PLAYER_READY:String = "playerReady";
	public static const PLAYER_OUT:String = "playerOut";
	
	public var playerID:String;
	public var details:Dynamic;
	
	public function GameEvent(type:String, playerID:String, details:Dynamic=null, bubbles:Bool=false, cancelable:Bool=false)
	{
		super(type, bubbles, cancelable);
		
		this.playerID = playerID;
		this.details = details;
	}
}
