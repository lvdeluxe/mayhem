package com.mayhem.ui 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.core.managers.Stage3DProxy;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.events.Event;
	import flash.events.Event;
	import flash.display.StageQuality;
	import flash.display3D.Context3DRenderMode
	 
	public class UIManager 
	{
		
		private var _starling:Starling;
		private var stage3D:Stage3D;
		private var _ready:Boolean = false
		
		public function UIManager(pStage:Stage, proxy:Stage3DProxy) 
		{
			Starling.multitouchEnabled = true;
			_starling = new Starling( UIDisplay, pStage, proxy.viewPort, proxy.stage3D);	
			_starling.start();
			_starling.shareContext = true;
			pStage.quality = StageQuality.LOW;
			
		}
	
		
		public function render():void {
			_starling.nextFrame();
		}
		
	}

}