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
		
		[Embed(source="/assets/collision.xml", mimeType="application/octet-stream")]
		private var _collisionXML:Class;
		[Embed(source="/assets/explosion.xml", mimeType="application/octet-stream")]
		private var _explosionXML:Class;
		
		private var _explosionFactory:EffectGroupFactoryS;
		private var _collisionFactory:EffectGroupFactoryS;
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
			var parts:* = new _collisionXML();
			var xml:XML = new XML(parts);
			_collisionFactory = new EffectGroupFactoryS();
			_collisionFactory.importCode(xml);
			
			var parts2:* = new _explosionXML();
			var xml2:XML = new XML(parts2);
			_explosionFactory = new EffectGroupFactoryS();
			_explosionFactory.importCode(xml2);
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
				if (eGroup.time >= _collisionFactory.effectDuration) {
					if(eGroup.onComplete != null)eGroup.onComplete();
					eGroup.parent.removeChild(eGroup);
					delete _runningParticles[eGroup];
					eGroup = null;
				}
			}
		}		
		
		public function getExplosionParticles(position:Vector3D, completeCallback:Function = null):void {
			if (position == null)
				position = new Vector3D();
				
			var effect:EffectGroup = _explosionFactory.createNeedStuff() as EffectGroup;
			effect.onComplete = completeCallback;
			_runningParticles[effect] = effect;
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
			//if (position == null)
				//position = new Vector3D();
//
			//var effect:EffectGroup = _collisionFactory.createNeedStuff() as EffectGroup;
			//effect.onComplete = completeCallback;
			//_runningParticles[effect] = effect;
			//effect.position = position;
			//_scene.addChild(effect);
			//effect.start();
		}
		
		public function getSparksParticles(position:Vector3D, completeCallback:Function = null):void {
			if (position == null)
				position = new Vector3D();

			var effect:EffectGroup = _collisionFactory.createNeedStuff() as EffectGroup;
			effect.onComplete = completeCallback;
			_runningParticles[effect] = effect;
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}		
	}

}