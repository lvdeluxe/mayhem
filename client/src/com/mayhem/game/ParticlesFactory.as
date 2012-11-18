package com.mayhem.game 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.containers.Scene3D;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import particleEditor.EffectGroupFactoryS;
	import flash.geom.Vector3D;
	import particleEditor.EffectGroup;
	 
	public class ParticlesFactory 
	{
		private static var _instance:ParticlesFactory;
		private static var _enableInstantiation:Boolean = false;		
		
		[Embed(source="/assets/particles.xml", mimeType="application/octet-stream")]
		private var _particlesXML:Class;
		private var _effectsFactory:EffectGroupFactoryS;
		private var _scene:Scene3D;
		private var _runningParticles:Dictionary = new Dictionary();
		
		public function ParticlesFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pScene:Scene3D):void {
			_scene = pScene;
			var parts:* = new _particlesXML();
			var xml:XML = new XML(parts);
			_effectsFactory = new EffectGroupFactoryS();
			_effectsFactory.importCode(xml);
		}
		
		public static function get instance():ParticlesFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ParticlesFactory();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		public function checkRemoveParticles():void {
			for each(var eGroup:EffectGroup in _runningParticles) {
				if (eGroup.time >= _effectsFactory.effectDuration) {
					if(eGroup.onComplete != null)eGroup.onComplete();
					eGroup.parent.removeChild(eGroup);
					delete _runningParticles[eGroup];
					eGroup = null;
				}
			}
		}		
		
		public function getSparksParticles(position:Vector3D, completeCallback:Function = null):void {
			if (position == null)
				position = new Vector3D();

			var effect:EffectGroup = _effectsFactory.createNeedStuff() as EffectGroup;
			effect.onComplete = completeCallback;
			_runningParticles[effect] = effect;
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}		
	}

}