package com.mayhem.ui 
{
	import com.mayhem.game.GameData;
	import com.mayhem.game.GameStats;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UISignals;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import starling.display.Button;
	import feathers.themes.AzureMobileTheme;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.core.Starling;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import com.mayhem.game.MovingCube;
	/**
	 * ...
	 * @author availlant
	 */
	public class UIDisplay extends Sprite
	{
		private var _healthBar:Quad;
		private var _powerUpBar:Quad;
		private var _xpBar:Quad;
		private var _levelTextField:TextField;
		private var _statusTextField:TextField;
		private var _timerTextField:TextField;
		private var _igcTextField:TextField;
		private  var _totalTimeString:String;
		private var _endSessionScreen:EndSessionScreen;
		
		public function UIDisplay() 
		{
			UISignals.ENERGY_UPDATE.add(onEnergyUpdate);
			UISignals.ENERGY_OUT.add(onEnergyOut);
			UISignals.OWNER_FELT.add(onOwnerFelt);
			UISignals.OWNER_RESPAWNED.add(clearTextFields);
			UISignals.OWNER_POWERUP_FILL.add(updatePowerMeter);
			UISignals.UPDATE_GAME_TIMER.add(updateGameTimer);
			UISignals.SHOW_STATS.add(showGameSessionStats);
			UISignals.UPDATE_USER_INFO.add(updateUserInfo);
			MultiplayerSignals.SESSION_RESTARTED.add(removeEndSession);
			createUI();			
		}
		
		private function updateUserInfo(igc:uint, xp:int):void {
			_igcTextField.text = "Coins:" + igc.toString();
			_levelTextField.text = "Level " + (GameData.getLevelForXP(xp) + 1).toString();
			_xpBar.scaleX = GameData.getFactorForXP(xp); 
			//trace("getLevelForXP", 0, GameData.getLevelForXP(0))
			//trace("getLevelForXP", 8, GameData.getLevelForXP(8))
			//trace("getLevelForXP", 201, GameData.getLevelForXP(201))
			//trace("getLevelForXP", 3000, GameData.getLevelForXP(3000))
			//trace("getLevelForXP", 17859, GameData.getLevelForXP(17859))
			//trace("getLevelForXP", 100000, GameData.getLevelForXP(100000))
		}
		
		private function removeEndSession(vehicleName:String):void {
			_endSessionScreen.visible = false;
		}
		
		private function showGameSessionStats(gameStats:GameStats):void {
			_endSessionScreen.displayStats(gameStats);
			_endSessionScreen.visible = true;			
			_timerTextField.text = _totalTimeString + "/" + _totalTimeString;
		}
	
		private function updateGameTimer(gameTime:uint):void {
			_timerTextField.text = formatTime(gameTime) + "/" + _totalTimeString;
		}
		
		private function updatePowerMeter(pupValue:uint):void {
			_powerUpBar.scaleX = (pupValue / GameData.POWERUP_FULL);
		}
		
		private function clearTextFields():void {
			onEnergyUpdate(1);
			_statusTextField.visible = false;
		}
		
		private function onOwnerFelt():void {
			onEnergyUpdate(0);
			_statusTextField.text = "YOU FELT, YOU MORON!!!";
			_statusTextField.visible = true;
		}
		private function onEnergyOut():void {
			_statusTextField.text = "YOU DIED, YOU MORON!!!";
			_statusTextField.visible = true;
		}
		private function onEnergyUpdate(prct:Number):void {
			_healthBar.width = GameData.VEHICLE_MAX_ENERGY * prct;
		}
		
		private function createUI():void {
			_totalTimeString = formatTime(GameData.GAME_SESSION_DURATION)
			
			_statusTextField = new TextField(800, 600, "---", "Verdana", 48);
			_statusTextField.color = 0x151515;
			addChild(_statusTextField);	
			_statusTextField.visible = false;
			
			var quad:Quad = new Quad(GameData.VEHICLE_MAX_ENERGY, 20, 0x666666);
			quad.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			quad.y = 10;
			addChild(quad);
			
			_xpBar = new Quad(GameData.VEHICLE_MAX_ENERGY, 20, 0xcc0000);
			_xpBar.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			_xpBar.y = 10;
			_xpBar.scaleX = 0;
			addChild(_xpBar);			
			
			_levelTextField = new TextField(200, 24, "LEVEL");
			_levelTextField.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			_levelTextField.y = 7;
			_levelTextField.color = 0xffffff;
			_levelTextField.hAlign = HAlign.LEFT;
			addChild(_levelTextField);
			
			
			var quad1:Quad = new Quad(GameData.VEHICLE_MAX_ENERGY, 20, 0x666666);
			quad1.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			quad1.y = 35;
			addChild(quad1);
			
			_healthBar = new Quad(GameData.VEHICLE_MAX_ENERGY, 20, 0xcc0000);
			_healthBar.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			_healthBar.y = 35;
			addChild(_healthBar);
			
			var textField1:TextField = new TextField(200, 24, "Energy");
			textField1.x = Starling.current.nativeStage.width - (GameData.VEHICLE_MAX_ENERGY + 10);
			textField1.y = 32;
			textField1.color = 0xffffff;
			textField1.hAlign = HAlign.LEFT;
			addChild(textField1);
			
			var quad2:Quad = new Quad(150, 20, 0x666666);
			quad2.x = _healthBar.x;
			quad2.y = 60;
			addChild(quad2);
			
			_powerUpBar = new Quad(150, 20, 0xcc0000);
			_powerUpBar.x = _healthBar.x;
			_powerUpBar.y = 60;
			addChild(_powerUpBar);
			_powerUpBar.scaleX = 0;
			
			var textField2:TextField = new TextField(200, 24, "PowerUp Meter");
			textField2.x = textField1.x;
			textField2.y = 57;
			textField2.color = 0xffffff;
			textField2.hAlign = HAlign.LEFT;
			addChild(textField2);
			
			_timerTextField = new TextField(150, 24, "Time");
			_timerTextField.x = textField1.x;
			_timerTextField.y = 80;
			_timerTextField.color = 0xffffff;
			_timerTextField.hAlign = HAlign.RIGHT;
			addChild(_timerTextField);
			
			_igcTextField = new TextField(150, 24, "Coins");
			_igcTextField.x = textField1.x;
			_igcTextField.y = _timerTextField.y + 18;
			_igcTextField.color = 0xffffff;
			_igcTextField.hAlign = HAlign.RIGHT;
			addChild(_igcTextField);
			
			_endSessionScreen = new EndSessionScreen();
			addChild(_endSessionScreen);
			_endSessionScreen.visible = false;
			
		}
		
		public function formatTime(milli:uint):String {
			var remainder:Number;
			var hours:Number = (milli / 1000) / ( 60 * 60 );
			var hFloor:Number = Math.floor(hours);
			remainder = hours - hFloor;
			hours = hFloor;
			var minutes:Number = remainder * 60;
			var mFloor:Number = Math.floor(minutes)
			remainder = minutes - mFloor;
			minutes = mFloor;
			var seconds:Number = remainder * 60;
			var sFloor:Number = Math.floor(seconds);
			remainder = seconds - sFloor;
			seconds = sFloor;
			var hString:String = hours < 10 ? hours.toString() : hours.toString();
			var mString:String = minutes < 10 ? "0"+minutes.toString() : minutes.toString();
			var sString:String = seconds < 10 ? "0" + seconds.toString() : seconds.toString();
			if(milli < 0 || isNaN(milli)) {
				return "00:00";
			}
			if(hours > 0) {
				return hString + ":" + mString + ":" + sString;
			}
			else {
				return mString + ":" + sString;
			}
		}
		
	}

}