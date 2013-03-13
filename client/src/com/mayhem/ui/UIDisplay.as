package com.mayhem.ui 
{
	
	import com.mayhem.game.GameData;
	import com.mayhem.game.GameStats;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.game.powerups.PowerupSlot;
	import com.mayhem.game.powerups.PowerupsModel;
	import com.mayhem.multiplayer.CoinsPackage;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.SocialSignals;
	import com.mayhem.signals.UISignals;
	import com.mayhem.SoundsManager;
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.text.BitmapFontTextFormat;
	import feathers.themes.AzureMobileTheme;
	import flash.filters.DropShadowFilter;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.GameSignals;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author availlant
	 */
	public class UIDisplay extends Screen
	{
		private var _gameHUD:GameHUD;
		private var _selectMenu:SelectMenu;
		private var _theme:AzureMobileTheme;
		//private var _titleLabel:Label;
		private var _igcTextField:Label;
		private var _levelTextField:Label;
		
		private var _endSessionScreen:EndSessionScreen;		
		
		private var _user:GameUserVO;
		private var _powerups:Vector.<PowerupDefinition>;
		private var _coinPacks:Vector.<CoinsPackage>;
		private var _slots:Vector.<PowerupSlot>;
		
		private var _previousCoins:uint;
		private var _previousXP:uint;
		
		private var _musicBtn:Button;
		
		private var _currentLevel:uint;
		
		public function UIDisplay() 
		{
			_theme = new AzureMobileTheme(Starling.current.stage, false);
			MultiplayerSignals.USER_LOADED.add(onUserLoaded);
			GameSignals.REMOVE_MENU.add(cleanup);
			MultiplayerSignals.POWERUP_UNLOCKED.add(onPowerupUnlocked);
			SocialSignals.COINS_PURCHASED.add(onCoinsPurchased);
			MultiplayerSignals.SLOT_UNLOCKED.add(onSlotPurchased);
			UISignals.BACK_TO_SELECTOR.add(backToSelector);
			UISignals.UPDATE_USER_INFO.add(updateUserInfo);	
			UISignals.REMOVE_STATS.add(removeEndSession);
			UISignals.SHOW_STATS.add(showGameSessionStats);	
			setView();			
		}	
		
		private function showGameSessionStats(gameStats:GameStats):void
		{
			_endSessionScreen = new EndSessionScreen();
			_endSessionScreen.displayStats(gameStats);
			addChild(_endSessionScreen);
			_gameHUD.resetTimer();
		}
		
		private function updateUserInfo(user:GameUserVO):void {
			if (_endSessionScreen) {
				_endSessionScreen.displayRewardCoins((user.igc - _previousCoins).toString() , (user.xp - _previousXP).toString());
			}
			var currentLevel:uint = (GameData.getLevelForXP(user.xp) + 1);
			_levelTextField.text = "Level " + currentLevel.toString() + " (" + user.xp + "/" + GameData.getNextLevelXP(user.xp) + ")";
			_igcTextField.text = "Coins:" + user.igc.toString();
			_previousCoins = user.igc;
			_previousXP = user.xp;
			checkNewUnlockedItems(user);
		}
		
		private function removeEndSession():void {
			_endSessionScreen.cleanup();
			removeChild(_endSessionScreen);
			_endSessionScreen = null;
		}
		
		
		private function checkNewUnlockedItems(user:GameUserVO):void {
			var currentLevel:uint = GameData.getLevelForXP(user.xp) + 1;
			var levelUp:Boolean = false;
			var newPowerUp:PowerupDefinition;
			var newSlot:PowerupSlot;
			if (_currentLevel != currentLevel) {
				levelUp = true;
				for (var i:uint = 0 ; i < _powerups.length ; i++ ) {
					if (_powerups[i].unlockLevel == currentLevel && user.powerups.indexOf(_powerups[i].id) == -1 ) {
						newPowerUp = _powerups[i];
						break;
					}
				}
				for (var j:uint = 0 ; j < _slots.length ; j++ ) {
					if (_slots[j].unlockLevel == currentLevel && uint(_slots[j].id.split("_")[1]) == user.powerupSlots ) {
						newSlot = _slots[j];
						break;
					}
				}
			}
			_currentLevel = currentLevel;
			
			
			if (newSlot != null) {
				_gameHUD.displayNewSlotPopup(_currentLevel, newSlot);
				MultiplayerSignals.LEVEL_UP.dispatch();
			}else if (newPowerUp != null) {
				_gameHUD.displayNewPowerupPopup(_currentLevel, newPowerUp);
				MultiplayerSignals.LEVEL_UP.dispatch();
			}else if (levelUp) {
				_gameHUD.displayLevelupPopup(_currentLevel);
				MultiplayerSignals.LEVEL_UP.dispatch();
			}			
		}
	
		
		private function backToSelector():void {
			removeEndSession();
			_gameHUD.cleanup();
			removeChild(_gameHUD);
			_selectMenu = new SelectMenu(_user,_powerups, _coinPacks, _slots, _theme);
			addChild(_selectMenu);	
			SoundsManager.startMenuLoop();
		}
		
		private function onSlotPurchased(user:GameUserVO, slot_id:String):void {
			_igcTextField.text = "Coins:" + user.igc.toString();
		}
		
		private function onCoinsPurchased(user:GameUserVO):void {
			_igcTextField.text = "Coins:" + user.igc.toString();
		}
		
		private function onPowerupUnlocked(user:GameUserVO, powerupId:String):void {
			_igcTextField.text = "Coins:" + user.igc.toString();
		}
		
		
		private function onUserLoaded(user:GameUserVO, powerups:Vector.<PowerupDefinition>, coinPacks:Vector.<CoinsPackage>, slots:Vector.<PowerupSlot>):void {
			if(user.hasMusic){
				_musicBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.Music()));
			}else {
				_musicBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.NoMusic()));
			}
			_user = user;
			_powerups = powerups;
			_coinPacks = coinPacks;
			_slots = slots;
			_igcTextField.text = "Coins:" + user.igc.toString();
			_currentLevel = GameData.getLevelForXP(user.xp) + 1;
			_levelTextField.text = "Level " + _currentLevel.toString() + " (" + user.xp + "/" + GameData.getNextLevelXP(user.xp)+")";
			_selectMenu = new SelectMenu(user, powerups, coinPacks, slots, _theme);
			_previousCoins = user.igc;
			_previousXP = user.xp;
			addChild(_selectMenu);		
		}

		
		
		private function cleanup():void {
			removeChild(_selectMenu);
			_gameHUD = new GameHUD();
			addChild(_gameHUD);
			SoundsManager.startGameLoop();
		}
		
		override protected function draw():void
		{
			
			_igcTextField.validate();
			var tf:BitmapFontTextFormat = _igcTextField.textRendererProperties.textFormat;
			_igcTextField.textRendererProperties.textFormat = null;
			tf.align = "left";
			_igcTextField.height = 36;
			_igcTextField.width = 200;
			_igcTextField.x = 5;
			_igcTextField.y = Starling.current.nativeStage.stageHeight - 72;
			_igcTextField.textRendererProperties.textFormat = tf;			
			
			_levelTextField.validate();
			_levelTextField.height = 36;
			_levelTextField.x = 5;
			_levelTextField.y = Starling.current.nativeStage.stageHeight - _levelTextField.height;
			_levelTextField.textRendererProperties.textFormat = tf;		
		}
		
		private function setView():void {
			_igcTextField = new Label();
			_igcTextField.text = 'Coins';
			addChild(_igcTextField);
			
			_levelTextField = new Label();
			_levelTextField.text = 'Level';
			addChild(_levelTextField);
			
			_musicBtn = new Button();
			_musicBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.Music()));
			_musicBtn.width = 40;
			_musicBtn.height = 40;
			_musicBtn.x = Starling.current.nativeStage.stageWidth - 45;
			_musicBtn.y = Starling.current.nativeStage.stageHeight - 45;
			_musicBtn.addEventListener(Event.TRIGGERED, onClickMusic);
			addChild(_musicBtn);
		}
		
		private function onClickMusic(e:Event):void 
		{
			if (SoundsManager.HAS_MUSIC) {
				_musicBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.NoMusic()));
				SoundsManager.stopAllSounds();
			}else {
				_musicBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.Music()));
				SoundsManager.startAllSounds();
			}		
			MultiplayerSignals.CHANGE_MUSIC_SETTINGS.dispatch(SoundsManager.HAS_MUSIC);
		}
		
		public static function formatTime(milli:uint):String {
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