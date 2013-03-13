package  
{
	import com.mayhem.ui.TexturesManager;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextField;
	import playerio.GameFS;
	/**
	 * ...
	 * @author availlant
	 */
	public class Preloader extends Sprite
	{
		
		private var _loadingBar:Sprite;
		private var tf:TextField
		private var logo:Bitmap;
		
		public function Preloader() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			logo = new TexturesManager.Logo();
			logo.smoothing = true;
			logo.x = (stage.stageWidth - logo.width) / 2;
			logo.y = ((stage.stageHeight / 2) - logo.height) - 20  ;
			addChild(logo);
			setLoadingBar();
			var context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
			context.securityDomain = SecurityDomain.currentDomain;
			//var gameFS:GameFS = GameFS.
			//GameFS.
			var request:URLRequest = new URLRequest("http://r.playerio.com/r/office-mayhem-g9omnsmpskqoxaolbzotca/Cube Mayhem/cubicmayhem.swf");
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			//loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request,context);
		}
		
		//private function onError(event:IOErrorEvent):void {
			//
		//}
		
		
		private function setLoadingBar():void {
			_loadingBar = new Sprite();
			_loadingBar.graphics.beginFill(0xffffff);
			_loadingBar.graphics.drawRect(0, 0, 200, 5);
			_loadingBar.x = (stage.stageWidth / 2) - 100;
			_loadingBar.y = (stage.stageHeight / 2) - 12;
			_loadingBar.scaleX = 00;
			addChild(_loadingBar);
			tf = new TextField();
			tf.textColor = 0x000000;
		}
		
		private function onProgressHandler(event:ProgressEvent):void {
			var frame:Number = (event.bytesLoaded / event.bytesTotal);
			_loadingBar.scaleX = frame;
		}

		private function onCompleteHandler(event:Event):void {
			event.currentTarget.removeEventListener(Event.COMPLETE, onCompleteHandler);
			event.currentTarget.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			removeChild(_loadingBar);
			removeChild(logo);
			addChild(event.currentTarget.content);
		}
	}

}