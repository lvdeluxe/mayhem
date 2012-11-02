package com.hibernum.social.model {
public class Token {
	public var accessToken:String;
	public var expireDate:Date;

	public function Token(pAccessToken:String = '', pExpireDate:Date = null) {
		accessToken = pAccessToken;
		expireDate = pExpireDate;
	}

	public function toString():String {
		return '[Token ' + accessToken + ', expires ' + expireDate + ']';
	}
}
}
