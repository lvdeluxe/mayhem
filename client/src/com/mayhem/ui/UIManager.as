package com.mayhem.ui 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import flash.display.Stage;
	import starling.core.Starling;
	import starling.events.Event
	 
	public class UIManager 
	{
		
		private var _starling:Starling;
		
		public function UIManager(pStage:Stage) 
		{
			_starling = new Starling( UIDisplay, pStage, null, pStage.stage3Ds[0] );			
			_starling.shareContext = true;
		}
		
		public function get renderer():Starling {
			return _starling;
		}
		
	}

}