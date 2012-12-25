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
		private var _deathTextField:TextField;
		
		public function UIDisplay() 
		{
			UISignals.ENERGY_UPDATE.add(onEnergyUpdate);
			UISignals.ENERGY_OUT.add(onEnergyOut);
			UISignals.OWNER_FELT.add(onOwnerFelt);
			UISignals.OWNER_RESPAWNED.add(clearTextFields);
			createUI();
			
		}
		
		private function clearTextFields():void {
			onEnergyUpdate(1);
			removeChild(_deathTextField);
			_deathTextField.dispose();
		}
		
		private function onOwnerFelt():void {
			onEnergyUpdate(0);
			_deathTextField = new TextField(800, 600, "YOU FELT, YOU MORON!!!", "Verdana", 48);
			_deathTextField.color = 0x151515;
			addChild(_deathTextField);	
		}
		private function onEnergyOut():void {
			_deathTextField = new TextField(800, 600, "YOU DIED, YOU MORON!!!", "Verdana", 48);
			_deathTextField.color = 0x151515;
			addChild(_deathTextField);	
		}
		private function onEnergyUpdate(prct:Number):void {
			trace("onEnergyUpdate", prct)
			_healthBar.width = MovingCube.MAX_ENERGY * prct;
		}
		
		private function createUI():void {
			var quad:Quad = new Quad(MovingCube.MAX_ENERGY, 20, 0x666666);
			quad.x = Starling.current.nativeStage.width - (MovingCube.MAX_ENERGY + 10);
			quad.y = 10;
			addChild(quad);
			
			_healthBar = new Quad(MovingCube.MAX_ENERGY, 20, 0xcc0000);
			_healthBar.x = Starling.current.nativeStage.width - (MovingCube.MAX_ENERGY + 10);
			_healthBar.y = 10;
			addChild(_healthBar);
			
			var textField:TextField = new TextField(200, 24, "Energy");
			textField.x = Starling.current.nativeStage.width - (MovingCube.MAX_ENERGY + 10);
			textField.y = 7;
			textField.color = 0xffffff;
			textField.hAlign = HAlign.LEFT;
			addChild(textField);
		}
		
	}

}