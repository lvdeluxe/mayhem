package
{
	//import away3d.core.managers.Stage3DManager;
	//import away3d.core.managers.Stage3DProxy;
	//import away3d.debug.AwayStats;
	import com.mayhem.game.GameManager;
	import com.mayhem.multiplayer.Connector;
	import com.hibernum.social.model.SocialModel;
	import com.hibernum.social.model.SocialUser;
	import com.mayhem.ui.UIManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	//import away3d.events.Stage3DEvent;
	import flash.utils.getTimer;
	import flash.display.StageQuality;
	import com.hibernum.social.service.FacebookService;
	import flash.system.Security;
	
	
	/**
	 * ...
	 * @author availlant
	 */
	public class Main extends Sprite 
	{
		
		private var _connector:Connector;
		private var _uiManager:UIManager;
		private var _gameManager:GameManager;
		private var _social:SocialModel;
		
		//private var _stage3DProxy:Stage3DProxy;
		//private var _stage3DManager:Stage3DManager;
		
		private var ticks:uint = 0;
		private var last:uint = getTimer();
		
		private var letters:String = "abcdefghijklmnopqrstuvwxyz"
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			Security.allowDomain("*") ;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			setStageProperties();
			setStage3DProxy();
			trace("yo1")
		}
		
		private function setStageProperties():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			stage.align = StageAlign.TOP_LEFT;
		}
		
		private function setStage3DProxy():void {
			_gameManager = new GameManager(stage);
			//_stage3DManager = Stage3DManager.getInstance(stage);
			//_stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy();
			_gameManager.renderer.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			//stage.stage3Ds[0].requestContext3D();
			//trace(stage.stage3Ds[0].context3D)
			//stage.stagq
			//_stage3DProxy.antiAlias = 0;
			//_stage3DProxy.color = 0x0;		
			//onContextCreated(null)
		}
		
		private function onContextCreated(event : Event) : void {
			stage.stage3Ds[0].removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			trace("created!",stage.stage3Ds[0].context3D)
			_uiManager = new UIManager(stage);
			//_gameManager = new GameManager(stage);
			//_social = new SocialModel(connectedToSocial);
			var socialUser:SocialUser = new SocialUser();
			socialUser.social_id = Math.round(Math.random() * 10000).toString();
			socialUser.name = getRandomName();
			trace("socialUser.name",socialUser.name);
			_connector = new Connector(stage,socialUser);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function getRandomName():String {
			var str:String = "";
			var split:Array = letters.split("");
			for (var i:uint = 0 ; i < 10 ; i++ )
				str += split[Math.floor(Math.random() * split.length)];
			return str;
		}
		
		private function connectedToSocial(socialUser:SocialUser):void {
			trace(socialUser.social_id);
			_connector = new Connector(stage,socialUser);
		}
		
		private function onEnterFrame(event : Event) : void {
			//_gameManager.renderPhysics();
			//_gameManager.render();
			//trace(_uiManager.renderer)
			_uiManager.renderer.nextFrame();
			_gameManager.render();
		}		
	}
	
}