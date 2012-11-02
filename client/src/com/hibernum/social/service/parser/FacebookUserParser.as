package com.hibernum.social.service.parser {
import com.pranks.social.model.AppRequestUserVO;
import com.pranks.social.model.AppRequestVO;
import com.pranks.social.model.SocialUser;
import com.pranks.social.service.FacebookService;

public class FacebookUserParser extends SocialUserParser {
	public function FacebookUserParser() {
		super();
	}

	override protected function parseObject(pObject:Object, pSocialUser:SocialUser):void {
		super.parseObject(pObject, pSocialUser);
		pSocialUser.isAppUser = pObject.installed;
		if(pObject.apprequests) {
			var v:Vector.<AppRequestVO> = new Vector.<AppRequestVO>;
			for each(var request:Object in pObject.apprequests.data) {
				var appRequest:AppRequestVO = parseAppRequest(request);
				v.push(appRequest);
			}
			pSocialUser.appRequests = v;
		}
	}

	private function parseAppRequest(object:Object):AppRequestVO {
		var vo:AppRequestVO = new AppRequestVO(object.id);
		vo.message = object.message;
		vo.createdTime = object.created_time;
		vo.userFrom = new AppRequestUserVO(object.from.id, object.from.name);
		vo.userTo = new AppRequestUserVO(object.to.id, object.to.name);
		vo.imgFrom = FacebookService.getImageUrl(vo.userFrom.id);
		if(object.data) {
			vo.transactionId = object.data;
		}
		return vo;
	}
}
}
