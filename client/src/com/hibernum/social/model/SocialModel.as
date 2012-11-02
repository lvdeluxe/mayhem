package com.hibernum.social.model 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import com.pranks.social.service.FacebookService;
	 
	public class SocialModel 
	{
		
		private var _token:Token;
		public var mainUser:SocialUser;
		private var _callbackUserLoggedIn:Function;
		
		public function SocialModel(onUserLogged:Function) 
		{
			_callbackUserLoggedIn = onUserLogged;
			FacebookService.initialize();
			FacebookService.init("121997937950672", "officemayhem", onSuccess, onFailure);
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