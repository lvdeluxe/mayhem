package com.mayhem.ui 
{
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.game.GameData;
	import com.mayhem.game.GameStats;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.controls.Screen;
	import feathers.text.BitmapFontTextFormat;
	import starling.core.Starling;	
	import flash.utils.setTimeout;
	import starling.filters.BlurFilter;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameHUD extends Screen
	{
		private var _healthBar:ProgressBar;
		private var _healthLabel:Label;
		private var _powerUpBar:ProgressBar;
		private var _powerUpLabel:Label;
		private var _xpBar:ProgressBar;
		private var _levelTextField:Label;
		private var _statusTextField:Label;
		private var _timerTextField:Label;
		
		private  var _totalTimeString:String;
		private var _endSessionScreen:EndSessionScreen;
		
		public function GameHUD() 
		{
			setSignals();
			createUI();
		}
		
		private function setSignals():void {
			UISignals.ENERGY_UPDATE.add(onEnergyUpdate);
			UISignals.ENERGY_OUT.add(onEnergyOut);
			UISignals.OWNER_FELT.add(onOwnerFelt);
			UISignals.OWNER_RESPAWNED.add(clearTextFields);
			UISignals.OWNER_POWERUP_FILL.add(updatePowerMeter);
			UISignals.UPDATE_GAME_TIMER.add(updateGameTimer);
			UISignals.SHOW_STATS.add(showGameSessionStats);
			UISignals.UPDATE_USER_INFO.add(updateUserInfo);			
			UISignals.SHOW_COUNTDOWN.add(showCountDown);			
			UISignals.REMOVE_STATS.add(removeEndSession);
		}
		
		private function showCountDown():void {
			_statusTextField.visible = true;
			_statusTextField.text = "3";
			setTimeout(function():void {
				_statusTextField.text = "2";
			}, 1000);
			
			setTimeout(function():void {
				_statusTextField.text = "1";
			}, 2000);
			
			setTimeout(function():void {
				_statusTextField.text = "GO!";
			}, 3000);
			
			setTimeout(function():void {
				_statusTextField.text = "";
				_statusTextField.visible = false;
			}, 4000);
		}
		
		override protected function draw():void
		{
			var tf:BitmapFontTextFormat = _statusTextField.textRendererProperties.textFormat;
			_statusTextField.textRendererProperties.textFormat = null;
			tf.size = 48;
			tf.color = 0xffffff;
			_statusTextField.textRendererProperties.textFormat = tf;
			
			_xpBar.validate();
			_xpBar.x = Starling.current.nativeStage.width -_xpBar.width - 10;
			_xpBar.y = 10;
			
			_levelTextField.validate();
			tf = _levelTextField.textRendererProperties.textFormat;
			_levelTextField.textRendererProperties.textFormat = null;
			_levelTextField.height = _xpBar.height;
			_levelTextField.width = _xpBar.width - 10;
			_levelTextField.x = _xpBar.x + 10;
			_levelTextField.y = _xpBar.y;
			tf.size = 16;
			tf.color = 0xffffff;
			tf.align = 'left';
			_levelTextField.textRendererProperties.textFormat = tf;
			
			_healthBar.validate();
			_healthBar.x = Starling.current.nativeStage.width - _healthBar.width - 10;
			_healthBar.y = _xpBar.y + _xpBar.height + 5;
			
			_healthLabel.validate();
			_healthLabel.height = _healthBar.height;
			_healthLabel.width = _healthBar.width - 10;
			_healthLabel.x = _healthBar.x + 10;
			_healthLabel.y = _healthBar.y;
			_healthLabel.textRendererProperties.textFormat = tf;
			
			_powerUpBar.validate();
			_powerUpBar.x = Starling.current.nativeStage.width - _powerUpBar.width - 10;
			_powerUpBar.y = _healthBar.y + _healthBar.height + 5;
			
			_powerUpLabel.validate();
			_powerUpLabel.height = _powerUpBar.height;
			_powerUpLabel.width = _powerUpBar.width - 10;
			_powerUpLabel.x = _powerUpBar.x + 10;
			_powerUpLabel.y = _powerUpBar.y;
			_powerUpLabel.textRendererProperties.textFormat = tf;			
			
			_timerTextField.validate();
			tf = _timerTextField.textRendererProperties.textFormat;
			_timerTextField.textRendererProperties.textFormat = null;
			tf.align = 'right';
			tf.size = 16;
			_timerTextField.height = _powerUpBar.height;
			_timerTextField.width = _powerUpBar.width - 20;
			_timerTextField.x = _powerUpBar.x + 10;
			_timerTextField.y = _powerUpBar.y + _powerUpBar.height + 5;
			_timerTextField.textRendererProperties.textFormat = tf;
			
			
		}
		
		private function createUI():void {
			_totalTimeString = UIDisplay.formatTime(GameData.GAME_SESSION_DURATION)
			
			_statusTextField = new Label();
			_statusTextField.text = "YOUPI";
			_statusTextField.width = Starling.current.nativeStage.stageWidth;
			_statusTextField.y = (Starling.current.nativeStage.stageHeight / 2) - 30;
			_statusTextField.height = 60;
			addChild(_statusTextField);	
			_statusTextField.filter = BlurFilter.createDropShadow(3, 0.785, 0x000000, 1, 0, 1);
			_statusTextField.visible = false;
			
			_xpBar = new ProgressBar();
			_xpBar.minimum = 0;
			_xpBar.maximum = 1;
			_xpBar.value = 1;
			addChild(_xpBar);			
			
			_levelTextField = new Label();
			_levelTextField.text = 'Level';
			addChild(_levelTextField);
			
			_healthBar = new ProgressBar();
			_healthBar.minimum = 0;
			_healthBar.maximum = 1;
			_healthBar.value = 1;
			addChild(_healthBar);
			
			_healthLabel = new Label();
			_healthLabel.text = 'Energy'
			addChild(_healthLabel);
			
			_powerUpBar = new ProgressBar();
			_powerUpBar.minimum = 0;
			_powerUpBar.maximum = 1;
			_powerUpBar.value = 0;
			addChild(_powerUpBar);
			
			_powerUpLabel = new Label();
			_powerUpLabel.text = 'PowerUp Meter';
			addChild(_powerUpLabel);
			
			_timerTextField = new Label();
			_timerTextField.text = 'Time';
			addChild(_timerTextField);
			
			_endSessionScreen = new EndSessionScreen();
			addChild(_endSessionScreen);
			_endSessionScreen.visible = false;
		}
		
		private function updateUserInfo(igc:uint, xp:int):void {
			_levelTextField.text = "Level " + (GameData.getLevelForXP(xp) + 1).toString();
			_xpBar.value = GameData.getFactorForXP(xp); 
		}
		
		private function removeEndSession():void {
			_endSessionScreen.visible = false;
		}
		
		private function showGameSessionStats(gameStats:GameStats):void {
			_endSessionScreen.displayStats(gameStats);
			_endSessionScreen.visible = true;			
			_timerTextField.text = _totalTimeString + "/" + _totalTimeString;
		}
	
		private function updateGameTimer(gameTime:uint):void {
			_timerTextField.text = UIDisplay.formatTime(gameTime) + "/" + _totalTimeString;
		}
		
		private function updatePowerMeter(pupValue:uint):void {
			_powerUpBar.value = (pupValue / GameData.POWERUP_FULL);
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
			_healthBar.value = prct;
		}
		
	}

}