package com.hibernum.social.service {
import com.pranks.social.model.SocialPayment;
import com.pranks.social.model.SocialPost;
import com.pranks.social.model.SocialRequest;
import com.pranks.social.model.SocialUser;
import com.pranks.social.model.Token;
import com.pranks.social.service.parser.FacebookUserParser;

import flash.utils.Dictionary;
import flash.external.ExternalInterface;

public class FacebookService {
	private static const GRAPH_URL:String = 'https://graph.facebook.com';
	private static const SUCCESS:uint = 0;
	private static const FAILURE:uint = 1;
	private static var _socialUserParser:FacebookUserParser;
	private static var _currentCallbacks:Dictionary;
	private static var _screenshotFunction:Function;
	private static var _userToken:Token;

	//TODO document all methods with the page url of the FB API related to this method

	public static function initialize():void {
		_socialUserParser = new FacebookUserParser();
		_currentCallbacks = new Dictionary();
		addCallback('onInit', onInit);
		addCallback('onGetOwnerInfos', onGetOwnerInfos);
		addCallback('onGetOwnerFriends', onGetOwnerFriends);
		addCallback('onDeleteAppRequest', onDeleteAppRequest);
		addCallback('onRequest', onRequest);
		addCallback('onStreamPublish', onStreamPublish);
		addCallback('onPublish', onPublish);
		addCallback('onMakePayment', onMakePayment);
		ExternalInterface.addCallback('exportScreenshot', exportScreenshot);
		ExternalInterface.addCallback('onFailure', onFailure);
		ExternalInterface.addCallback('onJavaScriptError', onJavaScriptError);
		trace("ExternalInterface.objectID",ExternalInterface.objectID)
		ExternalInterface.call('FBBridge.setGameElement', ExternalInterface.objectID);
	}

	public static function init(pAppId:String, pAppName:String, success:Function, failure:Function = null):void {
		registerCallback('onInit', success, failure);
		ExternalInterface.call('FBBridge.init', pAppId, pAppName, true);
	}

	private static function onInit(authResponse:Object):void {
		_userToken = getToken(authResponse.accessToken, authResponse.expireDate);
		unregisterCallback('onInit', SUCCESS)(_userToken);
	}

	public static function getOwnerInfo(fieldsObject:Object, success:Function, failure:Function = null):void {
		registerCallback('onGetOwnerInfos', success, failure);
		ExternalInterface.call('FBBridge.getOwnerInfos', fieldsObject);
	}

	private static function onGetOwnerInfos(result:Object):void {
		var user:SocialUser = _socialUserParser.parse({data:result})[0];
		unregisterCallback('onGetOwnerInfos', SUCCESS)(user);
	}

	public static function getOwnerFriends(fieldsObject:Object, limit:Number, success:Function, failure:Function = null):void {
		registerCallback('onGetOwnerFriends', success, failure);
		ExternalInterface.call('FBBridge.getOwnerFriends', fieldsObject, limit.toString());
	}

	private static function onGetOwnerFriends(result:Object):void {
		unregisterCallback('onGetOwnerFriends', SUCCESS)(_socialUserParser.parse(result.data));
	}

	public static function deleteAppRequest(requestId:String, success:Function, failure:Function = null):void {
		registerCallback('onDeleteAppRequest', success, failure);
		ExternalInterface.call('FBBridge.removeRequest', requestId);
	}

	private static function onDeleteAppRequest(result:Object):void {
		unregisterCallback('onDeleteAppRequest', SUCCESS)(result);
	}

	public static function request(pRequest:SocialRequest, success:Function, failure:Function = null):void {
		registerCallback('onRequest', success, failure);
		ExternalInterface.call('FBBridge.sendRequest', pRequest);
	}

	private static function onRequest(result:Object):void {
		unregisterCallback('onRequest', SUCCESS)(result);
	}

	public static function streamPublish(o:Object, success:Function, failure:Function = null):void {
		// see http://developers.facebook.com/docs/fbjs/streamPublish/
		registerCallback('onStreamPublish', success, failure);
		ExternalInterface.call('FBBridge.streamPublish', o);
	}

	private static function onStreamPublish(result:Object):void {
		unregisterCallback('onStreamPublish', SUCCESS)(result);
	}

	public static function makePayment(payment:SocialPayment, success:Function, failure:Function = null):void {
		registerCallback('onMakePayment', success, failure);
		ExternalInterface.call('FBBridge.makePayment', payment);
	}

	private static function onMakePayment(response:Object):void {
		unregisterCallback('onMakePayment', SUCCESS)(response);
	}

	public static function publish(o:SocialPost, success:Function, failure:Function = null):void {
		registerCallback('onPublish', success, failure);
		ExternalInterface.call('FBBridge.publish', o.toObject());
	}

	private static function onPublish(result:Object):void {
		unregisterCallback('onPublish', SUCCESS)(result);
	}

	public static function set screenshotFunction(f:Function):void {
		_screenshotFunction = f;
	}

	public static function exportScreenshot():String {
		if(_screenshotFunction != null) {
			return _screenshotFunction();
		}
		else {
			return '';
		}
	}

	public static function getToken(accessToken:String, expireIn:String):Token {
		var expireDate:Date = new Date();
		expireDate.setTime(expireDate.time + Number(expireIn) * 1000);
		return new Token(accessToken, expireDate);
	}

	public static function getImageUrl(id:String, type:String = null):String {
		return GRAPH_URL + '/' + id + '/picture' + (type != null ? '?type=' + type : '');
	}

	private static function addCallback(name:String, method:Function):void {
		ExternalInterface.addCallback(name, method);
		_currentCallbacks[name] = []
	}

	private static function onFailure(name:String, error:Object):void {
		var errorCallback:Function = unregisterCallback(name, FAILURE);
		if(errorCallback != null) {
			errorCallback(error);
		} else {
			trace("FacebookService: unhandled error " + error);
		}
	}

	private static function onJavaScriptError(error:*):void {
		throw Error(error);
	}

	public static function registerCallback(name:String, success:Function, failure:Function):void {
		_currentCallbacks[name].push([ success, failure ]);
	}

	public static function unregisterCallback(name:String, successOrFailure:uint):Function {
		if(!_currentCallbacks[name])
			throw new Error("FacebookService: Invalid callback name: " + name);
		if(_currentCallbacks[name].length == 0)
			throw new Error("FacebookService: unregistering empty callbacks for " + name);
		return _currentCallbacks[name].shift()[successOrFailure];
	}
}
}
