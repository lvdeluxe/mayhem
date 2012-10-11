/**
 * Created by IntelliJ IDEA.
 * User: lvdeluxe
 * Date: 12-02-02
 * Time: 16:12
 * To change this template use File | Settings | File Templates.
 */
package com.pranks.social.model {
public class AppRequestUserVO {
	public var _name:String;
	public var _id:String;

	public function AppRequestUserVO(pId:String, pName:String) {
		_name = pName;
		_id = pId;
	}

	public function get name():String {
		return _name;
	}

	public function get id():String {
		return _id;
	}
}
}
