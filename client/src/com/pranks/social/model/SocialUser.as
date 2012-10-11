package com.pranks.social.model {
import flash.display.Bitmap;

public class SocialUser {
	public var token:Token;
	public var first_name:String;
	public var last_name:String;
	public var gender:String;
	public var timezone:int;
	public var locale:String;
	public var link:String;
	public var name:String;
	public var social_id:String;
	public var pictureUrl:String;
	public var birthday:String;
	public var picture:Bitmap;
	public var isAppUser:Boolean = false;
	public var appRequests:Vector.<AppRequestVO> = new Vector.<AppRequestVO>;

	public function SocialUser() {
	}
}
}
