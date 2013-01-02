package com.mayhem.ui 
{
	import com.mayhem.game.GameStats;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.UISignals;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.controls.text.TextFieldTextRenderer;
	import feathers.controls.ToggleSwitch;
	import feathers.data.ListCollection;
	import feathers.text.BitmapFontTextFormat;
	import feathers.themes.AzureMobileTheme;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
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
		private var _statsTextField:Label;
		private var _alltimeTextField:Label;
		private var _sessionTextField:Label;
		private var _toggle:ToggleSwitch;
		private var _stats:GameStats;
		
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
			
			_statsTextField = new Label();
			_statsTextField.width = 600;
			_statsTextField.height = 400;
			_statsTextField.text = "youpi je suis une saucisse";
			
			_statsTextField.x = (Starling.current.nativeStage.width - _statsTextField.width) / 2;
			_statsTextField.y = ((Starling.current.nativeStage.height - _statsTextField.height) / 2);
			addChild(_statsTextField);
			
			_toggle = new ToggleSwitch();
			_toggle.addEventListener( Event.CHANGE, onToggleChange );
			_toggle.showLabels = false;
			_toggle.isSelected = false;
			addChild(_toggle);
			
			_alltimeTextField = new Label();
			_alltimeTextField.width = 200;
			_alltimeTextField.text = "All-Time Stats";	
			addChild(_alltimeTextField);
			
			_sessionTextField = new Label();
			_sessionTextField.width = 200;
			_sessionTextField.text = "Session Stats";
			addChild(_sessionTextField);
		}
		
		private function onToggleChange(event:Event):void {
			var toggle:ToggleSwitch = ToggleSwitch( event.currentTarget );
			if (toggle.isSelected) {
				showAlltimeStats();
			}else {
				showSessionStats();
			}
		}
		
		override protected function draw():void
		{			
			_buttonGroup.validate();
			_buttonGroup.x = (Starling.current.nativeStage.width - this._buttonGroup.width) / 2;
			_buttonGroup.y = ((Starling.current.nativeStage.height - _buttonGroup.height) / 2) + 200;
			
			_toggle.validate();
			_toggle.x = (Starling.current.nativeStage.width - _toggle.width) / 2;
			_toggle.y = _buttonGroup.y - _buttonGroup.height -20;
			
			_alltimeTextField.validate();
			var tf:BitmapFontTextFormat = _alltimeTextField.textRendererProperties.textFormat;
			_alltimeTextField.textRendererProperties.textFormat = null;
			//tf.color = 0x00ccff
			tf.align = TextFormatAlign.LEFT;
			_alltimeTextField.textRendererProperties.textFormat = tf;
			_alltimeTextField.height = _toggle.height
			_alltimeTextField.x = _toggle.x + _toggle.width +15;
			_alltimeTextField.y = _toggle.y+15;
			
			_sessionTextField.validate();
			tf = _sessionTextField.textRendererProperties.textFormat;
			_sessionTextField.textRendererProperties.textFormat = null;
			//tf.color = 0xff99aa
			tf.align = TextFormatAlign.RIGHT;
			_sessionTextField.height = _toggle.height
			_sessionTextField.textRendererProperties.textFormat = tf;
			_sessionTextField.x = _toggle.x - (_sessionTextField.width) - 15;
			_sessionTextField.y = _toggle.y +15
		}
		
		public function displayStats(gStats:GameStats):void {
			_stats = gStats;
			_toggle.isSelected = false;
			showSessionStats();
			
		}
		private function showSessionStats():void{
			var str:String = "SESSION STATISTICS\n"+
			"You hit " + _stats.current_num_hits_inflicted.toString() + " enemies.\n" +
			"You've been hit " + _stats.current_num_hits_received.toString() + " times.\n"+			
			"You destroyed " + _stats.current_num_kills_inflicted.toString() + " enemies.\n" +
			"You've been destroyed " + _stats.current_num_kills_received.toString() + " times.\n" +
			"You felt " + _stats.current_num_felt.toString() + " times.\n" +
			"Max speed at impact was "+uint(_stats.current_max_speed ).toString() + " km/h."
			_statsTextField.text = str;
		}
		private function showAlltimeStats():void{
			var str:String = "ALL-TIME STATISTICS ("+_stats.alltime_sessions_played+" SESSIONS)\n"+
			"You hit " + _stats.alltime_num_hits_inflicted.toString() + " enemies.\n" +
			"You've been hit " + _stats.alltime_num_hits_received.toString() + " times.\n"+			
			"You destroyed " + _stats.alltime_num_kills_inflicted.toString() + " enemies.\n" +
			"You've been destroyed " + _stats.alltime_num_kills_received.toString() + " times.\n" +
			"You felt " + _stats.alltime_num_felt.toString() + " times.\n" +
			"Max speed at impact was "+uint(_stats.alltime_max_speed ).toString() + " km/h."
			_statsTextField.text = str;
		}
		
		private function stopPlaying(event:Event):void {
			trace("stopPlaying")
		}
		
		private function restart(event:Event):void {
			UISignals.CLICK_RESTART.dispatch();
		}
		
	}

}