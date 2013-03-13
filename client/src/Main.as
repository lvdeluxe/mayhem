package
{
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import com.mayhem.game.GameData;
	import com.mayhem.game.powerups.PowerupsModel;
	import com.mayhem.game.ThreeDeeController;
	import com.mayhem.multiplayer.Connector;
	import com.hibernum.social.model.SocialModel;
	import com.hibernum.social.model.SocialUser;
	import com.mayhem.SoundsManager;
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
			_social = new SocialModel(connectedToSocial, true);
			//for (var i:uint = 0 ; i < 100 ; i++ ) {
				//var rndKillsInflicted:uint = Math.random() * 50;
				//var rndKillsReceived:uint = Math.random() * 50;
				//var rndHitsInflicted:uint = Math.random() * 500;
				//var rndHitsReceived:uint = Math.random() * 500;
				//var rndSpeed:uint = Math.random() * 300;
				//var rndXP:uint = Math.random() * 1000;
				//testBalancing(rndKillsInflicted, rndKillsReceived, rndHitsInflicted, rndHitsReceived, rndSpeed, rndXP);
			//}
		}
		
		private function testBalancing(kI:uint, kR:uint, hI:uint, hR:uint, mS:uint, currXP:uint ):void {
			var killsInflicted:uint = kI;
			var killReceived:uint = kR;
			var hitsInflicted:uint = hI;
			var hitsReceived:uint = hR;
			var maxSpeed:uint = mS;
			var currentXP:uint = currXP;
			var level:uint = GameData.getLevelForXP(currentXP) + 1;
			var factorXP:Number = 0.01;
			var factorCoins:Number = 0.1;
			var diffKills:int  = killsInflicted - killReceived;
			var diffHits:int  = hitsInflicted - hitsReceived;
			var baseXP:uint = 5;
			var baseCoins:uint = 100;
			
			var bonusKillsXP:Number = diffKills > 0 ? (diffKills * level * factorXP) : 0;
			var bonusHitsXP:Number = diffHits > 0 ? diffHits * level * factorXP : 0;
			var bonusSpeedXP:Number = (maxSpeed > 150) ? (maxSpeed - 150) * level * factorXP : 0;
			var bonusKillsCoins:Number = diffKills > 0 ? (diffKills * level * factorCoins) : 0;
			var bonusHitsCoins:Number = diffHits > 0 ? diffHits * level * factorCoins : 0;
			var bonusSpeedCoins:Number = (maxSpeed > 150) ? (maxSpeed - 150) * level * factorCoins : 0;
			
			var rewardXP:uint = uint(baseXP + bonusKillsXP + bonusHitsXP + bonusSpeedXP);
			var rewardCoins:uint = uint(baseCoins + bonusKillsCoins + bonusHitsCoins + bonusSpeedCoins);
			
			trace("CURRENT LEVEL = " + level + 
			"\nkillsInflicted = " + killsInflicted +
			"\nkillReceived = " + killReceived + 
			"\nhitsInflicted = " + hitsInflicted + 
			"\nhitsReceived = " + hitsReceived + 
			"\nmaxSpeed = " + maxSpeed + 
			"\n==================" + 
			"\nReward XP = " + rewardXP + 
			"\nReward Coins = " + rewardCoins + 
			"\n NEXT LEVEL = " + (GameData.getLevelForXP(currentXP + rewardXP) + 1) + 
			"\n/////////////////////////////////\n");
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