package com.mayhem.ui 
{
	
	import com.mayhem.multiplayer.GameUserVO;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.text.BitmapFontTextFormat;
	import feathers.themes.AzureMobileTheme;
	import flash.filters.DropShadowFilter;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.GameSignals;
	/**
	 * ...
	 * @author availlant
	 */
	public class UIDisplay extends Screen
	{
		private var _gameHUD:GameHUD;
		private var _selectMenu:SelectMenu;
		private var _theme:AzureMobileTheme;
		private var _titleLabel:Label;
		private var _igcTextField:Label;
		
		public function UIDisplay() 
		{
			_theme = new AzureMobileTheme(this, false);
			MultiplayerSignals.USER_LOADED.add(onUserLoaded);
			GameSignals.REMOVE_MENU.add(cleanup);
			
			setView();			
		}	
		
		
		private function onUserLoaded(user:GameUserVO):void {
			_igcTextField.text = "Coins:" + user.igc.toString();
			_selectMenu = new SelectMenu(user.vehicleId, user.textureId);
			addChild(_selectMenu);			
		}
		
		
		private function cleanup():void {
			_selectMenu.cleanup();
			removeChild(_selectMenu);
			_gameHUD = new GameHUD();
			addChild(_gameHUD);
		}
		
		override protected function draw():void
		{
			_titleLabel.validate();
			var tf:BitmapFontTextFormat = _titleLabel.textRendererProperties.textFormat;
			_titleLabel.textRendererProperties.textFormat = null;
			tf.size = 40;
			tf.color = 0xffffff;
			tf.align = "center";
			_titleLabel.textRendererProperties.textFormat = tf;
			_titleLabel.filter = BlurFilter.createDropShadow(3, 0.785, 0x000000, 1, 0, 1);
			
			_igcTextField.validate();
			tf = _igcTextField.textRendererProperties.textFormat;
			_igcTextField.textRendererProperties.textFormat = null;
			tf.align = "right";
			_igcTextField.height = 36;
			_igcTextField.width = 200;
			_igcTextField.x = Starling.current.nativeStage.stageWidth - _igcTextField.width - 10;
			_igcTextField.y = Starling.current.nativeStage.stageHeight - _igcTextField.height;
			_igcTextField.textRendererProperties.textFormat = tf;			
		}
		
		private function setView():void {
			_titleLabel = new Label();
			_titleLabel.width = Starling.current.nativeStage.stageWidth;
			_titleLabel.text = 'Bumper Mayhem'
			addChild(_titleLabel);
			
			_igcTextField = new Label();
			_igcTextField.text = 'Coins';
			addChild(_igcTextField);
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