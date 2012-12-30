package com.mayhem.ui 
{
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.UISignals;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import feathers.themes.AzureMobileTheme;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	/**
	 * ...
	 * @author availlant
	 */
	public class EndSessionScreen extends Screen
	{
		
		private var _background:Quad;
		private var _stopButton:Button;
		private var _playButton:Button;
		private var _theme:AzureMobileTheme;
		private var _buttonGroup:ButtonGroup;
		
		public function EndSessionScreen() 
		{
			_theme = new AzureMobileTheme(this, false);
			_background = new Quad(Starling.current.nativeStage.width, Starling.current.nativeStage.height, 0x000000);
			_background.alpha = 0.75;
			addChild(_background);
			
			
			_buttonGroup = new ButtonGroup();
			addChild(_buttonGroup);
			_buttonGroup.direction = "horizontal";
			_buttonGroup.dataProvider = new ListCollection( [
				{ label: "Play Again", triggered: restart },
				{ label: "Stop Playing", triggered: stopPlaying }
			]);			
		}
		
		override protected function draw():void
		{			
			_buttonGroup.validate();
			_buttonGroup.x = (Starling.current.nativeStage.width - this._buttonGroup.width) / 2;
			_buttonGroup.y = ((Starling.current.nativeStage.height - _buttonGroup.height) / 2) + 200;
		}
		
		private function stopPlaying(event:Event):void {
			trace("stopPlaying")
		}
		
		private function restart(event:Event):void {
			UISignals.CLICK_RESTART.dispatch();
		}
		
	}

}