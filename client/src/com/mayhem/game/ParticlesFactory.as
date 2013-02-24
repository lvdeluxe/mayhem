package com.mayhem.game 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import particleEditor.EffectGroupFactoryS;
	import flash.geom.Vector3D;
	import particleEditor.EffectGroup;
	 
	public class ParticlesFactory 
	{
		private static var _instance:ParticlesFactory;
		private static var _enableInstantiation:Boolean = false;		
		
		[Embed(source="/assets/particles/collision.xml", mimeType="application/octet-stream")]
		private var _collisionXML:Class;
		[Embed(source="/assets/particles/explosion.xml", mimeType="application/octet-stream")]
		private var _explosionXML:Class;
		[Embed(source="/assets/particles/danger_zone.xml", mimeType="application/octet-stream")]
		private var _dangerXML:Class;
		[Embed(source="/assets/particles/death.xml", mimeType="application/octet-stream")]
		private var _deathXML:Class;
		[Embed(source="/assets/particles/random_ray.xml", mimeType="application/octet-stream")]
		private var _randomRayXML:Class;
		[Embed(source="/assets/particles/shield.xml", mimeType="application/octet-stream")]
		private var _shieldXML:Class;
		
		private var _randomRayFactory:EffectGroupFactoryS;
		private var _explosionFactory:EffectGroupFactoryS;
		private var _collisionFactory:EffectGroupFactoryS;
		private var _dangerFactory:EffectGroupFactoryS;
		private var _deathFactory:EffectGroupFactoryS;
		private var _shieldFactory:EffectGroupFactoryS;
		private var _scene:Scene3D;
		private var _runningParticles:Dictionary = new Dictionary();
		
		public function ParticlesFactory() 
		{
			if (!_enableInstantiation) {
				throw new Error('This class is a Singleton, should not be instanciated!');
			}
		}
		
		public function initialize(pScene:Scene3D):void {
			_runningParticles = new Dictionary();
			_scene = pScene;
			var parts:* = new _collisionXML();
			var xml:XML = new XML(parts);
			_collisionFactory = new EffectGroupFactoryS();
			_collisionFactory.importCode(xml);
			
			var parts2:* = new _explosionXML();
			var xml2:XML = new XML(parts2);
			_explosionFactory = new EffectGroupFactoryS();
			_explosionFactory.importCode(xml2);
			
			var parts3:* = new _dangerXML();
			var xml3:XML = new XML(parts3);
			_dangerFactory = new EffectGroupFactoryS();
			_dangerFactory.importCode(xml3);
			
			var parts4:* = new _deathXML();
			var xml4:XML = new XML(parts4);
			_deathFactory = new EffectGroupFactoryS();
			_deathFactory.importCode(xml4);
			
			var parts5:* = new _randomRayXML();
			var xml5:XML = new XML(parts5);
			_randomRayFactory = new EffectGroupFactoryS();
			_randomRayFactory.importCode(xml5);
			
			var parts6:* = new _shieldXML();
			var xml6:XML = new XML(parts6);
			_shieldFactory = new EffectGroupFactoryS();
			_shieldFactory.importCode(xml6);
		}
		
		public static function get instance():ParticlesFactory {
			if (!_instance) {
				_enableInstantiation = true
				_instance = new ParticlesFactory();
				_enableInstantiation = false;
			}
			return _instance;
		}
		
		public function cleanup():void {
			for each(var eGroup:Object in _runningParticles) {
				var group:EffectGroup = eGroup.particleEffect;
				group.parent.removeChild(group);
			}
			_runningParticles = new Dictionary();
		}
		
		
		public function checkRemoveParticles():void {
			for each(var eGroup:Object in _runningParticles) {
				var group:EffectGroup = eGroup.particleEffect;
				var factory:EffectGroupFactoryS = eGroup.factory;
				if (group.time >= factory.effectDuration) {
					if(group.onComplete != null)group.onComplete();
					group.parent.removeChild(group);
					delete _runningParticles[group];
					eGroup = null;
				}
			}
		}		
		
		public function getDangerParticles(position:Vector3D):void {
			if (position == null)
				position = new Vector3D();
				
			var effect:EffectGroup = _dangerFactory.createNeedStuff() as EffectGroup;
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}
		
		public function getBeamParticles(target:Mesh):void {
			var effect:EffectGroup = _randomRayFactory.createNeedStuff() as EffectGroup;
			_runningParticles[effect] = {particleEffect:effect, factory:_randomRayFactory};
			target.addChild(effect);
			effect.start();
		}
		public function getRandomRayParticles(position:Vector3D, target:Vector3D):void {
			if (position == null)
				position = new Vector3D();
				
			var effect:EffectGroup = _randomRayFactory.createNeedStuff() as EffectGroup;
			_runningParticles[effect] = {particleEffect:effect, factory:_randomRayFactory};
			effect.position = position;
			effect.lookAt(target);
			_scene.addChild(effect);
			effect.start();
		}
		
		public function getDeathParticles(position:Vector3D):void {
			if (position == null)
				position = new Vector3D();
				
			var effect:EffectGroup = _deathFactory.createNeedStuff() as EffectGroup;
			_runningParticles[effect] = {particleEffect:effect, factory:_deathFactory};
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}
		
		public function getExplosionParticles(position:Vector3D):void {
			if (position == null)
				position = new Vector3D();
				
			var effect:EffectGroup = _explosionFactory.createNeedStuff() as EffectGroup;
			_runningParticles[effect] = {particleEffect:effect, factory:_explosionFactory};
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}
		
		public function getSparksParticles(position:Vector3D, completeCallback:Function = null):void {
			if (position == null)
				position = new Vector3D();

			var effect:EffectGroup = _collisionFactory.createNeedStuff() as EffectGroup;
			effect.onComplete = completeCallback;
			_runningParticles[effect] = {particleEffect:effect, factory:_collisionFactory};
			effect.position = position;
			_scene.addChild(effect);
			effect.start();
		}	
		
		public function getShieldParticles(target:Mesh):void {
			var effect:EffectGroup = _shieldFactory.createNeedStuff() as EffectGroup;
			_runningParticles[effect] = {particleEffect:effect, factory:_shieldFactory};
			target.addChild(effect);
			effect.start();
		}		
	}

}