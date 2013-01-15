package com.hibernum.social.model 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import com.hibernum.social.service.FacebookService;
	import flash.display.Stage;
	import playerio.Client;
	import playerio.PlayerIO;
	 
	public class SocialModel 
	{
		
		private var _token:Token;
		public var mainUser:SocialUser;
		private var _callbackUserLoggedIn:Function;		
		
		private var letters:String = "abcdefghijklmnopqrstuvwxyz"
		
		
		public function SocialModel(onUserLogged:Function, standalone:Boolean) 
		{
			if (standalone) {
				var socialUser:SocialUser = new SocialUser();
				socialUser.social_id = Math.round(Math.random() * 10000).toString();
				socialUser.name = getRandomName();
				onUserLogged(socialUser);
			}else{
				_callbackUserLoggedIn = onUserLogged;
				FacebookService.initialize();
				FacebookService.init("483222041718845", "cmayhem", onSuccess, onFailure);
			}
		}
		
		
		
		private function getRandomName():String {
			var str:String = "";
			var split:Array = letters.split("");
			for (var i:uint = 0 ; i < 10 ; i++ )
				str += split[Math.floor(Math.random() * split.length)];
			return str;
		}
		
		private function onFailure(o:Object):void {
			trace("failure",o)
		}
		
		private function onSuccess(response:Object):void {
			var expireDate:Date = new Date();
			expireDate.setTime(expireDate.time + Number(response.expireDate) * 1000);
			_token = new Token(response.accessToken, expireDate);
			FacebookService.getOwnerInfo({ fields:'first_name,last_name,gender,timezone,locale,link,name,id,picture,apprequests'},onGetOwnerInfos);
		}
		
		private function onGetOwnerInfos(userVo:SocialUser):void {
			userVo.token = _token;
			mainUser = userVo;
			_callbackUserLoggedIn(mainUser);	
		}
		
	}

}