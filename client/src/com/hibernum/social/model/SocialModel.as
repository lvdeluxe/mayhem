package com.hibernum.social.model 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import com.hibernum.social.controller.SocialImageLoader;
	import com.hibernum.social.service.FacebookService;
	import com.mayhem.game.ModelsManager;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.SocialSignals;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import playerio.Client;
	import playerio.PlayerIO;
	 
	public class SocialModel 
	{
		
		private var _token:Token;
		public var mainUser:SocialUser;
		private var _callbackUserLoggedIn:Function;		
		
		private var letters:String = "abcdefghijklmnopqrstuvwxyz"
		
		private var _isSocial:Boolean = true;
		private var _allUsers:Dictionary = new Dictionary();
		private var _allFriends:Array;
		
		
		public function SocialModel(onUserLogged:Function, standalone:Boolean) 
		{
			GameSignals.GET_USER_INFO_PLANE.add(getUserImage);
			SocialSignals.IMAGE_LOADED.add(createUserInfoBitmapData);
			SocialSignals.GET_LEADERBOARD_FRIENDS.add(getLeaderboardFriends);
			_isSocial = !standalone;
			if (standalone) {
				var socialUser:SocialUser = new SocialUser();
				//socialUser.social_id = "1234";
				socialUser.social_id = Math.round(Math.random() * 10000).toString();
				socialUser.name = getRandomName();
				onUserLogged(socialUser);
				_allUsers[socialUser.social_id] = socialUser;
			}else{
				_callbackUserLoggedIn = onUserLogged;
				FacebookService.initialize();
				FacebookService.init("483222041718845", "cmayhem", onSuccess, onFailure);
			}
		}
		
		private function getLeaderboardFriends(cb:Function):void {
			var friendUsers:Array = [];
			if(_isSocial){
				for (var i:uint = 0 ; i < _allFriends.length ; i++ ) {
					var sUser:SocialUser = _allFriends[i];
					if (sUser.isAppUser) {
						friendUsers.push(sUser);
					}
				}
			}
			cb(friendUsers);
		}
		
		private function getUserImage(userId:String):void 
		{
			var socialId:String = userId.split("_")[1];
			if (userId.split("_")[0] == "ai") {
				createUserInfoBitmapData(userId,new ModelsManager.instance.skullFace());
			}else{
				if (_isSocial) {
					if (_allUsers[socialId] != null) {
						//main user
						getImageAfterUserLoaded(_allUsers[socialId]);
					}else{
						FacebookService.getSocialUserInfo( { id:socialId }, getImageAfterUserLoaded, onFailure);
					}
				}else {
					var userVo:SocialUser;
					if (_allUsers[socialId] != null) {
						userVo = _allUsers[socialId]
						
					}else {
						userVo = new SocialUser();
						userVo.name = getRandomName();
						userVo.social_id = userId.split("_")[1];
					}
					getImageAfterUserLoaded(userVo);
				}
			}
		}
		
		private function getImageAfterUserLoaded(user:SocialUser):void {
			_allUsers[user.social_id] = user;
			if (_isSocial) {
				var imgLoader:SocialImageLoader = new SocialImageLoader("user_" + user.social_id, function(userId:String,img:Bitmap):void {
					SocialSignals.IMAGE_LOADED.dispatch(userId,img);
				});
				
			}else {
				createUserInfoBitmapData("user_"+user.social_id,new Bitmap(new BitmapData(50, 50, false, 0xcc0000)));
			}
		}
		
		private function createUserInfoBitmapData(userId:String,bmp:Bitmap):void {
			var tf:TextField = new TextField();
			tf.width = 128;
			var tff:TextFormat = new TextFormat("Verdana", 14, 0x000000);
			tff.align = 'center';
			var socialId:String = userId.split("_")[1];
			var user:SocialUser = _allUsers[socialId];
			if (user != null) {
				tf.text = user.name
			}else {
				tf.text = "CPU " + socialId;
				tff.size = 24;
			}
			tf.setTextFormat(tff);
			tf.y = 50
			var sp:Sprite = new Sprite();
			bmp.x = 39
			//bmp.y = 18;
			sp.addChild(bmp);
			sp.addChild(tf);
			var bmpData:BitmapData = new BitmapData(128, 128,true,0x00000000);
			bmpData.draw(sp);
			GameSignals.SET_USER_INFO_PLANE.dispatch(userId,bmpData);
		}
		
		
		private function getRandomName():String {
			var str:String = "";
			var split:Array = letters.split("");
			for (var i:uint = 0 ; i < 4 ; i++ )
				str += split[Math.floor(Math.random() * split.length)];
			return "dummy_"+str;
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
			_allUsers[userVo.social_id] = userVo;
			FacebookService.getOwnerFriends({fields:"first_name,last_name,name,installed", limit:1000},onFriendsSuccess, onFailure);
			
		}
		
		private function onFriendsSuccess(response:Object):void {
			_allFriends = response as Array;
			_callbackUserLoggedIn(mainUser);	
		}
		
	}

}