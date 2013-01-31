package com.mayhem.ui 
{
	import com.mayhem.game.ModelsManager;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.UISignals;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Screen;
	import feathers.data.ListCollection;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.Event;
	/**
	 * ...
	 * @author availlant
	 */
	public class SelectMenu extends Screen
	{
		
		private var _startButton:Button;
		private var prevButton:Button;
		private var nextButton:Button;
		private var _vehicleId:uint;
		private var _textureId:uint;
		private var _buttonGroup:ButtonGroup
		
		
		public function SelectMenu(vId:uint, tId:uint) 
		{
			_textureId = tId;
			_vehicleId = vId;
			_startButton = new Button();
			_startButton.label = "Start";
			_startButton.width = 200;
			_startButton.addEventListener(Event.TRIGGERED, startGame);
			
			addChild(_startButton);
			setTextureSelector();
			setVehicleButtons();			
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
			prevButton.removeEventListener( Event.TRIGGERED, prevVehicle );
			nextButton.removeEventListener( Event.TRIGGERED, nextVehicle );
			removeChild(prevButton);
			removeChild(nextButton);
			removeChild(_buttonGroup);
		}
		
		private function setVehicleButtons():void {
			prevButton = new Button();
			prevButton.label = "<<";
			addChild(prevButton);
			prevButton.addEventListener( Event.TRIGGERED, prevVehicle );
			
			nextButton = new Button();
			nextButton.label = ">>";
			addChild(nextButton);
			nextButton.addEventListener( Event.TRIGGERED, nextVehicle );
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
			_buttonGroup = new ButtonGroup();
			
			_buttonGroup.width = 300;
			_buttonGroup.height = 30;
			_buttonGroup.direction = "horizontal";
			
			_buttonGroup.dataProvider = new ListCollection( [
				{ label: "", defaultIcon:new Quad(20, 20, 0x00d3dc), triggered:setColor_0},
				{ label: "", defaultIcon:new Quad(20, 20, 0x00dc16), triggered:setColor_1},
				{ label: "", defaultIcon:new Quad(20, 20, 0xce01da), triggered:setColor_2},
				{ label: "", defaultIcon:new Quad(20, 20, 0xdb0602), triggered:setColor_3},
				{ label: "", defaultIcon:new Quad(20, 20, 0xe7d300), triggered:setColor_4}
			]);		
			
			addChild(_buttonGroup);
			_buttonGroup.x = (Starling.current.nativeStage.stageWidth - _buttonGroup.width )  / 2 
			_buttonGroup.y = 150; 
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
			
			prevButton.validate();
			prevButton.x = ((Starling.current.nativeStage.stageWidth - prevButton.width) / 2) - 350;
			prevButton.y = (Starling.current.nativeStage.stageHeight - prevButton.height) / 2;
			
			nextButton.validate();
			nextButton.x = ((Starling.current.nativeStage.stageWidth - nextButton.width) / 2) + 350;
			nextButton.y = (Starling.current.nativeStage.stageHeight - nextButton.height) / 2;
		}
		
	}

}