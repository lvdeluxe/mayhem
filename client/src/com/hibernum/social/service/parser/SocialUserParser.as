package com.hibernum.social.service.parser {
import com.hibernum.social.model.SocialUser;

import flash.utils.Dictionary;

public class SocialUserParser {
	public function SocialUserParser() {
	}

	public function parse(result:Object):Array {
		var a:Array = new Array();
		for each (var object:Object in result) {
			var socialUser:SocialUser = new SocialUser();
			parseObject(object, socialUser);
			a[a.length] = socialUser;
		}
		return a;
	}

	protected function parseObject(pObject:Object, pSocialUser:SocialUser):void {
		pSocialUser.social_id = pObject.id;
		pSocialUser.first_name = pObject.first_name;
		pSocialUser.last_name = pObject.last_name;
		pSocialUser.name = pObject.name;
		pSocialUser.pictureUrl = pObject.picture;
	}

	protected function getId(pObject:Object):String {
		var r:String;
		var fields:Array = ['id', 'uid'];
		for each (var field:String in fields) {
			if(pObject.hasOwnProperty(field)) {
				r = pObject[field];
				break;
			}
		}
		return r;
	}

	public function get definitions():Dictionary {
		return null;
	}
}
}
