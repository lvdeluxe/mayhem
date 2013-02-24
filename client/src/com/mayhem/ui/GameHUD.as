package com.mayhem.ui 
{
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.game.powerups.PowerupSlot;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.game.GameData;
	import com.mayhem.game.GameStats;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.Screen;
	import feathers.core.PopUpManager;
	import feathers.text.BitmapFontTextFormat;
	import starling.core.Starling;	
	import flash.utils.setTimeout;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.events.Event;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author availlant
	 */
	public class GameHUD extends Screen
	{
		private var _healthBar:ProgressBar;
		private var _healthLabel:Label;
		private var _statusTextField:Label;
		private var _timerTextField:Label;		
		private  var _totalTimeString:String;
		private var _endSessionScreen:EndSessionScreen;		
		private var _allPowerups:Vector.<Sprite> = new Vector.<Sprite>();
		private var _levelupContainer:Sprite;
		private var _closeBtn:Button;
		
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
			UISignals.SHOW_COUNTDOWN.add(showCountDown);			
			UISignals.REMOVE_STATS.add(removeEndSession);
			UISignals.SET_POWERUPS.add(setPowerups)
		}
		
		public function cleanup():void {
			UISignals.ENERGY_UPDATE.remove(onEnergyUpdate);
			UISignals.ENERGY_OUT.remove(onEnergyOut);
			UISignals.OWNER_FELT.remove(onOwnerFelt);
			UISignals.OWNER_RESPAWNED.remove(clearTextFields);
			UISignals.OWNER_POWERUP_FILL.remove(updatePowerMeter);
			UISignals.UPDATE_GAME_TIMER.remove(updateGameTimer);
			UISignals.SHOW_STATS.remove(showGameSessionStats);
					
			UISignals.SHOW_COUNTDOWN.remove(showCountDown);			
			UISignals.REMOVE_STATS.remove(removeEndSession);
			UISignals.SET_POWERUPS.remove(setPowerups);
		}
		
		private function setPowerups(selectedPowerups:Array):void {
			for (var i:uint = 0 ; i < selectedPowerups.length ; i++ ) {
				if(selectedPowerups[i] != ""){
					var powerup:Sprite = new Sprite();
					var img:Image = new Image(getTextureById(selectedPowerups[i]));
					powerup.addChild(img);
					var fill:Quad = new Quad(powerup.width, powerup.height, 0xcc0000);
					fill.pivotY = img.height;
					fill.name = "fill";
					fill.alpha = 0.5;
					fill.scaleY = 0;
					fill.y = img.height;
					powerup.addChild(fill);
					powerup.x = 10;
					powerup.y = 40 + ((i * 74));
					addChild(powerup);	
					_allPowerups.push(powerup)
				}
			}
		}
		
		private function getTextureById(powerup_id:String):Texture 
		{
			var texture:Texture;
			switch(powerup_id) {
				case "powerup_0":
					texture = Texture.fromBitmap(new TexturesManager.PowerUp1());
					break;
				case "powerup_1":
					texture = Texture.fromBitmap(new TexturesManager.PowerUp2());
					break;
				case "powerup_2":
					texture = Texture.fromBitmap(new TexturesManager.PowerUp3());
					break;
				case "powerup_3":
					texture = Texture.fromBitmap(new TexturesManager.PowerUp4());
					break;
				case "powerup_4":
					texture = Texture.fromBitmap(new TexturesManager.PowerUp5());
					break;
				case "":
					texture = Texture.fromBitmap(new TexturesManager.EmptySlot());
					break;
			}
			return texture;
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
			
			tf = _healthLabel.textRendererProperties.textFormat;
			tf.size = 16;
			tf.color = 0xffffff;
			tf.align = 'left';			
			_healthBar.validate();
			_healthBar.x = Starling.current.nativeStage.width - _healthBar.width - 10;
			_healthBar.y = 15;
			
			_healthLabel.validate();
			_healthLabel.height = _healthBar.height;
			_healthLabel.width = _healthBar.width - 10;
			_healthLabel.x = _healthBar.x + 10;
			_healthLabel.y = _healthBar.y;
			_healthLabel.textRendererProperties.textFormat = tf;
			
			_timerTextField.validate();
			tf = _timerTextField.textRendererProperties.textFormat;
			_timerTextField.textRendererProperties.textFormat = null;
			tf.align = 'left';
			tf.size = 24;
			//_timerTextField.height = _healthBar.height;
			//_timerTextField.width = _healthBar.width - 20;
			_timerTextField.x = 10//_healthBar.x + 10;
			_timerTextField.y = 5//_healthBar.y// + _healthBar.height + 5;
			_timerTextField.textRendererProperties.textFormat = tf;		
		}
		
		private function createUI():void {
			_totalTimeString = UIDisplay.formatTime(GameData.GAME_SESSION_DURATION);			
			_statusTextField = new Label();
			_statusTextField.text = "STATUS";
			_statusTextField.width = Starling.current.nativeStage.stageWidth;
			_statusTextField.y = (Starling.current.nativeStage.stageHeight / 2) - 30;
			_statusTextField.height = 60;
			addChild(_statusTextField);	
			_statusTextField.filter = BlurFilter.createDropShadow(3, 0.785, 0x000000, 1, 0, 1);
			_statusTextField.visible = false;
			
			_healthBar = new ProgressBar();
			_healthBar.minimum = 0;
			_healthBar.maximum = 1;
			_healthBar.value = 1;
			addChild(_healthBar);
			
			_healthLabel = new Label();
			_healthLabel.text = 'Energy'
			addChild(_healthLabel);
			
			_timerTextField = new Label();
			_timerTextField.text = 'Time';
			addChild(_timerTextField);
			
			_endSessionScreen = new EndSessionScreen();
			addChild(_endSessionScreen);
			_endSessionScreen.visible = false;
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
			var fillFactor:Number = pupValue / GameData.POWERUP_FULL
			for (var i:uint = 0 ; i < _allPowerups.length ; i++ ) {
				var fill:Quad = _allPowerups[i].getChildByName("fill") as Quad;
				fill.scaleY = fillFactor;
			}
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
		
		public function displayNewSlotPopup(level:uint, slot:PowerupSlot):void {
			var desc:String = "Congratulations!\nYou reached Level "+level.toString() + ".\nYou unlocked a new Power-Up Slot \n(Buy with "+slot.unlockCoins+" Coins)\nand you received a 500 Coins Gift."
			displayPopup(desc,75);
		}
		public function displayNewPowerupPopup(level:uint, powerup:PowerupDefinition):void {
			var desc:String = "Congratulations!\nYou reached Level "+level.toString() + ".\nYou unlocked the «" + powerup.title + "» Power-up \n(Buy with "+powerup.unlockCoins+" Coins)\nand you received a 500 Coins Gift"
			displayPopup(desc,75);
		}
		public function displayLevelupPopup(level:uint):void {
			var desc:String = "Congratulations!\nYou reached Level "+level.toString() + ".\nYou received a 500 Coins Gift."
			displayPopup(desc,100);
		}
		
		private function displayPopup(desc:String, posY:uint):void {
			_levelupContainer = new Sprite();
			var bg:Button = new Button();
			bg.width = 500;
			bg.height = 300;
			bg.touchable = false;			
			
			_closeBtn = new Button();
			_closeBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closeBtn.width = 30;
			_closeBtn.height = 30;
			_closeBtn.x = 465;
			_closeBtn.y = 5;
			_closeBtn.addEventListener(Event.TRIGGERED, onClosePopup);
			
			var levelupTitle:Label = new Label();
			levelupTitle.width = 500;
			levelupTitle.height = 24;
			levelupTitle.y = 20
			levelupTitle.text = "LEVEL-UP!";
			
			var levelupDesc:Label = new Label();
			levelupDesc.width = 400;
			levelupDesc.textRendererProperties.wordWrap = true;
			levelupDesc.height = 200;
			levelupDesc.x = 50;
			levelupDesc.y = posY;
			levelupDesc.text = desc;
			
			_levelupContainer.addChild(bg);
			_levelupContainer.addChild(levelupDesc);
			_levelupContainer.addChild(levelupTitle);
			_levelupContainer.addChild(_closeBtn);
			
			PopUpManager.addPopUp(_levelupContainer);
		}
		
		private function onClosePopup(e:Event):void 
		{
			PopUpManager.removePopUp(_levelupContainer);
		}
		
	}

}