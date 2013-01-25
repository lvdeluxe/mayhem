package com.hibernum.social.controller 
{
	import com.hibernum.social.service.FacebookService;
	import com.mayhem.signals.SocialSignals;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author availlant
	 */
	public class SocialImageLoader 
	{
		
		private var _userId:String;
		
		public function SocialImageLoader(uid:String) 
		{
			_userId = uid;
			var imagePath:String = FacebookService.getImageUrl(_userId.split("_")[1]);
			var loader:Loader = new Loader()
			var req:URLRequest = new URLRequest(imagePath);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
			loader.load(req);
		}
		
		private function onImageComplete(event:Event):void {
			var img:Bitmap = event.target.loader.content;
			SocialSignals.IMAGE_LOADED.dispatch(_userId,img);
		}
		
	}

}