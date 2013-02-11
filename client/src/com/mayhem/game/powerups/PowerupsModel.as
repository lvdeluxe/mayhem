package com.mayhem.game.powerups 
{
	/**
	 * ...
	 * @author availlant
	 */
	public class PowerupsModel 
	{
		public var allPowerups:Vector.<PowerupDefinition>;
		[Embed(source = "/assets/data/powerups.json", mimeType = "application/octet-stream")]
		private var Powerups:Class;
		
		public function PowerupsModel() 
		{
			//var allPups:Object = JSON.parse(new Powerups());
			//allPowerups = new Vector.<PowerupDefinition>();
			//for each(var pup:Object in allPups.powerups) {
				//allPowerups.push(new PowerupDefinition(pup));
			//}
			//allPowerups.sort(sort);
		}
		
		
	}

}