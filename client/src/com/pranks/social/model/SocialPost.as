package com.pranks.social.model {
public class SocialPost implements ISocialMessage {
	public var id:String;
	public var name:String;
	public var picture:String;
	public var caption:String;
	public var description:String;
	public var link:String;
	public var actions:Object;

	public function SocialPost() {
	}

	public function toObject():Object {
		return {id:id, name:name, picture:picture, caption:caption, description:description, link:link, actions:actions};
	}
}
}
