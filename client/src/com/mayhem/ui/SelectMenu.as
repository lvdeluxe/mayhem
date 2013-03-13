package com.mayhem.ui 
{
	import com.hibernum.social.controller.SocialImageLoader;
	import com.hibernum.social.model.SocialRequest;
	import com.hibernum.social.model.SocialUser;
	import com.hibernum.social.service.FacebookService;
	import com.mayhem.game.GameData;
	import com.mayhem.game.GameStats;
	import com.mayhem.game.ModelsManager;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.game.powerups.PowerupSlot;
	import com.mayhem.multiplayer.CoinsPackage;
	import com.mayhem.multiplayer.GameUserVO;
	import com.mayhem.signals.GameSignals;
	import com.mayhem.signals.MultiplayerSignals;
	import com.mayhem.signals.SocialSignals;
	import com.mayhem.signals.UISignals;
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Radio;
	import feathers.controls.Screen;
	import feathers.controls.ToggleSwitch;
	import feathers.core.PopUpManager;
	import feathers.core.ToggleGroup;
	import feathers.data.ListCollection;
	import feathers.text.BitmapFontTextFormat;
	import feathers.themes.AzureMobileTheme;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextFormatAlign;
	import flash.utils.setTimeout;
	import playerio.VaultItem;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	//import flash.events.Event;
	/**
	 * ...
	 * @author availlant
	 */
	public class SelectMenu extends Screen
	{
		
		private var _startButton:Button;
		private var _prevButton:Button;
		private var _nextButton:Button;
		private var _vehicleId:uint;
		private var _textureId:uint;
		private var _colorSelector:ButtonGroup;
		private var _powerupsSelector:ButtonGroup;
		private var _powerupDefs:Vector.<PowerupDefinition>;
		private var _coinsPackages:Vector.<CoinsPackage>;
		private var _powerupSlots:Vector.<PowerupSlot>
		private var _callout:Callout;
		private var _user:GameUserVO;
		private var _infoBtn:Button;
		private var _infoContainer:Sprite;
		private var _closeBtn:Button;
		private var _howToPlay:Label
		private var _credits:Label
		private var _leaderboardDataContainer:Sprite = new Sprite();
		private var _leaderboardContainer:Sprite = new Sprite();
		private var _unlockSlotContainer:Sprite = new Sprite();
		private var _purchasePowerupContainer:Sprite = new Sprite();
		private var _purchaseMoreCoinsContainer:Sprite = new Sprite();
		private var _inviteFriendsBtn:Button;
		private var _closeLeaderboardDataBtn:Button;
		private var _closeLeaderboardBtn:Button;
		private var _closeUnlockSlotBtn:Button;
		private var _closePurchaseCoinsBtn:Button;
		private var _closePurchaseBtn:Button;
		private var _purchaseCreditsBtn:Button;
		private var _unlockSlotBtn:Button;
		private var _leaderboardBtn:Button;
		private var _btnContainer:Sprite;
		private var _theme:AzureMobileTheme;
		private var _numFreeSlots:uint;
		
		private var _leaderboardGroup:ToggleGroup;
		
		private var _maxLeaderboardPics:uint = 0;
		private var _incLeaderboardPics:uint = 0;
		private var _leaderboardList:List;
		
		private var _selectedPowerups:Array = [];
		
		private var _currentLeaderboardSelected:uint = 0;
		
		private var _leaderboardUsers:Vector.<Object> = new Vector.<Object>();
		private var _leaderboardFriends:Vector.<Object> = new Vector.<Object>();
		private var _currentleaderboardUsers:Vector.<Object> = new Vector.<Object>();
		
		private static const CUSTOM_BUTTON_NAME:String = "customName";
		
		private var howToPlayString:String = "\nBumper Mayhem is a realtime multiplayer 3D game in which you control a vehicle in a 12-player arena,\nto try and destroy all your opponents.\nThe more hits you make, the more XP and Coins you get, which will allow you to unlock new Power-Ups!\nEvery time you get destroyed,\nyou respawn but you lose some precious seconds...\nEach session last 3:00 minutes, but you can play as many sessions as you want.\n\nYou control the vehicle with the W / A / S / D or ARROW keys,\nand unleash you power-ups with the 1 / 2 / 3 / 4 / 5 keys.\nYou need to fill up your power-up before using them, by staying on the the item located on top of the bridge.\n\nHAVE FUN!"
		
		
		public function SelectMenu(user:GameUserVO, powerupDefs:Vector.<PowerupDefinition>, coinPacks:Vector.<CoinsPackage>, slots:Vector.<PowerupSlot>, theme:AzureMobileTheme) 
		{
			_theme = theme;
			_theme.setInitializerForClass( Button, customButtonInitializer, CUSTOM_BUTTON_NAME );
			_user = user;
			_numFreeSlots = user.powerupSlots;
			_textureId = user.textureId;
			_vehicleId = user.vehicleId;
			_powerupDefs = powerupDefs;
			_coinsPackages = coinPacks;
			_powerupSlots = slots;
			_startButton = new Button();
			_startButton.label = "Start";
			_startButton.width = 200;
			_startButton.addEventListener(Event.TRIGGERED, startGame);			
			PopUpManager.overlayFactory = getPopupModal;
			addChild(_startButton);
			setTextureSelector();
			setPowerUpsSelector();
			setVehicleButtons();	
			setInfoPopupContent();
			setInfosButton();
			
			UISignals.POWERUP_SLOT_CLICKED.add(onSlotSelected);
			MultiplayerSignals.POWERUP_UNLOCKED.add(onPowerupUnlocked);
			MultiplayerSignals.SLOT_UNLOCKED.add(onSlotUnlocked);
			MultiplayerSignals.GET_LEADERBOARD.dispatch(onGetLeaderboard);
			
			for (var i:uint = 0 ; i < _user.powerupSlots ; i++ ) {
				_selectedPowerups.push("");
			}
			
			var logo:Image = new Image(Texture.fromBitmap(new TexturesManager.Logo()));
			logo.x = (Starling.current.nativeStage.stageWidth - logo.width) / 2;
			addChild(logo);
		}
		
		private function onClickItemLeaderboard(event:Event):void {
			var list:List = List( event.currentTarget );
			_currentLeaderboardSelected = list.selectedIndex;
			MultiplayerSignals.GET_LEADERBOARD_DATA.dispatch(_currentleaderboardUsers[_currentLeaderboardSelected].user_id, showLeaderboardDataPopup);
		}
		
		private function showLeaderboardDataPopup(stats:GameStats):void {
			var user:Object;
			for (var i:uint = 0 ; i < _currentleaderboardUsers.length ; i++ ) {
				if (_currentleaderboardUsers[i].user_id == stats.uid) {
					user = _currentleaderboardUsers[i];
				}
			}
			
			_leaderboardDataContainer = new Sprite();
			var btn:Button = new Button();
			btn.width = 500;
			btn.height = 300;
			btn.touchable = false;			
			
			var leaderboardDataTitle:Label = new Label();
			leaderboardDataTitle.width = 500;
			leaderboardDataTitle.height = 24;
			leaderboardDataTitle.y = 20
			leaderboardDataTitle.text = user.name;
			
			var img:Image = new Image(user.pic);
			img.x = 10;
			img.y = 10;
			
			_closeLeaderboardDataBtn = new Button();
			_closeLeaderboardDataBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closeLeaderboardDataBtn.width = 30;
			_closeLeaderboardDataBtn.height = 30;
			_closeLeaderboardDataBtn.x = 465;
			_closeLeaderboardDataBtn.y = 5;
			_closeLeaderboardDataBtn.addEventListener(Event.TRIGGERED, onCloseLeaderboardData);
			
			var dataLabel:Label  = new Label();
			dataLabel.textRendererProperties.wordWrap = true;
			dataLabel.width = 400;
			dataLabel.height = 200;
			dataLabel.x = 50;
			dataLabel.y = 75;
			dataLabel.text =  "has played " +stats.alltime_sessions_played.toString() + " sessions.\n"+
			"has hit " + stats.alltime_num_hits_inflicted.toString() + " enemies.\n" +
			"has been hit " + stats.alltime_num_hits_received.toString() + " times.\n"+			
			"has destroyed " + stats.alltime_num_kills_inflicted.toString() + " enemies.\n" +
			"has been destroyed " + stats.alltime_num_kills_received.toString() + " times.\n" +
			"Max speed at impact was " + uint(stats.alltime_max_speed ).toString() + " km/h."
			
			
			_leaderboardDataContainer.addChild(btn);
			_leaderboardDataContainer.addChild(leaderboardDataTitle);
			_leaderboardDataContainer.addChild(dataLabel);			
			_leaderboardDataContainer.addChild(img);		
			_leaderboardDataContainer.addChild(_closeLeaderboardDataBtn);
			
			PopUpManager.addPopUp(_leaderboardDataContainer);
		}
		
		private function onCloseLeaderboardData(event:Event):void {
			PopUpManager.removePopUp(_leaderboardDataContainer);
			_leaderboardList.selectedItem.isSelected = false;
		}
		
		private function onGetLeaderboard(leaderboardUsers:Vector.<GameUserVO>):void {
			var pic:Texture = Texture.fromBitmap(new ModelsManager.instance.leaderboardDummy());
			for (var i:uint = 0 ; i < leaderboardUsers.length ; i++ ) {
				var user:Object = { };
				user.user_id = leaderboardUsers[i].uid;
				user.name = leaderboardUsers[i].name;
				user.label = leaderboardUsers[i].name + " / Level "+(GameData.getLevelForXP(leaderboardUsers[i].xp) + 1).toString();
				
				if (leaderboardUsers[i].name.split("_")[0] != "dummy") {
					_maxLeaderboardPics ++;
					var imgLoader:SocialImageLoader = new SocialImageLoader(leaderboardUsers[i].uid, setLeaderboardUserPicture);
				}else {
					user.pic = pic;
				}
				_leaderboardUsers.push(user);
			}
			
		}
		
		private function setLeaderboardUserPicture(userId:String, img:Bitmap):void
		{
			for (var i:uint = 0 ; i < _leaderboardUsers.length; i++ ) {
				if (_leaderboardUsers[i].user_id == userId) {
					_leaderboardUsers[i].pic = Texture.fromBitmap(img);
				}
			}
			_incLeaderboardPics++;
			if (_incLeaderboardPics == _maxLeaderboardPics)
				SocialSignals.GET_LEADERBOARD_FRIENDS.dispatch(onGetLeaderboardFriends);
		}
		
		private function onGetLeaderboardFriends(leaderboardFriends:Array):void {
			for (var i:uint = 0 ; i < leaderboardFriends.length ; i++ ) {
				var sUser:SocialUser = leaderboardFriends[i];
				for (var j:uint = 0 ; j < _leaderboardUsers.length; j++ ) {
					if (sUser.social_id == _leaderboardUsers[j].user_id.split("_")[1]) {
						_leaderboardFriends.push(_leaderboardUsers[j]);
					}
				}				
			}
			setLeaderboardButton();
		}
		
		private function onSlotUnlocked(mainUser:GameUserVO, slot_id:String):void 
		{
			_user = mainUser;
			_numFreeSlots++;
			_selectedPowerups.push("");
		}
		
		private function removeSelectedPowerupsById(powerup_id:String):void {
			var index:uint = _selectedPowerups.indexOf(powerup_id);
			if (index != -1)
				_selectedPowerups[index] = "";
			trace(_selectedPowerups);
		}
		
		private function onSlotSelected(powerup_index:uint, isAssigned:String):void {
			if (powerup_index >= _user.powerupSlots) {
				displayUnlockSlotPopup();
			}else {
				if (isAssigned != "") {
					var btn:Button = Button(_btnContainer.getChildByName(isAssigned));
					btn.isEnabled = true;
					btn.defaultIcon.alpha = 1;
					removeSelectedPowerupsById(isAssigned);
					UISignals.REMOVE_POWERUP_FROM_SLOT.dispatch(isAssigned);
					_numFreeSlots++;
				}
			}
		}
		
		private function onCloseUnlockSlot(event:Event):void {
			_closeUnlockSlotBtn.removeEventListener(Event.TRIGGERED, onCloseUnlockSlot);
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_unlockSlotContainer);
		}
		
		private function displayUnlockSlotPopup():void {
			_unlockSlotContainer = new Sprite();
			var bg:Button = new Button();
			bg.width = 500;
			bg.height = 300;
			bg.touchable = false;			
			
			_closeUnlockSlotBtn = new Button();
			_closeUnlockSlotBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closeUnlockSlotBtn.width = 30;
			_closeUnlockSlotBtn.height = 30;
			_closeUnlockSlotBtn.x = 465;
			_closeUnlockSlotBtn.y = 5;
			_closeUnlockSlotBtn.addEventListener(Event.TRIGGERED, onCloseUnlockSlot);
			
			var unlockSlotTitle:Label = new Label();
			unlockSlotTitle.width = 500;
			unlockSlotTitle.height = 24;
			unlockSlotTitle.y = 20
			unlockSlotTitle.text = "UNLOCK POWER-UP SLOT";
			
			_unlockSlotBtn = new Button();
			_unlockSlotBtn.name = "slot_" + _user.powerupSlots.toString();
			_unlockSlotBtn.width = 200;
			_unlockSlotBtn.height = 50;
			_unlockSlotBtn.x = 150;
			_unlockSlotBtn.y = 225;
			_unlockSlotBtn.label = "Unlock Now"
			
			var unlockSlotDesc:Label = new Label();
			unlockSlotDesc.width = 400;
			unlockSlotDesc.textRendererProperties.wordWrap = true;
			unlockSlotDesc.height = 200;
			
			var currentUnlockableSlot:PowerupSlot = _powerupSlots[_user.powerupSlots];
			var currentLevel:uint = GameData.getLevelForXP(_user.xp) + 1;
			
			if (currentLevel >= currentUnlockableSlot.unlockLevel) {
				unlockSlotDesc.x = 50;
				unlockSlotDesc.y = 100;
				unlockSlotDesc.text = "Unlock a new Power-up Slot with " +  currentUnlockableSlot.unlockCoins +" coins"
				_unlockSlotBtn.addEventListener(Event.TRIGGERED, onClickUnlockSlotWithCoins);
			}else{
				unlockSlotDesc.x = 50;
				unlockSlotDesc.y = 75;
				unlockSlotDesc.text = "You can unlock a new Power-up Slot at level " + currentUnlockableSlot.unlockLevel + " with " +  currentUnlockableSlot.unlockCoins +" coins\nOR\nUnlock now with " + currentUnlockableSlot.unlockCredits +" FB Credits"
				_unlockSlotBtn.addEventListener(Event.TRIGGERED, onClickUnlockSlotWithCredits);
			}
			
			_unlockSlotContainer.addChild(bg);
			_unlockSlotContainer.addChild(unlockSlotTitle);
			_unlockSlotContainer.addChild(unlockSlotDesc);			
			_unlockSlotContainer.addChild(_unlockSlotBtn);	
			_unlockSlotContainer.addChild(_closeUnlockSlotBtn);
			
			PopUpManager.addPopUp(_unlockSlotContainer);
			UISignals.ADD_POPUP.dispatch();
		}
		
		private function onClickUnlockSlotWithCredits(e:Event):void 
		{
			var btn:Button = e.currentTarget as Button;
			_unlockSlotBtn.removeEventListener(Event.TRIGGERED, onClickUnlockSlotWithCredits);
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_unlockSlotContainer);
			var powerupSlot:PowerupSlot = _powerupSlots[uint(btn.name.split("_")[1])];
			trace(powerupSlot.unlockCredits)
			MultiplayerSignals.SLOT_CREDITS_UNLOCK.dispatch(powerupSlot.id);			
		}
		
		private function onClickUnlockSlotWithCoins(e:Event):void 
		{
			var btn:Button = e.currentTarget as Button;
			_unlockSlotBtn.removeEventListener(Event.TRIGGERED, onClickUnlockSlotWithCoins);
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_unlockSlotContainer);
			var powerupSlot:PowerupSlot = _powerupSlots[uint(btn.name.split("_")[1])];
			if (_user.igc >= powerupSlot.unlockCoins) {
				MultiplayerSignals.SLOT_UNLOCK.dispatch(powerupSlot.id);
			}else {
				displayNotEnoughIGCPopup();
			}
		}
		
		private function onPowerupUnlocked(user:GameUserVO, powerupId:String):void {
			_user = user;
			var btn:Button = Button(_btnContainer.getChildByName(powerupId));
			btn.defaultIcon = new Image(getTextureByName(btn.name));
		}
		
		private function setInfoPopupContent():void 
		{
			_infoContainer = new Sprite();
			var btn:Button = new Button();
			btn.width = 800;
			btn.height = 600;
			btn.touchable = false;			
			
			var howToPlayTitle:Label = new Label();
			howToPlayTitle.width = 800;
			howToPlayTitle.height = 24;
			howToPlayTitle.y = 20
			howToPlayTitle.text = "HOW TO PLAY?";
			
			_howToPlay = new Label();
			_howToPlay.textRendererProperties.wordWrap = true;
			_howToPlay.width = 700;
			_howToPlay.height = 280;
			_howToPlay.x = 50;
			_howToPlay.y = 54
			_howToPlay.text = howToPlayString;
			
			var creditsTitle:Label = new Label();
			creditsTitle.width = 800;
			creditsTitle.height = 24;
			creditsTitle.y = 300
			creditsTitle.text = "CREDITS";
			
			_credits = new Label();
			_credits.width = 800;
			_credits.height = 280;
			
			_credits.y = 340
			_credits.text = "DEVELOPER\nArnaud Vaillant\n\nART\nYves Paradis\nYan Verde\nMichael Renaud\n\nSPECIAL THANKS\nHibernum Creations\nLeonardo Borrero Luz\nRaphael Seul\nThomas Pradeilles"
			
			_closeBtn = new Button();
			_closeBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closeBtn.width = 30;
			_closeBtn.height = 30;
			_closeBtn.x = 765;
			_closeBtn.y = 5;
			
			_infoContainer.addChild(btn);
			_infoContainer.addChild(howToPlayTitle);
			_infoContainer.addChild(_howToPlay);			
			_infoContainer.addChild(creditsTitle);
			_infoContainer.addChild(_credits);			
			_infoContainer.addChild(_closeBtn);
		}
		
		private function showLeaderboardPopup():void {
			_leaderboardContainer = new Sprite();
			var btn:Button = new Button();
			btn.width = 800;
			btn.height = 600;
			btn.touchable = false;			
			
			var leaderboardTitle:Label = new Label();
			leaderboardTitle.width = 800;
			leaderboardTitle.height = 24;
			leaderboardTitle.y = 20
			leaderboardTitle.text = "LEADERBOARD";
			
			_closeLeaderboardBtn = new Button();
			_closeLeaderboardBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closeLeaderboardBtn.width = 30;
			_closeLeaderboardBtn.height = 30;
			_closeLeaderboardBtn.x = 765;
			_closeLeaderboardBtn.y = 5;
			_closeLeaderboardBtn.addEventListener(Event.TRIGGERED, onCloseLeaderboard);
			
			if(_leaderboardFriends.length > 0){
				_leaderboardGroup = new ToggleGroup();
	 
				var radio1:Radio = new Radio();
				radio1.label = "All Users";
				radio1.toggleGroup = _leaderboardGroup;
				radio1.isSelected = true;
				radio1.x = 230;
				radio1.y = 75;
				radio1.labelOffsetX = 10;
				 
				var radio2:Radio = new Radio();
				radio2.label = "Friends";
				radio2.toggleGroup = _leaderboardGroup;
				radio2.x = 450;
				radio2.y = 75;
				radio2.labelOffsetX = 10;
				
				_leaderboardGroup.addEventListener( Event.CHANGE, onChangeLeaderboard );
			}
			
			_leaderboardList = new List();
			_leaderboardList.width = 700;
			_leaderboardList.height = 350;
			_leaderboardList.x = 50;
			if(_leaderboardFriends.length > 0){
				_leaderboardList.y = 150;
				_leaderboardList.height = 350;
			}else {
				_leaderboardList.y = 75;
				_leaderboardList.height = 438;
			}
			_leaderboardList.addEventListener( Event.CHANGE, onClickItemLeaderboard );
			_currentleaderboardUsers = _leaderboardUsers;
			var leaderboardCollection:ListCollection = new ListCollection( _leaderboardUsers);
			
			_leaderboardList.dataProvider = leaderboardCollection;
			_leaderboardList.itemRendererProperties.labelField = "label";
			_leaderboardList.itemRendererProperties.iconSourceField = "pic";
			
			_inviteFriendsBtn = new Button();
			_inviteFriendsBtn.label = "Invite Friends";
			_inviteFriendsBtn.width = 250;
			_inviteFriendsBtn.height = 44;
			_inviteFriendsBtn.x = 275;
			_inviteFriendsBtn.y = 540;
			_inviteFriendsBtn.addEventListener(Event.TRIGGERED, onClickInvite);
			
			_leaderboardContainer.addChild(btn);
			_leaderboardContainer.addChild(leaderboardTitle);
			if(_leaderboardFriends.length > 0)_leaderboardContainer.addChild(radio1);			
			if(_leaderboardFriends.length > 0)_leaderboardContainer.addChild(radio2);			
			_leaderboardContainer.addChild(_leaderboardList);
			_leaderboardContainer.addChild(_inviteFriendsBtn);			
			_leaderboardContainer.addChild(_closeLeaderboardBtn);
			
			PopUpManager.addPopUp(_leaderboardContainer);
		}
		
		
		private function onChangeLeaderboard(event:Event):void {
			var group:ToggleGroup = ToggleGroup( event.currentTarget );
			switch(group.selectedIndex) {
				default:
				case 0:
					showLeaderboardAllUser();
					break;
				case 1:
					showLeaderboardFriends();
					break;
			}
		}
		
		private function showLeaderboardFriends():void {
			_currentleaderboardUsers = _leaderboardFriends;
			var leaderboardCollection:ListCollection = new ListCollection( _leaderboardFriends);
			_leaderboardList.dataProvider = leaderboardCollection;	
		}
		
		private function showLeaderboardAllUser():void {
			_currentleaderboardUsers = _leaderboardUsers;
			var leaderboardCollection:ListCollection = new ListCollection( _leaderboardUsers);
			_leaderboardList.dataProvider = leaderboardCollection;			
		}
		
		
		private function onClickInvite(event:Event):void {
			var req:SocialRequest = new SocialRequest();
			req.title = "Come and Play Bumper Mayhem";
			req.message = "You will have some fun!!!";
			req.filters = ['app_non_users'];
			FacebookService.request(req, onInviteSuccess, onInviteFailure);
		}
		
		private function onInviteSuccess(success:Object):void {
			trace(success);
		}		
		
		private function onInviteFailure(error:Object):void {
			trace(error);
		}
		
		private function onCloseLeaderboard(event:Event):void {
			PopUpManager.removePopUp(_leaderboardContainer);
			_leaderboardList.removeEventListener( Event.CHANGE, onClickItemLeaderboard );
			_inviteFriendsBtn.removeEventListener(Event.TRIGGERED, onClickInvite);
			if(_leaderboardGroup)_leaderboardGroup.removeEventListener( Event.CHANGE, onChangeLeaderboard );
		}
		private function onClickLeaderboard(event:Event):void {
			showLeaderboardPopup();
		}
		
		private function setLeaderboardButton():void {
			_leaderboardBtn = new Button();
			_leaderboardBtn.defaultIcon = new Image(Texture.fromBitmap(new ModelsManager.instance.leaderboardIcon()));
			_leaderboardBtn.width = 50;
			_leaderboardBtn.height = 50;
			_leaderboardBtn.x = 10;
			_leaderboardBtn.y = 10;
			addChild(_leaderboardBtn);
			_leaderboardBtn.addEventListener(Event.TRIGGERED, onClickLeaderboard);
		}
		private function setInfosButton():void 
		{
			_infoBtn = new Button();
			_infoBtn.label = "?";
			_infoBtn.width = 50;
			_infoBtn.height = 50;
			_infoBtn.x = Starling.current.nativeStage.width - 60;
			_infoBtn.y = 10;
			addChild(_infoBtn);
			_infoBtn.addEventListener(Event.TRIGGERED, onClickInfo);
		}
		
		private function onClickInfo(e:Event):void 
		{
			PopUpManager.addPopUp(_infoContainer);
			UISignals.ADD_POPUP.dispatch();
			_closeBtn.addEventListener(Event.TRIGGERED, removePopup);
			
			var tf:BitmapFontTextFormat = _howToPlay.textRendererProperties.textFormat;
			_howToPlay.textRendererProperties.textFormat = null;
			tf.size = 14;
			
			_howToPlay.validate();
			_howToPlay.textRendererProperties.textFormat = tf;
			_credits.validate();
			_credits.textRendererProperties.textFormat = tf;
			_closeBtn.validate();
			_closeBtn.defaultLabelProperties.textFormat = tf;
		}
		
		private function removePopup(event:Event):void {
			_closeBtn.removeEventListener(Event.TRIGGERED, removePopup);
			PopUpManager.removePopUp(_infoContainer);
		}
		
		private function getPopupModal():DisplayObject {
			var quad:Quad = new Quad(Starling.current.nativeStage.width, Starling.current.nativeStage.height, 0x000000);
			quad.alpha = .75;
			return quad;
		}
		
		private function setPowerUpsSelector():void 
		{
			var label:Label = new Label();
			label.text = "Select your Power-Ups";
			label.width = 600;
			label.x = (Starling.current.nativeStage.stageWidth - 600 )  / 2;
			label.y = 135;
			addChild(label);
			
			_btnContainer = new Sprite();			
			
			var rolloutShape:Quad = new Quad(330, 90, 0xcc0000);
			rolloutShape.alpha = 0;
			rolloutShape.x = -20;
			rolloutShape.y = -20;
			_btnContainer.addChild(rolloutShape)
			rolloutShape.touchable = true;
			rolloutShape.addEventListener(TouchEvent.TOUCH, onTouchRolloutShape);
			
			var btn1:Button = new Button();
			btn1.name = _powerupDefs[0].id;
			btn1.width = 76;
			btn1.height = 76;
			btn1.defaultIcon = new Image(getTextureByName(btn1.name));
			_btnContainer.addChild(btn1);
			btn1.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			
			var btn2:Button = new Button();
			btn2.name = _powerupDefs[1].id;
			btn2.width = 76;
			btn2.height = 76;
			btn2.x = btn1.x + btn1.width + 10;
			btn2.defaultIcon = new Image(getTextureByName(btn2.name));
			_btnContainer.addChild(btn2);
			btn2.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			
			var btn3:Button = new Button();
			btn3.name = _powerupDefs[2].id;
			btn3.width = 76;
			btn3.height = 76;
			btn3.x = btn2.x + btn2.width + 10;
			btn3.defaultIcon = new Image(getTextureByName(btn3.name));
			_btnContainer.addChild(btn3);
			btn3.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			
			var btn4:Button = new Button();
			btn4.name = _powerupDefs[3].id;
			btn4.width = 76;
			btn4.height = 76;
			btn4.x = btn3.x + btn3.width + 10;
			btn4.defaultIcon = new Image(getTextureByName(btn4.name));
			_btnContainer.addChild(btn4);
			btn4.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			
			var btn5:Button = new Button();
			btn5.name = _powerupDefs[4].id;
			btn5.width = 76;
			btn5.height = 76;
			btn5.x = btn4.x + btn4.width + 10;
			btn5.defaultIcon = new Image(getTextureByName(btn5.name));
			_btnContainer.addChild(btn5);
			btn5.addEventListener(TouchEvent.TOUCH, onTouchPowerup);
			
			btn1.addEventListener(Event.TRIGGERED, onClickPowerup);
			btn2.addEventListener(Event.TRIGGERED, onClickPowerup);
			btn3.addEventListener(Event.TRIGGERED, onClickPowerup);
			btn4.addEventListener(Event.TRIGGERED, onClickPowerup);
			btn5.addEventListener(Event.TRIGGERED, onClickPowerup);
			
			addChild(_btnContainer);
			_btnContainer.y = 180;
			_btnContainer.x = (Starling.current.nativeStage.stageWidth / 2) - 210;
		}
		
		private function onClickPowerup(e:Event):void 
		{
			var btn:Button = e.currentTarget as Button
			var isLocked:Boolean = _user.powerups.indexOf(btn.name) == -1;
			if (isLocked) {
				displayPurchasePopup(btn.name);
			}else {
				btn.isEnabled = false;
				btn.defaultIcon.alpha = 0.25
				addPowerupToFreeSlot(btn.name,btn.x,btn.y);
			}
		}
		
		private function addPowerupToFreeSlot(name:String, posX:Number, posY:Number):void 
		{
			var btn:Button = _btnContainer.getChildByName(name) as Button;
			if (_numFreeSlots == 0) {
				if (_user.powerupSlots == 5) {
					trace("no more slots, cannot unlock more")
				}else {
					btn.isEnabled = true;
					btn.defaultIcon.alpha = 1;
					displayUnlockSlotPopup();
				}
				
			}else {
				UISignals.ADD_POWERUP_TO_SLOT.dispatch(name, new Point(posX, posY));
				addPowerupToSelection(name);
				_numFreeSlots--;
			}			
		}
		
		private function addPowerupToSelection(powerup_id:String):void {
			for (var i:uint = 0; i < _selectedPowerups.length ; i++ ) {
				if (_selectedPowerups[i] == "") {
					_selectedPowerups[i] = powerup_id;
					break;
				}
			}
		}
		
		private function getPowerupById(powerup_id:String):PowerupDefinition {
			var def:PowerupDefinition;
			for each(var pUpDef:PowerupDefinition in _powerupDefs) {
				if (pUpDef.id == powerup_id) {
					return pUpDef;
				}
			}
			return def;
		}
		
		private function displayPurchasePopup(name:String):void 
		{
			var btn:Button = new Button();
			btn.width = 500;
			btn.height = 300;
			btn.touchable = false;			
			
			var title:Label = new Label();
			title.width = 500;
			title.height = 24;
			title.y = 20
			title.text = "THIS POWER-UP IS LOCKED!";
			
			
			var powerupDef:PowerupDefinition = getPowerupById(name);
			var purchaseWithCoins:Label = new Label();
			purchaseWithCoins.width = 400;
			purchaseWithCoins.textRendererProperties.wordWrap = true;
			purchaseWithCoins.x = 50;
			
			_purchaseCreditsBtn = new Button();
			_purchaseCreditsBtn.name = name;
			_purchaseCreditsBtn.width = 200;
			_purchaseCreditsBtn.height = 50;
			_purchaseCreditsBtn.x = 150;
			
			var currentLevel:uint = GameData.getLevelForXP(_user.xp) + 1;
			if (currentLevel >= powerupDef.unlockLevel) {
				_purchaseCreditsBtn.y = 220;
				purchaseWithCoins.y = 100;
				_purchaseCreditsBtn.label = "Unlock now";
				purchaseWithCoins.text = "Unlock the «" + powerupDef.title + "» power-up with " + powerupDef.unlockCoins + " coins.";
				_purchaseCreditsBtn.addEventListener(Event.TRIGGERED, onClickUnlockWithCoins);
			}else {
				purchaseWithCoins.y = 60;
				_purchaseCreditsBtn.y = 230;
				purchaseWithCoins.text = "Unlock the «" + powerupDef.title + "» power-up at level " + powerupDef.unlockLevel.toString() + " with " + powerupDef.unlockCoins + " coins.\nOR\nUnlock now with\n" + powerupDef.unlokcCredits + " Facebook Credits";
				_purchaseCreditsBtn.label = "Buy now";
				_purchaseCreditsBtn.addEventListener(Event.TRIGGERED, onClickUnlockWithCredits);
			}
			
			_closePurchaseBtn = new Button();
			_closePurchaseBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closePurchaseBtn.width = 30;
			_closePurchaseBtn.height = 30;
			_closePurchaseBtn.x = 465;
			_closePurchaseBtn.y = 5;
			_closePurchaseBtn.addEventListener(Event.TRIGGERED, onClickClosePurchase);
			
			_purchasePowerupContainer.addChild(btn);
			_purchasePowerupContainer.addChild(title);
			_purchasePowerupContainer.addChild(purchaseWithCoins);
			_purchasePowerupContainer.addChild(_purchaseCreditsBtn);
			_purchasePowerupContainer.addChild(_closePurchaseBtn);
			
			
			PopUpManager.addPopUp(_purchasePowerupContainer);
			UISignals.ADD_POPUP.dispatch();
		}
		
		private function onClickUnlockWithCredits(e:Event):void 
		{
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchasePowerupContainer);
			_purchaseCreditsBtn.removeEventListener(Event.TRIGGERED, onClickUnlockWithCredits);
			MultiplayerSignals.POWERUP_CREDITS_UNLOCK.dispatch(Button(e.currentTarget).name);
		}
		
		private function onClickUnlockWithCoins(e:Event):void 
		{
			_purchaseCreditsBtn.removeEventListener(Event.TRIGGERED, onClickUnlockWithCoins);
			var powerupDef:PowerupDefinition = getPowerupById(Button(e.currentTarget).name);
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchasePowerupContainer);
			if (_user.igc >= powerupDef.unlockCoins) {
				MultiplayerSignals.POWERUP_UNLOCK.dispatch(powerupDef.id);
			}else {
				displayNotEnoughIGCPopup();
			}
		}
		
		private function customButtonInitializer(button:Button):void {
			_theme.themeButtonInitializer(button);
			var tf:BitmapFontTextFormat = new BitmapFontTextFormat(_theme.bitmapFont, 16, 0xffffff);
			button.defaultLabelProperties.textFormat = tf;
		}
		
		private function displayNotEnoughIGCPopup():void 
		{
			var btn:Button = new Button();
			btn.width = 500;
			btn.height = 300;
			btn.touchable = false;			
			
			var title:Label = new Label();
			title.width = 500;
			title.height = 24;
			title.y = 20
			title.text = "NOT ENOUGH COINS!";
			
			_closePurchaseCoinsBtn = new Button();
			_closePurchaseCoinsBtn.defaultIcon = new Image(Texture.fromBitmap(new TexturesManager.CloseButton()));
			_closePurchaseCoinsBtn.width = 30;
			_closePurchaseCoinsBtn.height = 30;
			_closePurchaseCoinsBtn.x = 465;
			_closePurchaseCoinsBtn.y = 5;
			_closePurchaseCoinsBtn.addEventListener(Event.TRIGGERED, onClickClosePurchaseCoins);
			
			
			var buyMoreCoinsGroup:ButtonGroup = new ButtonGroup();
			buyMoreCoinsGroup.customFirstButtonName = CUSTOM_BUTTON_NAME;
			buyMoreCoinsGroup.customButtonName = CUSTOM_BUTTON_NAME;
			buyMoreCoinsGroup.customLastButtonName = CUSTOM_BUTTON_NAME;
			buyMoreCoinsGroup.width = 300;
			buyMoreCoinsGroup.height = 200;
			buyMoreCoinsGroup.direction = "vertical";
			buyMoreCoinsGroup.x = 100;
			buyMoreCoinsGroup.y = 75;
			
			buyMoreCoinsGroup.dataProvider = new ListCollection( [
				{ label:"Buy "+ _coinsPackages[0].amount+" coins for "+ _coinsPackages[0].cost +" FB Credits", triggered:buyCoinsPack_0},
				{ label:"Buy "+ _coinsPackages[1].amount+" coins for "+ _coinsPackages[1].cost +" FB Credits", triggered:buyCoinsPack_1},
				{ label:"Buy "+ _coinsPackages[2].amount+" coins for "+ _coinsPackages[2].cost +" FB Credits", triggered:buyCoinsPack_2},
				{ label:"Buy "+ _coinsPackages[3].amount+" coins for "+ _coinsPackages[3].cost +" FB Credits", triggered:buyCoinsPack_3}
			]);				
			
			_purchaseMoreCoinsContainer.addChild(btn);
			_purchaseMoreCoinsContainer.addChild(title);
			_purchaseMoreCoinsContainer.addChild(buyMoreCoinsGroup);
			_purchaseMoreCoinsContainer.addChild(_closePurchaseCoinsBtn);
			UISignals.ADD_POPUP.dispatch();
			PopUpManager.addPopUp(_purchaseMoreCoinsContainer);
		}
		
		private function buyCoinsPack_0(event:Event):void {
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchaseMoreCoinsContainer);
			SocialSignals.COINS_PURCHASE.dispatch(_coinsPackages[0].id);
		}
		private function buyCoinsPack_1(event:Event):void {
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchaseMoreCoinsContainer);
			SocialSignals.COINS_PURCHASE.dispatch(_coinsPackages[1].id);
		}
		private function buyCoinsPack_2(event:Event):void {
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchaseMoreCoinsContainer);
			SocialSignals.COINS_PURCHASE.dispatch(_coinsPackages[2].id);
		}
		private function buyCoinsPack_3(event:Event):void {
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchaseMoreCoinsContainer);
			SocialSignals.COINS_PURCHASE.dispatch(_coinsPackages[3].id);
		}
		
		private function onClickClosePurchaseCoins(e:Event):void 
		{
			_closePurchaseCoinsBtn.removeEventListener(Event.TRIGGERED, onClickClosePurchaseCoins);
			UISignals.REMOVE_POPUP.dispatch();			
			PopUpManager.removePopUp(_purchaseMoreCoinsContainer);
		}
		
		private function onClickClosePurchase(e:Event):void 
		{
			_closePurchaseBtn.addEventListener(Event.TRIGGERED, onClickClosePurchase);
			UISignals.REMOVE_POPUP.dispatch();
			PopUpManager.removePopUp(_purchasePowerupContainer);
		}
		
		private function getTextureByName(name:String):Texture {
			switch(name) {
				case _powerupDefs[0].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp1_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp1());
					}
					break;
				case _powerupDefs[1].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp2_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp2());
					}
					break;
				case _powerupDefs[2].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp3_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp3());
					}
					break;
				case _powerupDefs[3].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp4_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp4());
					}
					break;
				case _powerupDefs[4].id:
					if (_user.powerups.indexOf(name) == -1) {
						return Texture.fromBitmap(new TexturesManager.PowerUp5_Locked());
					}else{
						return Texture.fromBitmap(new TexturesManager.PowerUp5());
					}
					break;
			}
			return new Texture();
		}
		
		private function onTouchRolloutShape(event:TouchEvent):void 
		{
			var button:Quad = Quad( event.currentTarget );
			var touchHover:Touch = event.getTouch(button, TouchPhase.HOVER);
			if (touchHover) {
				if (_callout) {
					_callout.close(true);
					_callout = null;
				}
				
			}
		}
		
		private function onTouchPowerup(event:TouchEvent):void 
		{
			var button:Button = Button( event.currentTarget );
			var touchHover:Touch = event.getTouch(button, TouchPhase.HOVER);
			
			if (touchHover) {
				if (_callout != null) {
					_callout.close(true);
				}
				var powerupDescTextfield:Label = new Label();
				powerupDescTextfield.text = getDescriptionByButtonName(button.name);
				_callout = Callout.show( powerupDescTextfield, button, "DIRECTION_ANY", false);
				_callout.touchable = false;
				var size:Point = new Point(_callout.width * 0.5, _callout.height * 0.75)
				var calloutX:Number = _callout.x
				_callout.setSize(size.x, size.y)
				_callout.x = calloutX + (size.x / 2)
				powerupDescTextfield.validate();
				var tf:BitmapFontTextFormat = powerupDescTextfield.textRendererProperties.textFormat;
				powerupDescTextfield.textRendererProperties.textFormat = null;
				tf.size = 12;
				powerupDescTextfield.textRendererProperties.textFormat = tf;
			}
		}
		
		private function getDescriptionByButtonName(name:String):String 
		{
			switch(name) {
				case _powerupDefs[0].id:
					return _powerupDefs[0].title+"\n"+_powerupDefs[0].description
					break;
				case _powerupDefs[1].id:
					return _powerupDefs[1].title+"\n"+_powerupDefs[1].description
					break;
				case _powerupDefs[2].id:
					return _powerupDefs[2].title+"\n"+_powerupDefs[2].description
					break;
				case _powerupDefs[3].id:
					return _powerupDefs[3].title+"\n"+_powerupDefs[3].description
					break;
				case _powerupDefs[4].id:
					return _powerupDefs[4].title+"\n"+_powerupDefs[4].description
					break;
			}
			return "";
		}		
		
		private function startGame(event:Event):void {
			if (_purchaseCreditsBtn && _purchaseCreditsBtn.hasEventListener(Event.TRIGGERED))
				_purchaseCreditsBtn.removeEventListener(Event.TRIGGERED, onClickUnlockWithCoins);
			if (_closePurchaseCoinsBtn && _closePurchaseCoinsBtn.hasEventListener(Event.TRIGGERED))
				_closePurchaseCoinsBtn.removeEventListener(Event.TRIGGERED, onClickClosePurchaseCoins);
			if (_closeUnlockSlotBtn && _closeUnlockSlotBtn.hasEventListener(Event.TRIGGERED))
				_closeUnlockSlotBtn.removeEventListener(Event.TRIGGERED, onCloseUnlockSlot);
			if (_unlockSlotBtn && _unlockSlotBtn.hasEventListener(Event.TRIGGERED))
				_unlockSlotBtn.removeEventListener(Event.TRIGGERED, onClickUnlockSlotWithCoins);
			if (_closePurchaseBtn && _closePurchaseBtn.hasEventListener(Event.TRIGGERED))
				_closePurchaseBtn.removeEventListener(Event.TRIGGERED, onClickClosePurchase);
			
			UISignals.POWERUP_SLOT_CLICKED.remove(onSlotSelected);
			MultiplayerSignals.POWERUP_UNLOCKED.remove(onPowerupUnlocked);
			MultiplayerSignals.SLOT_UNLOCKED.remove(onSlotUnlocked);
			
			_startButton.removeEventListener(Event.TRIGGERED, startGame);
			_prevButton.removeEventListener( Event.TRIGGERED, prevVehicle);
			_nextButton.removeEventListener( Event.TRIGGERED, nextVehicle);
			if(_leaderboardBtn){
				_leaderboardBtn.removeEventListener(Event.TRIGGERED, onClickLeaderboard);
				removeChild(_leaderboardBtn);
			}
			if (_leaderboardList) {
				_leaderboardList.removeEventListener( Event.CHANGE, onClickItemLeaderboard );
			}
			removeChild(_startButton);
			removeChild(_btnContainer);
			removeChild(_prevButton);
			removeChild(_nextButton);
			removeChild(_colorSelector);
			dispose();
			GameSignals.SESSION_START.dispatch(_vehicleId, _textureId,_selectedPowerups);
			
		}
		
		private function setVehicleButtons():void {
			_prevButton = new Button();
			_prevButton.height = 50;
			_prevButton.label = "<<";
			addChild(_prevButton);
			_prevButton.addEventListener( Event.TRIGGERED, prevVehicle );
			
			_nextButton = new Button();
			_nextButton.height = 50;
			_nextButton.label = ">>";
			addChild(_nextButton);
			_nextButton.addEventListener( Event.TRIGGERED, nextVehicle );
		}
		
		private function prevVehicle(event:Event):void {
			if (_vehicleId == 0)
				return 
			_vehicleId --;
			UISignals.SET_VEHICLE.dispatch(_vehicleId);
		}
		
		private function nextVehicle(event:Event):void {
			if (_vehicleId == ModelsManager.instance.maxVehicles - 1)
				return;
			_vehicleId++;
			UISignals.SET_VEHICLE.dispatch(_vehicleId);
		}
		
		private function setTextureSelector():void {
			_colorSelector = new ButtonGroup();
			
			_colorSelector.width = 300;
			_colorSelector.height = 30;
			_colorSelector.direction = "horizontal";
			
			_colorSelector.dataProvider = new ListCollection( [
				{ label: "", defaultIcon:new Quad(20, 20, 0x00d3dc), triggered:setColor_0},
				{ label: "", defaultIcon:new Quad(20, 20, 0x00dc16), triggered:setColor_1},
				{ label: "", defaultIcon:new Quad(20, 20, 0xce01da), triggered:setColor_2},
				{ label: "", defaultIcon:new Quad(20, 20, 0xdb0602), triggered:setColor_3},
				{ label: "", defaultIcon:new Quad(20, 20, 0xe7d300), triggered:setColor_4}
			]);		
			
			addChild(_colorSelector);
			_colorSelector.x = (Starling.current.nativeStage.stageWidth - _colorSelector.width )  / 2 
			
		}
		
		private function setColor_0(event:Event):void {
			_textureId = 0;
			UISignals.SET_TEXTURE.dispatch(0);
		}
		private function setColor_1(event:Event):void {
			_textureId = 1;
			UISignals.SET_TEXTURE.dispatch(1);
		}
		private function setColor_2(event:Event):void {
			_textureId = 2;
			UISignals.SET_TEXTURE.dispatch(2);
		}
		private function setColor_3(event:Event):void {
			_textureId = 3;
			UISignals.SET_TEXTURE.dispatch(3);
		}
		private function setColor_4(event:Event):void {
			_textureId = 4;
			UISignals.SET_TEXTURE.dispatch(4);
		}
		
		
		override protected function draw():void
		{			
			_startButton.validate();
			_startButton.x = (Starling.current.nativeStage.stageWidth - _startButton.width) / 2;
			_startButton.y = Starling.current.nativeStage.stageHeight - _startButton.height - 50;
			
			_colorSelector.y = _startButton.y - 65; 
			
			_prevButton.validate();
			_prevButton.x = ((Starling.current.nativeStage.stageWidth - _prevButton.width) / 2) - 300;
			_prevButton.y = ((Starling.current.nativeStage.stageHeight - _prevButton.height) / 2) + 75;
			
			_nextButton.validate();
			_nextButton.x = ((Starling.current.nativeStage.stageWidth - _nextButton.width) / 2) + 300;
			_nextButton.y = ((Starling.current.nativeStage.stageHeight - _nextButton.height) / 2) + 75;
		}
		
	}

}