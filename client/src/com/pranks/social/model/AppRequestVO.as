/**
 * Created by IntelliJ IDEA.
 * User: lvdeluxe
 * Date: 12-02-02
 * Time: 16:09
 * To change this template use File | Settings | File Templates.
 */
package com.pranks.social.model {
public class AppRequestVO {
	private var _id:String;
	private var _message:String;
	private var _imgFrom:String;
	private var _createdTime:String;
	private var _userFrom:AppRequestUserVO;
	private var _userTo:AppRequestUserVO;
	private var _transactionId:String;

	public function AppRequestVO(pId:String) {
		_id = pId;
	}

	[Bindable]
	public function get message():String {
		return _message;
	}

	public function set message(value:String):void {
		_message = value;
	}

	public function get createdTime():String {
		return _createdTime;
	}

	public function set createdTime(value:String):void {
		_createdTime = value;
	}

	[Bindable]
	public function get userFrom():AppRequestUserVO {
		return _userFrom;
	}

	public function set userFrom(value:AppRequestUserVO):void {
		_userFrom = value;
	}

	public function get userTo():AppRequestUserVO {
		return _userTo;
	}

	public function set userTo(value:AppRequestUserVO):void {
		_userTo = value;
	}

	[Bindable]
	public function get imgFrom():String {
		return _imgFrom;
	}

	public function set imgFrom(value:String):void {
		_imgFrom = value;
	}

	public function get transactionId():String {
		return _transactionId;
	}

	public function set transactionId(value:String):void {
		_transactionId = value;
	}

	public function get id():String {
		return _id;
	}
}
}
