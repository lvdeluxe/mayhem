package com.hibernum.social.model {
public class SocialRequest implements ISocialMessage {
	public var id:String;
	public var name:String;
	public var message:String;
	public var title:String;
	public var data:String;
	public var to:String;
	public var filters:Array;
	public var method:Object;

	public function SocialRequest() {
	}

	public function toObject():Object {
		return {id:id, name:name, message:message, title:title, data:data, filters:filters};
	}
}
}
