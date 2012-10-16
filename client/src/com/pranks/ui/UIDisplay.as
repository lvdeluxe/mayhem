package com.pranks.ui 
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	/**
	 * ...
	 * @author availlant
	 */
	public class UIDisplay extends Sprite
	{
		
		public function UIDisplay() 
		{
			//createUI();
			//var textField:TextField = new TextField(400, 300, "Welcome to Starling!");
			//addChild(textField);
		}
		
		private function createUI():void {
			var quad:Quad = new Quad(200, 200, 0xcc0000);
			quad.x = 10;
			quad.y = 10;
			addChild(quad);
		}
		
	}

}