package com.mayhem.multiplayer 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.entities.Mesh;
	import awayphysics.dynamics.AWPRigidBody;
	import com.hibernum.social.model.SocialPayment;
	import com.hibernum.social.model.SocialUser;
	import com.hibernum.social.service.FacebookService;
	import com.mayhem.game.ArenaFactory;
	import com.mayhem.game.CollisionManifold;
	import com.mayhem.game.GameStats;
	import com.mayhem.game.LightRigidBody;
	import com.mayhem.game.MovingCube;
	import com.mayhem.game.powerups.ExplosionData;
	import com.mayhem.game.powerups.PowerupDefinition;
	import com.mayhem.game.powerups.PowerUpMessage;
	import com.mayhem.game.powerups.PowerupSlot;
	import com.mayhem.SoundsManager;
	import flash.display.Stage;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import org.osflash.signals.Signal;
	import playerio.*;
	import com.mayhem.signals.*;
	import flash.net.registerClassAlias;
	import flash.geom.Matrix3D;
	import away3d.containers.ObjectContainer3D;
	 
	public class Connector 
	{
		
		private var _allUsers:Dictionary;
		private var _mainUserId:uint = 0;
		private var _client:Client;
		private var _socialUser:SocialUser;
		private var _mainConnection:Connection;
		private var _vehicle_id:uint;
		private var _texture_id:uint;
		private var _allPowerups:Vector.<PowerupDefinition>
		private var _allCoinsPacks:Vector.<CoinsPackage>;
		private var _allSlots:Vector.<PowerupSlot>;
		private var _selectedPowerups:Array;
		
		public static const MAX_USER_PER_ROOM:uint = 12;
		
		//url for live deployment
		//https://office-mayhem-g9omnsmpskqoxaolbzotca.fb.playerio.com/fb/omfb/
		
		public function Connector(pStage:Stage, user:SocialUser) 
		{
			_allUsers = new Dictionary();
			_socialUser = user;
			registerClassAlias("LightRigidBody", LightRigidBody);
			registerClassAlias("CollisionManifold", CollisionManifold);
			registerClassAlias("Vector3D", Vector3D);
			registerClassAlias("Vector", Vector);
			registerClassAlias("PowerUpMessage", PowerUpMessage);
			registerClassAlias("ExplosionData", ExplosionData);
			registerClassAlias("GameStats", GameStats);
			
			PlayerIO.connect(
				pStage,										//Reference to stage
				"office-mayhem-g9omnsmpskqoxaolbzotca",		//Game id (Get your own at playerio.com)
				"testconnection",							//Connection id, default is public
				"user_"+user.social_id.toString(),			//Username
				"",											//User auth. Can be left blank if authentication is disabled on connection
				null,										//Current PartnerPay partner.
				handleConnect,								//Function executed on successful connect
				handleError									//Function executed if we recive an error
			);   
		}
		private function handleConnect(client:Client):void{
			trace("Sucessfully connected to player.io");
			_client = client;
			setSignals();
			//uncomment this line for local server 
			_client.multiplayer.developmentServer = "localhost:8184";
			_client.bigDB.load("PlayerObjects", client.connectUserId, onUserDataLoaded, handleError);
		}
		
		private function onGameStart(vId:uint, tId:uint, selectedPowerups:Array):void {
			trace("Game starts", vId, tId);
			_selectedPowerups = selectedPowerups;
			_vehicle_id = vId;
			_texture_id = tId;
			_client.multiplayer.listRooms("OfficeMayhem", { }, 20, 0, onGetRoomList, handleError);	
			
		}
		
		private function onUserDataLoaded(dbObject:DatabaseObject):void {
			if (dbObject == null) {
				_client.payVault.credit(100, "startGame", onFirstTimeCredit, handleError);
			}else {
				onUserCreated(dbObject);
			}
		}
		
		private function onFirstTimeCredit():void {
			_client.payVault.give([{itemKey:"powerup_0"},{itemKey:"slot_0"}], onFirstTimePowerup, handleError);			
		}
		
		private function onFirstTimePowerup():void {
			_client.bigDB.createObject("PlayerObjects", _client.connectUserId, { username:_socialUser.name, xp:0, vehicleId:0, textureId:0, music:true }, onUserCreated, handleError);
		}
		
		private function onUserCreated(dbObject:DatabaseObject):void {
			var user:GameUserVO = new GameUserVO(_client.connectUserId);
			user.xp = dbObject.xp;
			user.name = dbObject.username;
			user.vehicleId = dbObject.vehicleId;
			user.textureId = dbObject.textureId;
			user.hasMusic = dbObject.music;
			_allUsers[_client.connectUserId] = user;	
			_client.payVault.refresh(onPayVaultLoaded, handleError);			
		}
		
		private function onPayVaultLoaded():void {			
			for (var i:uint = 0 ; i < _client.payVault.items.length ; i++) {
				var vaultItem:VaultItem = _client.payVault.items[i];
				trace(vaultItem.itemKey)
				if (vaultItem.itemKey.split("_")[0] == "slot") {
					_allUsers[_client.connectUserId].powerupSlots++;
				}else if (vaultItem.itemKey.split("_")[0] == "powerup"){
					_allUsers[_client.connectUserId].powerups.push(vaultItem.itemKey);
				}
			}
			trace(_allUsers[_client.connectUserId].powerupSlots)
			_allUsers[_client.connectUserId].igc = _client.payVault.coins;
			var allItems:Array = ["powerup_0","powerup_1","powerup_2","powerup_3","powerup_4","slot_0","slot_1","slot_2","slot_3","slot_4","coins_0", "coins_1", "coins_2", "coins_3"]
			_client.bigDB.loadKeys("PayVaultItems", allItems, onCompleteLoadVaultItems, handleError);
			
		}
		
		private function onCompleteLoadVaultItems(dbarr:Array):void {
			_allPowerups = new Vector.<PowerupDefinition>();
			_allCoinsPacks = new Vector.<CoinsPackage>();
			_allSlots = new Vector.<PowerupSlot>();
			for (var i:uint = 0 ; i < dbarr.length ; i++ ) {
				var dbObject:DatabaseObject = dbarr[i];
				var keySplit:String = dbObject.key.split("_")[0];
				if (keySplit == "powerup") {
					_allPowerups.push(new PowerupDefinition(dbObject));
				}else if (keySplit == "slot") {
					_allSlots.push(new PowerupSlot(dbObject));
				}else if (keySplit == "coins") {
					_allCoinsPacks.push(new CoinsPackage(dbObject));
				}				
			}
			MultiplayerSignals.USER_LOADED.dispatch(_allUsers[_client.connectUserId],_allPowerups,_allCoinsPacks,_allSlots);
		}
		
		
		private function getPowerupById(powerup_id:String):PowerupDefinition {
			var def:PowerupDefinition;
			for each(var pUpDef:PowerupDefinition in _allPowerups) {
				if (pUpDef.id == powerup_id) {
					return pUpDef;
				}
			}
			return def;
		}
		
		private function unlockPowerup(powerupId:String):void {
			var powerup:PowerupDefinition = getPowerupById(powerupId);
			_client.payVault.buy([ { itemKey:powerup.id } ], true, function():void {
				_client.payVault.refresh(function():void {
					var mainUser:GameUserVO = _allUsers[_client.connectUserId];
					mainUser.powerups.push(powerupId);
					mainUser.igc = _client.payVault.coins;
					MultiplayerSignals.POWERUP_UNLOCKED.dispatch(_allUsers[_client.connectUserId],powerupId);
				}, handleError);
			}, handleError);
		}
		
		
		private function setSignals():void {
			GameSignals.SESSION_START.add(onGameStart);
			UserInputSignals.USER_IS_MOVING.add(onPlayerMoving);
			UserInputSignals.USER_STOPPED_MOVING.add(onPlayerStopMoving);
			UserInputSignals.USER_UPDATE_STATE.add(onPlayerUpdateState);
			UserInputSignals.AI_UPDATE_STATE.add(onAIUpdateState);
			UserInputSignals.USER_IS_COLLIDING.add(onCollision);
			UserInputSignals.POWERUP_TRIGGER.add(onPowerupTrigger);
			GameSignals.SESSION_PAUSE.add(onSessionPause);
			GameSignals.SESSION_RESTART.add(onSessionRestart);
			MultiplayerSignals.UPDATE_AI_TARGET.add(setAITarget);
			MultiplayerSignals.VEHICLE_DIE.add(setVehicleDie);
			MultiplayerSignals.POWERUP_UNLOCK.add(unlockPowerup);
			SocialSignals.COINS_PURCHASE.add(puchaseCoins);
			MultiplayerSignals.POWERUP_CREDITS_UNLOCK.add(BuyPowerupWithCredits);
			MultiplayerSignals.SLOT_CREDITS_UNLOCK.add(unlockSlotWithCredits);
			MultiplayerSignals.SLOT_UNLOCK.add(unlockSlotWithCoins);
			UISignals.BACK_TO_SELECTOR.add(removeUserFormServer);
			MultiplayerSignals.CHANGE_MUSIC_SETTINGS.add(onChangeMusicSettings);
			MultiplayerSignals.LEVEL_UP.add(onLevelUp)
		}
		
		
		
		private function onChangeMusicSettings(hasMusic:Boolean):void {
			_client.bigDB.loadMyPlayerObject(function(dbObject:DatabaseObject):void {
				dbObject.music = hasMusic;
				dbObject.save();
			},handleError);
		}
		
		private function removeUserFormServer():void {
			var mess:Message = _mainConnection.createMessage("RemoveUser");
			_mainConnection.sendMessage(mess);
		}
		
		private function onLevelUp():void 
		{
			_client.payVault.credit(500, "levelup", function():void {
				_client.payVault.refresh(function():void {
					var mainUser:GameUserVO = _allUsers[_client.connectUserId];
					mainUser.igc = _client.payVault.coins;
					UISignals.UPDATE_USER_INFO.dispatch(mainUser);
				}, handleError);
			},handleError);
		}
		
		private function unlockSlotWithCoins(slot_id:String):void {
			_client.payVault.buy([{itemKey:slot_id}], true, function():void {
				_client.payVault.refresh(function():void {
					var mainUser:GameUserVO = _allUsers[_client.connectUserId];
					mainUser.powerupSlots++;
					mainUser.igc = _client.payVault.coins;
					MultiplayerSignals.SLOT_UNLOCKED.dispatch(mainUser, slot_id);
				}, handleError);
			}, handleError);
		}
		
		private function unlockSlotWithCredits(slot_id:String):void 
		{
			var slot:PowerupSlot;
			for (var i:uint = 0 ; i < _allSlots.length ; i++ ) {
				if (slot_id == _allSlots[i].id) {
					slot = _allSlots[i];
					break;
				}
			}
			var dataObject:Object = {                           
				title:"+1 Power-up Slot",                    
				description:"Unlock a new Power-up slot!",
				image_url:_client.gameFS.getURL("/img/powerup_empty_slot.png"),
				product_url:""
			};
			_client.payVault.getBuyDirectInfo(
				"facebook",
				dataObject,
				[ { itemKey:slot_id } ],
				function(info:Object):void {
					FacebookService.makePayment(info, function(response:Object):void {
						_client.payVault.refresh(function():void {
							var mainUser:GameUserVO = _allUsers[_client.connectUserId];
							mainUser.powerupSlots++;
							mainUser.igc = _client.payVault.coins;
							MultiplayerSignals.SLOT_UNLOCKED.dispatch(mainUser, slot_id);
						}, handleError);
					},function(error:Object):void {
						//error or cancelled payment
					});
				},
				handleError
			);
		}
		
		private function BuyPowerupWithCredits(powerup_id:String):void {
			var powerup:PowerupDefinition;
			for (var i:uint = 0 ; i < _allPowerups.length ; i++ ) {
				if (powerup_id == _allPowerups[i].id) {
					powerup = _allPowerups[i];
					break;
				}
			}
			var dataObject:Object = {                           
				title:powerup.title,                    
				description:"Unlock this awesome power-up!",
				image_url:_client.gameFS.getURL("/img/"+powerup.id+".jpg"),
				product_url:""
			};
			_client.payVault.getBuyDirectInfo(
				"facebook",
				dataObject,
				[ { itemKey:powerup_id } ],
				function(info:Object):void {
					FacebookService.makePayment(info, function(response:Object):void {
						_client.payVault.refresh(function():void {
							var mainUser:GameUserVO = _allUsers[_client.connectUserId];
							mainUser.powerups.push(powerup_id);
							mainUser.igc = _client.payVault.coins;
							MultiplayerSignals.POWERUP_UNLOCKED.dispatch(_allUsers[_client.connectUserId],(powerup_id));
						}, handleError);
					},function(error:Object):void {
						//error or cancelled payment
					});
				},
				handleError
			);
		}
		
		private function puchaseCoins(package_id:String):void 
		{
			var coinsPackage:CoinsPackage;
			for (var i:uint = 0 ; i < _allCoinsPacks.length ; i++ ) {
				if (package_id == _allCoinsPacks[i].id) {
					coinsPackage = _allCoinsPacks[i];
					break;
				}
			}
			var dataObject:Object = {                           
					coinamount:coinsPackage.amount.toString(),                         
					title:coinsPackage.amount.toString() + " Coins",
					description:"Buy " + coinsPackage.amount.toString() + " Coins, thank you!",
					image_url:_client.gameFS.getURL("/img/coins.png"),
					product_url:""
				};
			_client.payVault.getBuyCoinsInfo(
				"facebook",  
				dataObject,
				function(info:Object):void {
					FacebookService.makePayment(info, function(response:Object):void {
						_client.payVault.refresh(onPaymentComplete, handleError);
					},function(error:Object):void {
						//error or cancelled payment
					});
				},
				handleError
			)
		}
		
		private function onPaymentComplete():void {
			var mainUser:GameUserVO = _allUsers[_client.connectUserId];
			mainUser.igc = _client.payVault.coins;
			SocialSignals.COINS_PURCHASED.dispatch(mainUser);
		}
		
		private function setVehicleDie(vehicleId:String):void {
			var mess:Message = _mainConnection.createMessage("SetVehicleDie");
			mess.add(vehicleId);
			_mainConnection.sendMessage(mess);
		}
		
		private function setAITarget(chaserId:String, targetId:String):void {
			var mess:Message = _mainConnection.createMessage("SetAITarget");
			mess.add(chaserId);
			mess.add(targetId);
			_mainConnection.sendMessage(mess);
		}
		
		private function onSessionRestart(cubeId:String, spawnIndex:int):void {
			var mess:Message = _mainConnection.createMessage("UserSessionRestart");
			mess.add(cubeId);
			mess.add(spawnIndex);
			_mainConnection.sendMessage(mess);
		}
		
		private function onSessionPause(gameStats:GameStats):void {
			var mess:Message = _mainConnection.createMessage("UserSessionExpire");
			var statsBytes:ByteArray = new ByteArray();
			statsBytes.writeUTF(gameStats.uid);
			statsBytes.writeInt(gameStats.current_num_kills_received);
			statsBytes.writeInt(gameStats.current_num_kills_inflicted);
			statsBytes.writeInt(gameStats.current_num_hits_received);
			statsBytes.writeInt(gameStats.current_num_hits_inflicted);
			statsBytes.writeInt(gameStats.current_num_felt);
			statsBytes.writeInt(gameStats.current_max_speed);
			mess.add(statsBytes);
			_mainConnection.sendMessage(mess);	
		}
		
		private function onPowerupTrigger(pUpMesage:PowerUpMessage):void {
			var mess:Message = _mainConnection.createMessage("PowerUpTrigger");
			var pUpBytes:ByteArray = new ByteArray();
			pUpBytes.writeObject(pUpMesage);
			mess.add(pUpBytes);
			_mainConnection.sendMessage(mess);
		}
		
		private function onCollision(manifold:CollisionManifold):void
		{
			var mess:Message = _mainConnection.createMessage("PlayerIsColliding");
			var collisionBytes:ByteArray = new ByteArray();
			collisionBytes.writeObject(manifold);
			mess.add(collisionBytes);
			_mainConnection.sendMessage(mess);	
		}
		
		private function onAIUpdateState(allAI:Vector.<Object>):void {
			var mess:Message = _mainConnection.createMessage("AIUpdateState");
			var allAIBytes:ByteArray = new ByteArray();
			allAIBytes.writeObject(allAI);
			mess.add(allAIBytes);
			_mainConnection.sendMessage(mess);			
		}
		
		private function onPlayerUpdateState(rigidBody:LightRigidBody):void {
			var mess:Message = _mainConnection.createMessage("PlayerUpdateState");
			var rigidBodyBytes:ByteArray = new ByteArray();
			rigidBodyBytes.writeObject(rigidBody);
			mess.add(rigidBodyBytes);
			_mainConnection.sendMessage(mess);	
		}
		
		private function onPlayerStopMoving(keyCode:uint, timestamp:Number):void {
			var mess:Message = _mainConnection.createMessage("PlayerStoppedMoving");
			mess.add(keyCode);
			mess.add(timestamp);
			_mainConnection.sendMessage(mess);			
		}
		
		private function onPlayerMoving(keyCode:uint, timestamp:Number):void {
			var mess:Message = _mainConnection.createMessage("PlayerIsMoving");
			mess.add(keyCode);
			mess.add(timestamp);
			_mainConnection.sendMessage(mess);
		}
		
		private function onGetRoomList(rooms:Array):void {
			var numRooms:uint = rooms.length;
			var roomsComplete:uint = 0;
			var room:RoomInfo
			for each(room in rooms) {
				trace('roomId',room.id)
				if (room.onlineUsers == MAX_USER_PER_ROOM) {
					room.data.isFull = true;
					roomsComplete ++;
				}else {
					room.data.isFull = false;
				}
			}
			if (rooms.length > 0 && roomsComplete < numRooms) {
				for each(room in rooms) {
					if (!room.data.isFull) {
						_client.multiplayer.joinRoom(room.id, { name:_socialUser.name , textureId:_texture_id, vehicleId:_vehicle_id}, handleJoin, handleError);
						return;
					}
				}
					
			}else {
				_client.multiplayer.createJoinRoom(
					null,								//Room id. If set to null a random roomid is used
					"OfficeMayhem",						//The game type started on the server
					true,								//Should the room be visible in the lobby?
					{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
					{name:_socialUser.name, textureId:_texture_id, vehicleId:_vehicle_id},			//User join data
					handleJoin,							//Function executed on successful joining of the room
					handleError							//Function executed if we got a join error
				);
			}
		}
		
		private function setRoomUsersHandler(m:Message):void {
			var numParams:uint = 5;
			for (var i:uint = 0; i < m.length; i++ ) {
				if (i % numParams == numParams-1) {
					var byteArray:ByteArray = m.getByteArray(i);
					var lightBody:LightRigidBody = byteArray.readObject();
					var user:GameUserVO = new GameUserVO(m.getString( i - 4));
					user.spawnIndex = m.getUInt( i - 3);
					user.vehicleId = m.getUInt(i - 2);
					user.textureId = m.getUInt(i - 1);
					user.isMainUser = false;
					_allUsers[user.uid] = user;
					MultiplayerSignals.USERS_IN_ROOM.dispatch( { user:user, rigidBody:lightBody} );
				}
			}
			MultiplayerSignals.CREATE_AI_VEHICLES.dispatch();
		}
		
		private function UserJoinedHandler(m:Message, userid:String, userIndex:int, xp:uint, igc:int, vehicleId:uint, textureId:uint, isAIMaster:Boolean):void {
			var currentUser:GameUserVO;
			if (_allUsers[userid] == null) {
				currentUser = new GameUserVO(userid)
				_allUsers[userid] = currentUser;
			}else {
				currentUser = _allUsers[userid];
			}	
			var isMain:Boolean;
			if (userid == "user_"+_socialUser.social_id){
				trace("You are the main user", userid);
				currentUser.selectedPowerups = _selectedPowerups;
				GameSignals.REMOVE_MENU.dispatch();
				isMain = true;
			}else{
				trace("Player with the userid", userid, "just joined the game");
				isMain = false;
			}
			currentUser.igc = igc;
			currentUser.isMainUser = isMain;
			currentUser.spawnIndex = userIndex;
			currentUser.xp = xp;
			currentUser.vehicleId = vehicleId;
			currentUser.textureId = textureId;
			currentUser.isAIMaster = isAIMaster;
			MultiplayerSignals.USER_JOINED.dispatch( currentUser );
			if (isMain)
				_mainConnection.send("GetRoomUsers");
		}
		
		private function AIStateUpdateHandler(m:Message, byteArray:ByteArray):void {
			var allAI:Vector.<Object> = byteArray.readObject();
			UserInputSignals.AI_HAS_UPDATE_STATE.dispatch(allAI);
		}
		private function playerStateUpdateHandler(m:Message, userid:String, byteArray:ByteArray):void {
			var rBody:LightRigidBody = byteArray.readObject();
			UserInputSignals.USER_HAS_UPDATE_STATE.dispatch(userid, rBody);
		}
		
		private function playerHasMovedHandler(m:Message, userid:String, keyCode:uint, timestamp:Number):void {
			UserInputSignals.USER_HAS_MOVED.dispatch(userid, keyCode,timestamp);
		}
		
		private function playerStoppedMovingHandler(m:Message, userid:String, keyCode:uint, timestamp:Number):void {
			UserInputSignals.USER_HAS_STOPPED_MOVING.dispatch(userid, keyCode,timestamp);
		}
		
		private function userLeftHandler(m:Message, userid:String, userIndex:int, newMasterId:String):void{
			trace("Player with the userid ", userid, " just left the room");
			MultiplayerSignals.USER_REMOVED.dispatch(userid,userIndex,newMasterId);
		}
		
		private function powerUpTriggered(m:Message, byteArray:ByteArray):void {
			var pupMessage:PowerUpMessage = byteArray.readObject();
			MultiplayerSignals.POWERUP_TRIGGERED.dispatch(pupMessage);
		}
		
		private function playerHasCollidedHandler(m:Message, byteArray:ByteArray):void {
			var manifold:CollisionManifold = byteArray.readObject();
			MultiplayerSignals.USER_HAS_COLLIDED.dispatch(manifold);
		}
		
		private function userSessionExpired(m:Message, uid:String, coins:int, xp:uint):void {
			var user:GameUserVO = _allUsers[uid];
			user.igc = coins;
			user.xp = xp;
			trace("userSessionExpired",user.powerupSlots)
			_client.bigDB.load("UserStats", uid, onStatsComplete);
			UISignals.UPDATE_USER_INFO.dispatch(user);
		}
		
		private function onStatsComplete(dbObject:DatabaseObject):void {
			MultiplayerSignals.SESSION_PAUSED.dispatch(dbObject);
		}
		
		private function userSessionRestarted(m:Message, uid:String):void {
			MultiplayerSignals.SESSION_RESTARTED.dispatch(uid);
		}
		
		private function onAITargetUpdated(m:Message, chaser_id:String, target_id:String):void {
			MultiplayerSignals.AI_TARGET_UPDATED.dispatch(chaser_id,target_id);
		}
		
		private function onVehicleDied(m:Message, deadVehicleId:String):void {
			MultiplayerSignals.VEHICLE_DIED.dispatch(deadVehicleId);
		}
		
		private function handleJoin(connection:Connection):void {
			_mainConnection = connection;
			trace("Sucessfully connected to the multiplayer server");
			_mainConnection.addDisconnectHandler(handleDisconnect);			
			_mainConnection.addMessageHandler("SetRoomUsers", setRoomUsersHandler);
			_mainConnection.addMessageHandler("UserJoined", UserJoinedHandler);
			_mainConnection.addMessageHandler("PlayerHasStateUpdate", playerStateUpdateHandler);
			_mainConnection.addMessageHandler("AIHasStateUpdate", AIStateUpdateHandler);
			_mainConnection.addMessageHandler("PlayerHasMoved", playerHasMovedHandler);
			_mainConnection.addMessageHandler("PlayerHasStoppedMoving", playerStoppedMovingHandler);			
			_mainConnection.addMessageHandler("UserLeft", userLeftHandler);			
			_mainConnection.addMessageHandler("PlayerHasCollided", playerHasCollidedHandler);
			_mainConnection.addMessageHandler("PowerUpTriggered", powerUpTriggered);
			_mainConnection.addMessageHandler("UserSessionExpired", userSessionExpired);
			_mainConnection.addMessageHandler("UserSessionRestarted", userSessionRestarted);
			_mainConnection.addMessageHandler("AITargetUpdated", onAITargetUpdated);
			_mainConnection.addMessageHandler("VehicleDied", onVehicleDied);
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		private function handleError(error:PlayerIOError):void{
			trace("got", error);
		}
		
	}

}