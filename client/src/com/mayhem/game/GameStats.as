package com.mayhem.game 
{
	import playerio.DatabaseObject;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameStats 
	{
		public var uid:String;
		public var current_worst_enemy:String = "";
		public var current_num_kills_received:int = 0;//OK
		public var current_num_kills_inflicted:int = 0;//OK
		public var current_num_hits_received:int = 0;//OK
		public var current_num_hits_inflicted:int = 0;//OK
		public var current_num_felt:int = 0;//OK
		public var current_max_speed:int = 0; //OK
		
		public var alltime_worst_enemy:String = "";
		public var alltime_num_kills_received:Number = 0;
		public var alltime_num_kills_inflicted:Number = 0;
		public var alltime_num_hits_received:Number = 0;
		public var alltime_num_hits_inflicted:Number = 0;
		public var alltime_num_felt:Number = 0;
		public var alltime_max_speed:Number = 0;
		public var alltime_sessions_played:int = 0
		
		public var total_time_played:Number;
		
		
		
		public function updateWithAllTimeData(dbObject:DatabaseObject):void {
			alltime_max_speed = dbObject.AllTimeMaxSpeed;
			alltime_num_kills_received = dbObject.AllTimeKillsReceived;
			alltime_num_kills_inflicted = dbObject.AllTimeKillsInflicted;
			alltime_num_hits_received = dbObject.AllTimeHitsReceived;
			alltime_num_hits_inflicted = dbObject.AllTimeHitsInflicted ;
			alltime_num_felt = dbObject.AllTimeFelt;
			alltime_sessions_played = dbObject.AllTimeSessionsPlayed;
		}
	
		public function GameStats(pName:String) 
		{
			uid = pName;
		}
		
	}

}