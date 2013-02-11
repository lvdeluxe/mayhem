package
{
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import com.mayhem.game.powerups.PowerupsModel;
	import com.mayhem.game.ThreeDeeController;
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
	import com.mayhem.game.ModelsManager;
	
	
	/**
	 * ...
	 * @author availlant
	 */
	public class Main extends Sprite 
	{
		
		private var _connector:Connector;
		private var _uiManager:UIManager;
		private var _3dController:ThreeDeeController;
		private var _social:SocialModel;		
		private var _stage3DProxy:Stage3DProxy;
		private var _stage3DManager:Stage3DManager;
				
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			Security.allowDomain("*") ;
			https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc7/
			Security.loadPolicyFile('https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc7/crossdomain.xml');
			removeEventListener(Event.ADDED_TO_STAGE, init);
			ModelsManager.instance.loadAllModels(setup);
			
		}
		
		private function setup():void {
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
			_stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			_social = new SocialModel(connectedToSocial, false);
		}
		
		
		private function connectedToSocial(socialUser:SocialUser):void {
			_uiManager = new UIManager(stage,_stage3DProxy);
			_3dController = new ThreeDeeController(stage, _stage3DProxy);
			_connector = new Connector(stage, socialUser);
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event : Event) : void {
			_3dController.render();
			_uiManager.render();
		}		
	}
	
}