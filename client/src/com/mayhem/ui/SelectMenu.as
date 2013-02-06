package com.mayhem.ui 
{
	import com.mayhem.game.ModelsManager;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.UISignals;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import feathers.text.BitmapFontTextFormat;
	import feathers.themes.AzureMobileTheme;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author availlant
	 */
	public class SelectMenu extends Screen
	{
		
		private var _startButton:Button;
		private var _prevButton:Button;
		private var _nextButton:Button;
		private var _vehicleId:uint;
		private var _textureId:uint;
		private var _colorSelector:ButtonGroup;
		private var _powerupsSelector:ButtonGroup;
		private var _powerupDefs:Vector.<PowerupDefinition>;
		private var _callout:Callout;
		private var _user:GameUserVO;
		
		
		public function SelectMenu(user:GameUserVO, powerupDefs:Vector.<PowerupDefinition>) 
		{
			_user = user;
			trace(_user.powerups)
			_textureId = user.textureId;
			_vehicleId = user.vehicleId;
			_powerupDefs = powerupDefs;
			_startButton = new Button();
			_startButton.label = "Start";
			_startButton.width = 200;
			_startButton.addEventListener(Event.TRIGGERED, startGame);			
			
			addChild(_startButton);
			setTextureSelector();
			setPowerUpsSelector();
			setVehicleButtons();			
		}
		
		private function setPowerUpsSelector():void 
		{
			var label:Label = new Label();
			label.text = "Select your Power-Ups";
			label.width = 600;
			label.x = (Starling.current.nativeStage.stageWidth - 600 )  / 2;
			label.y = 100;
			addChild(label);
			
			var btnContainer:Sprite = new Sprite();			
			
			var rolloutShape:Quad = new Quad(330, 90, 0xcc0000);
			rolloutShape.alpha = 0;
			rolloutShape.x = -20;
			rolloutShape.y = -20;
			btnContainer.addChild(rolloutShape)
			rolloutShape.touchable = true;
			rolloutShape.addEventListener(TouchEvent.TOUCH, onTouchRolloutShape);
			
			var btn1:Button = new Button();
			btn1.name = _powerupDefs[0].id;
			btn1.width = 50;
			btn1.height = 50;
			btn1.defaultIcon = new Image(getTextureByName(btn1.name));
			btnContainer.addChild(btn1);
			btn1.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			trace(btn1.name)
			
			var btn2:Button = new Button();
			btn2.name = _powerupDefs[1].id;
			btn2.width = 50;
			btn2.height = 50;
			btn2.x = btn1.x + btn1.width + 10;
			btn2.defaultIcon = new Image(getTextureByName(btn2.name));
			btnContainer.addChild(btn2);
			btn2.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			trace(btn2.name)
			
			var btn3:Button = new Button();
			btn3.name = _powerupDefs[2].id;
			btn3.width = 50;
			btn3.height = 50;
			btn3.x = btn2.x + btn2.width + 10;
			btn3.defaultIcon = new Image(getTextureByName(btn3.name));
			btnContainer.addChild(btn3);
			btn3.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			trace(btn3.name)
			
			var btn4:Button = new Button();
			btn4.name = _powerupDefs[3].id;
			btn4.width = 50;
			btn4.height = 50;
			btn4.x = btn3.x + btn3.width + 10;
			btn4.defaultIcon = new Image(getTextureByName(btn4.name));
			btnContainer.addChild(btn4);
			btn4.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			trace(btn4.name)
			
			var btn5:Button = new Button();
			btn5.name = _powerupDefs[4].id;
			btn5.width = 50;
			btn5.height = 50;
			btn5.x = btn4.x + btn4.width + 10;
			btn5.defaultIcon = new Image(getTextureByName(btn5.name));
			btnContainer.addChild(btn5);
			btn5.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			trace(btn5.name)
			
			
			addChild(btnContainer);
			btnContainer.y = 150;
			btnContainer.x = (Starling.current.nativeStage.stageWidth / 2) - 145;
		}
		
		private function getTextureByName(name:String):Texture {
			switch(name) {
				case _powerupDefs[0].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp1_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp1());
					}
					break;
				case _powerupDefs[1].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp2_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp2());
					}
					break;
				case _powerupDefs[2].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp3_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp3());
					}
					break;
				case _powerupDefs[3].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp4_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp4());
					}
					break;
				case _powerupDefs[4].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp5_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp5());
					}
					break;
			}
			return new Texture();
		}
		
		private function onTouchRolloutShape(event:TouchEvent):void 
		{
			var button:Quad = Quad( event.currentTarget );
			var touchHover:Touch = event.getTouch(button, TouchPhase.HOVER);
			if (touchHover) {
				if (_callout) {
					_callout.close(true);
					_callout = null;
				}
				
			}
		}
		
		private function onTouchPowerup(event:TouchEvent):void 
		{
			var button:Button = Button( event.currentTarget );
			var touchHover:Touch = event.getTouch(button, TouchPhase.HOVER);
			
			if (touchHover) {
				if (_callout != null) {
					_callout.close(true);
				}
				var powerupDescTextfield:Label = new Label();
				powerupDescTextfield.text = getDescriptionByButtonName(button.name);
				_callout = Callout.show( powerupDescTextfield, button, "DIRECTION_ANY", false);
				_callout.touchable = false;
				var size:Point = new Point(_callout.width * 0.5, _callout.height * 0.75)
				var calloutX:Number = _callout.x
				_callout.setSize(size.x, size.y)
				_callout.x = calloutX + (size.x / 2)
				powerupDescTextfield.validate();
				var tf:BitmapFontTextFormat = powerupDescTextfield.textRendererProperties.textFormat;
				powerupDescTextfield.textRendererProperties.textFormat = null;
				tf.size = 12;
				powerupDescTextfield.textRendererProperties.textFormat = tf;
			}
		}
		
		private function getDescriptionByButtonName(name:String):String 
		{
			switch(name) {
				case _powerupDefs[0].id:
					return _powerupDefs[0].description
					break;
				case _powerupDefs[1].id:
					return _powerupDefs[1].description
					break;
				case _powerupDefs[2].id:
					return _powerupDefs[2].description
					break;
				case _powerupDefs[3].id:
					return _powerupDefs[3].description
					break;
				case _powerupDefs[4].id:
					return _powerupDefs[4].description
					break;
			}
			return "";
		}
		
		
		
		public function cleanup():void {
			//_startButton.removeEventListener(Event.TRIGGERED, startGame);
			//removeChild(_startButton);
			//prevButton.removeEventListener( Event.TRIGGERED, prevVehicle );
			//nextButton.removeEventListener( Event.TRIGGERED, nextVehicle );
			//removeChild(prevButton);
			//removeChild(nextButton);
		}
		
		
		private function startGame(event:Event):void {
			GameSignals.SESSION_START.dispatch(_vehicleId, _textureId);
			_startButton.removeEventListener(Event.TRIGGERED, startGame);
			removeChild(_startButton);
			_prevButton.removeEventListener( Event.TRIGGERED, prevVehicle );
			_nextButton.removeEventListener( Event.TRIGGERED, nextVehicle );
			removeChild(_prevButton);
			removeChild(_nextButton);
			removeChild(_colorSelector);
		}
		
		private function setVehicleButtons():void {
			_prevButton = new Button();
			_prevButton.label = "<<";
			addChild(_prevButton);
			_prevButton.addEventListener( Event.TRIGGERED, prevVehicle );
			
			_nextButton = new Button();
			_nextButton.label = ">>";
			addChild(_nextButton);
			_nextButton.addEventListener( Event.TRIGGERED, nextVehicle );
		}
		
		private function prevVehicle(event:Event):void {
			if (_vehicleId == 0)
				return 
			_vehicleId --;
			UISignals.SET_VEHICLE.dispatch(_vehicleId);
		}
		
		private function nextVehicle(event:Event):void {
			if (_vehicleId == ModelsManager.instance.maxVehicles - 1)
				return;
			_vehicleId++;
			UISignals.SET_VEHICLE.dispatch(_vehicleId);
		}
		
		private function setTextureSelector():void {
			_colorSelector = new ButtonGroup();
			
			_colorSelector.width = 300;
			_colorSelector.height = 30;
			_colorSelector.direction = "horizontal";
			
			_colorSelector.dataProvider = new ListCollection( [
				{ label: "", defaultIcon:new Quad(20, 20, 0x00d3dc), triggered:setColor_0},
				{ label: "", defaultIcon:new Quad(20, 20, 0x00dc16), triggered:setColor_1},
				{ label: "", defaultIcon:new Quad(20, 20, 0xce01da), triggered:setColor_2},
				{ label: "", defaultIcon:new Quad(20, 20, 0xdb0602), triggered:setColor_3},
				{ label: "", defaultIcon:new Quad(20, 20, 0xe7d300), triggered:setColor_4}
			]);		
			
			addChild(_colorSelector);
			_colorSelector.x = (Starling.current.nativeStage.stageWidth - _colorSelector.width )  / 2 
			
		}
		
		private function setColor_0(event:Event):void {
			_textureId = 0;
			UISignals.SET_TEXTURE.dispatch(0);
		}
		private function setColor_1(event:Event):void {
			_textureId = 1;
			UISignals.SET_TEXTURE.dispatch(1);
		}
		private function setColor_2(event:Event):void {
			_textureId = 2;
			UISignals.SET_TEXTURE.dispatch(2);
		}
		private function setColor_3(event:Event):void {
			_textureId = 3;
			UISignals.SET_TEXTURE.dispatch(3);
		}
		private function setColor_4(event:Event):void {
			_textureId = 4;
			UISignals.SET_TEXTURE.dispatch(4);
		}
		
		
		override protected function draw():void
		{			
			_startButton.validate();
			_startButton.x = (Starling.current.nativeStage.stageWidth - _startButton.width) / 2;
			_startButton.y = Starling.current.nativeStage.stageHeight - _startButton.height - 50;
			
			_colorSelector.y = _startButton.y - 65; 
			
			_prevButton.validate();
			_prevButton.x = ((Starling.current.nativeStage.stageWidth - _prevButton.width) / 2) - 350;
			_prevButton.y = (Starling.current.nativeStage.stageHeight - _prevButton.height) / 2;
			
			_nextButton.validate();
			_nextButton.x = ((Starling.current.nativeStage.stageWidth - _nextButton.width) / 2) + 350;
			_nextButton.y = (Starling.current.nativeStage.stageHeight - _nextButton.height) / 2;
		}
		
	}

}