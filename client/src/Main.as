package
{
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import com.mayhem.game.GameManager;
	import com.mayhem.multiplayer.Connector;
	import com.hibernum.social.model.SocialModel;
	import com.hibernum.social.model.SocialUser;
	import com.mayhem.ui.UIManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import away3d.events.Stage3DEvent;
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
		
		private var _stage3DProxy:Stage3DProxy;
		private var _stage3DManager:Stage3DManager;
		
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
			Security.loadPolicyFile("http://cdn.playerio.com/crossdomain.xml");
			removeEventListener(Event.ADDED_TO_STAGE, init);
			setStageProperties();
			setStage3DProxy();
		}
		
		private function setStageProperties():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			stage.align = StageAlign.TOP_LEFT;
		}
		
		private function setStage3DProxy():void{			
			_stage3DManager = Stage3DManager.getInstance(stage);
			_stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy();
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			_stage3DProxy.antiAlias = 0;
			_stage3DProxy.color = 0x0;		
		}
		
		private function onContextCreated(event : Stage3DEvent) : void {
			_uiManager = new UIManager(stage);
			_gameManager = new GameManager(stage, _stage3DProxy);
			//_social = new SocialModel(connectedToSocial);
			var socialUser:SocialUser = new SocialUser();
			socialUser.social_id = Math.round(Math.random() * 10000).toString();
			socialUser.name = getRandomName();
			trace("socialUser.name",socialUser.name);
			_connector = new Connector(stage,socialUser);
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			_gameManager.renderPhysics();
			_gameManager.renderer.render();
			_uiManager.renderer.nextFrame();
		}		
	}
	
}