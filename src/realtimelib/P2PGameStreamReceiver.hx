package realtimelib;

import flash.events.IEventDispatcher;

import realtimelib.events.GameEvent;

class P2PGameStreamReceiver
{
	private var _eventDispatcher:IEventDispatcher;

	private var receiveSpeedCallback(getReceiveSpeedCallback, setReceiveSpeedCallback):Function;
	private var receiveRotationCallback(getReceiveRotationCallback, setReceiveRotationCallback);
	private var receiveMousePositionCallback(getReceiveMousePositionCallback, setReceiveMousePositionCallback);
	private var receivePositionCallback(getReceivePositionCallback, setReceivePositionCallback);
	private var receiveMovementCallback(getReceiveMovementCallback, setReceiveMovementCallback);

	public function getReceiveSpeedCallback():Function
	{
		return _receiveSpeedCallback;
	}

	public function setReceiveSpeedCallback(value:Function):Void
	{
		_receiveSpeedCallback = value;
	}

	public function getReceiveRotationCallback():Function
	{
		return _receiveRotationCallback;
	}

	public function setReceiveRotationCallback(value:Function):Void
	{
		_receiveRotationCallback = value;
	}

	public function getReceiveMousePositionCallback():Function
	{
		return _receiveMousePositionCallback;
	}

	public function setReceiveMousePositionCallback(value:Function):Void
	{
		_receiveMousePositionCallback = value;
	}

	public function getReceivePositionCallback():Function
	{
		return _receivePositionCallback;
	}

	public function setReceivePositionCallback(value:Function):Void
	{
		_receivePositionCallback = value;
	}

	public function getReceiveMovementCallback():Function
	{
		return _receiveMovementCallback;
	}

	public function setReceiveMovementCallback(value:Function):Void
	{
		_receiveMovementCallback = value;
	}

	private var _runningExplicitSetter:Function;
	private var _receiveMovementCallback:Function;
	private var _receivePositionCallback:Function;
	private var _receiveMousePositionCallback:Function;
	private var _receiveRotationCallback:Function;
	private var _receiveSpeedCallback:Function;
	
	
	public function P2PGameStreamReceiver(eventDispatcher:IEventDispatcher, runningExplicitSetter:Function)
	{
		_initializeP2PGameStreamReceiver(eventDispatcher, runningExplicitSetter);
	}
	
	private function _initializeP2PGameStreamReceiver(eventDispatcher:IEventDispatcher, runningExplicitSetter:Function):Void
	{
		_eventDispatcher = eventDispatcher;
		_runningExplicitSetter = runningExplicitSetter;
	}
	
	/*
	**********************************************************************
	* RECEIVE 
	**********************************************************************
	*/ 
	
	/*
	* GAME MESSAGES
	*/
	public function receiveStartGame(peerID:String):Void
	{
		_eventDispatcher.dispatchEvent(new GameEvent(GameEvent.START_GAME,peerID));
		_runningExplicitSetter(true);
	}
	
	public function receiveGameOver(peerID:String):Void
	{
		_eventDispatcher.dispatchEvent(new GameEvent(GameEvent.GAME_OVER,peerID));
		_runningExplicitSetter(false);
	}
	
	/*
	* PLAYER MESSAGES
	*/
	public function receivePlayerReady(peerID:String):Void
	{
		_eventDispatcher.dispatchEvent(new GameEvent(GameEvent.PLAYER_READY,peerID));
	}
	
	public function receivePlayerOut(peerID:String):Void
	{
		_eventDispatcher.dispatchEvent(new GameEvent(GameEvent.PLAYER_OUT,peerID));
	}
	
	/*
	* MOVEMENT MESSAGES
	*/ 
	/**
	 * Receive movement, called internally in the most cases.
	 * @param peerID Contains unique peerID.
	 * @param direction an be any int describing UP, DOWN, LEFT, RIGHT or FORWARD, BACKWARD, LEFT, RIGHT or their combinations UP-LEFT, UP-RIGHT and so on.
	 * @param down
	 */
	public function receiveMovement(peerID:String, direction:Int, down:Bool):Void
	{
		receiveMovementCallback.call(this, peerID, direction, down);
	}
	/**
	 * Receive position, called internally in the most cases.
	 * @param peerID Contains unique peerID.
	 * @param position Object that usually contains info about position like x, y, z and orientation, rotation, velocity.
	 */
	public function receivePosition(peerID:String, position:Dynamic):Void
	{
		receivePositionCallback.call(this,peerID, position);
	}
	
	/**
	 * Receive mouse position, called internally in the most cases.
	 * @param peerID Contains unique peerID.
	 * @param x Mouse x position.
	 * @param y Mouse y position.
	 */
	public function receiveMousePositions(peerID:String, x:Int, y:Int):Void
	{
		receiveMousePositionCallback.call(this,peerID, x, y);
	}
	
	// car related
	/**
	 * Receive rotation, called internally in the most cases. This method is mostly racing car steering wheel related.
	 * @param peerID Contains unique peerID.
	 * @param rotation Contains rotation.
	 */
	public function receiveRotation(peerID:String, rotation:Float):Void
	{
		receiveRotationCallback.call(this, peerID, rotation);
	}
	
	/**
	 * Receive speed, called internally in the most cases. This method is mostly racing car steering wheel related.
	 * @param peerID Contains unique peerID.
	 * @param speed Contains speed.
	 */
	public function receiveSpeed(peerID:String, speed:Float):Void
	{
		receiveSpeedCallback.call(this, peerID, speed);
	}
}