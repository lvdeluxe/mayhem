var FBBridge = {

	gameElement: null,
	imageElement: null,
	screenshotElement: null,

	setGameElement:function(objectId) {
		FBBridge.gameElement = document.getElementById('game');
	},

	onInit:function (response) {
		console.log(response)
		console.log(FBBridge.gameElement)
		if(response.status == 'connected') {
			FBBridge.gameElement.onInit(response.authResponse);
		}
		FB.Event.unsubscribe('auth.statusChange', FBBridge.onInit);
	},
	init:function(app_id, app_name, fric_less_req) {
		FB.Event.subscribe('auth.statusChange', FBBridge.onInit);
		console.log("called init")
		try {
			FB.init({
				appId:app_id,
				status : false,
				hideFlashCallback : FBBridge.onFlashHide,
				frictionlessRequests:fric_less_req
			});
			FB.getLoginStatus(function(response) {
				console.log(response.status)
				if (response.status == 'not_authorized' ||response.status == 'unknown') {
					var params = location.search.substring(1);
					//console.log('//graph.facebook.com/oauth/authorize?client_id=' + app_id + '&redirect_uri=' + encodeURIComponent(location.protocol + '//apps.facebook.com/' + app_name + '/?' + params));
					 //warning: be sure to end redirect_uri with a slash or you'll get a weird error from facebook
					top.location = '//graph.facebook.com/oauth/authorize?client_id=' + app_id + '&redirect_uri=' + encodeURIComponent(location.protocol + '//apps.facebook.com/' + app_name + '/?' + params);
					
				}
			});
		}
		catch(error) {
			console.log("error init")
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	makePayment:function(order_info) {
		var obj = {
			method:'pay',
			action:'buy_item',
			order_info:order_info,
			dev_purchase_params:{'oscif':true}
		};
		try {
			FBBridge.displayFlashScreenshot();
			FB.ui(obj, function(response) {
				FBBridge.hideFlashScreenshot();
				if(response.order_id) {
					FBBridge.gameElement.onMakePayment(response);
				} else if(response.error_code) {
					FBBridge.gameElement.onFailure('onMakePayment', response.error);
				}
				else {
					FBBridge.gameElement.onFailure('onMakePayment', response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	getOwnerInfos:function(params) {
		try {
			FB.api('/me', params, function(response) {
				if(!response || response.error) {
					FBBridge.gameElement.onFailure('onGetOwnerInfos', response.error);
				}
				else {
					FBBridge.gameElement.onGetOwnerInfos(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	getOwnerFriends:function(params, limit) {
		try {
			FB.api('me/friends&limit=' + limit, params, function(response) {
				if(!response || response.error) {
					FBBridge.gameElement.onFailure('onGetOwnerFriends', response.error);
				}
				else {
					FBBridge.gameElement.onGetOwnerFriends(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	removeRequest:function(postId) {
		try {
			FB.api(postId, 'delete', function(response) {
				if(!response || response.error) {
					FBBridge.gameElement.onFailure('onRemoveRequest', response.error);
				}
				else {
					FBBridge.gameElement.onDeleteAppRequest(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	sendRequest:function(request) {
		try {
			FBBridge.displayFlashScreenshot();
			request.method = 'apprequests';
			FB.ui(request, function (response) {
				FBBridge.hideFlashScreenshot();
				if(!response) {
					FBBridge.gameElement.onRequest(null);
				} else if(response.error) {
					FBBridge.gameElement.onFailure('onSendRequest', response.error);
				}
				else {
					FBBridge.gameElement.onRequest(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	streamPublish:function(feed) {
		try {
			FB.api('me/feed', 'post', feed, function (response) {
				if(!response || response.error) {
					FBBridge.gameElement.onFailure('onStreamPublish', response.error);
				}
				else {
					FBBridge.gameElement.onStreamPublish(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	publish:function(wallpost) {
		try {
			FBBridge.displayFlashScreenshot();
			wallpost.method = 'feed';
			FB.ui(wallpost, function (response) {
				FBBridge.hideFlashScreenshot();
				if(!response) {
					FBBridge.gameElement.onPublish(null);
				} else if(response.error) {
					FBBridge.gameElement.onFailure('onPublish', response.error);
				}
				else {
					FBBridge.gameElement.onPublish(response);
				}
			});
		}
		catch(error) {
			FBBridge.gameElement.onJavaScriptError(error);
		}
	},
	onFlashHide:function(info) {
		if(info.state == 'opened') {
			FBBridge.displayFlashScreenshot();
		}
		else {
			FBBridge.hideFlashScreenshot();
		}
	},
	displayFlashScreenshot:function() {
		var screenshotData = FBBridge.gameElement.exportScreenshot();
		FBBridge.screenshotElement.src = 'data:image/jpeg;base64,' + screenshotData;
		FBBridge.screenshotElement.width = FBBridge.gameElement.width;
		FBBridge.screenshotElement.height = FBBridge.gameElement.height;
		FBBridge.gameElement.style.top = '-10000px';
		FBBridge.imageElement.style.top = '';
	},

	hideFlashScreenshot:function() {
		FBBridge.gameElement.style.top = '';
		FBBridge.imageElement.style.top = '-10000px';
	}
};
