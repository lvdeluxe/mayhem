package com.mayhem.ui 
{
	import com.mayhem.signals.UISignals;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.core.Starling;
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
		
		public function UIDisplay() 
		{
			UISignals.ENERGY_UPDATE.add(onEnergyUpdate);
			UISignals.ENERGY_OUT.add(onEnergyOut);
			createUI();
			trace(this.parent)
			var textField:TextField = new TextField(800, 600, "WTF!!!", "Verdana", 48);
			textField.color = 0xffffff;
			addChild(textField);	
			
		}
		
		private function onEnergyOut():void {
			var textField:TextField = new TextField(800, 600, "YOU DIED!!!", "Verdana", 48);
			textField.color = 0xffffff;
			addChild(textField);	
		}
		private function onEnergyUpdate(prct:Number):void {
			_healthBar.width = MovingCube.MAX_ENERGY * prct;
		}
		
		private function createUI():void {
			var quad:Quad = new Quad(200, 20, 0x666666);
			quad.x = Starling.current.nativeStage.width - 210;
			quad.y = 10;
			addChild(quad);
			
			_healthBar = new Quad(200, 20, 0xcc0000);
			_healthBar.x = Starling.current.nativeStage.width - 210;
			_healthBar.y = 10;
			addChild(_healthBar);
			
			var textField:TextField = new TextField(200, 24, "Energy");
			textField.x = Starling.current.nativeStage.width - 210;
			textField.y = 7;
			textField.color = 0xffffff;
			textField.hAlign = HAlign.LEFT;
			addChild(textField);
		}
		
	}

}