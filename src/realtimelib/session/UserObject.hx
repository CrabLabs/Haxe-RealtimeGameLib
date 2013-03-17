/* 
Created by Tom Krcha (http://flashrealtime.com/, http://twitter.com/tomkrcha). 
Provided "as is" in public domain with no guarantees 
Adapted to HaXe by CrabLabs. March 2013.
*/
package realtimelib.session;

/**
 * object used for storing user information in the user list. 
 */
class UserObject
{
	public var id:String;
	public var name:String;
	public var stamp:Float;
	public var address:String;
	public var idle:Date;
	public var label:String;
	
	public var details:Dynamic;
}
