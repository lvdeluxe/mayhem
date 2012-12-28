package com.mayhem.multiplayer 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import away3d.entities.Mesh;
	import awayphysics.dynamics.AWPRigidBody;
	import com.hibernum.social.model.SocialUser;
	import com.mayhem.game.CollisionManifold;
	import com.mayhem.game.LightRigidBody;
	import com.mayhem.game.powerups.ExplosionData;
	import com.mayhem.game.powerups.PowerUpMessage;
	import flash.display.Stage;
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
			
			PlayerIO.connect(
				pStage,								//Referance to stage
				"office-mayhem-g9omnsmpskqoxaolbzotca",		//Game id (Get your own at playerio.com)
				"public",							//Connection id, default is public
				"user_"+user.social_id.toString(),	//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				null,								//Current PartnerPay partner.
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);   
		}
		private function handleConnect(client:Client):void{
			trace("Sucessfully connected to player.io");
			_client = client;
			_client.multiplayer.developmentServer = "localhost:8184";
			_client.multiplayer.listRooms("OfficeMayhem", { }, 20, 0, onGetRoomList, handleError);	
			setSignals();
		}
		
		
		private function setSignals():void {
			UserInputSignals.USER_IS_MOVING.add(onPlayerMoving);
			UserInputSignals.USER_STOPPED_MOVING.add(onPlayerStopMoving);
			UserInputSignals.USER_UPDATE_STATE.add(onPlayerUpdateState);
			UserInputSignals.AI_UPDATE_STATE.add(onAIUpdateState);
			UserInputSignals.USER_IS_COLLIDING.add(onCollision);
			UserInputSignals.POWERUP_TRIGGER.add(onPowerupTrigger);
		}
		
		
		private function onPowerupTrigger(pUpMesage:PowerUpMessage):void {
			var mess:Message = _mainConnection.createMessage("PowerUpTrigger");
			var pUpBytes:ByteArray = new ByteArray();
			pUpBytes.writeObject(pUpMesage);
			mess.add(pUpBytes);
			_mainConnection.sendMessage(mess);	
			trace("send from connector")
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
						_client.multiplayer.joinRoom(room.id, { name:_socialUser.name }, handleJoin, handleError);
						return;
					}
				}
					
			}else {
				_client.multiplayer.createJoinRoom(
					null,								//Room id. If set to null a random roomid is used
					"OfficeMayhem",						//The game type started on the server
					true,								//Should the room be visible in the lobby?
					{},									//Room data. This data is returned to lobby list. Variabels can be modifed on the server
					{name:_socialUser.name},			//User join data
					handleJoin,							//Function executed on successful joining of the room
					handleError							//Function executed if we got a join error
				);
			}
		}
		
		private function setRoomUsersHandler(m:Message):void {
			for (var i:uint = 0; i < m.length; i++ ) {
				if (i % 2 == 1) {
					trace(i)
					var byteArray:ByteArray = m.getByteArray(i);
					var lightBody:LightRigidBody = byteArray.readObject();
					trace("SetRoomUsers",lightBody)
					MultiplayerSignals.USERS_IN_ROOM.dispatch( { uid:m.getString( i - 1), isMainUser:false, rigidBody:lightBody} );
				}
			}
		}
		
		private function UserJoinedHandler(m:Message, userid:String, userIndex:int):void {
			_allUsers[userid] = new GameUserVO(userid);
			var isMain:Boolean;
			if (userid == "user_"+_socialUser.social_id){
				trace("You are the main user", userid);
				isMain = true
			}else{
				trace("Player with the userid", userid, "just joined the game");
				isMain = false;
			}
			MultiplayerSignals.USER_JOINED.dispatch( { uid:userid, user_index:userIndex, isMainUser:isMain } );
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
		
		private function userLeftHandler(m:Message, userid:String, userIndex:int):void{
			trace("Player with the userid", userid, "just left the room");
			MultiplayerSignals.USER_REMOVED.dispatch(userid,userIndex);
		}
		
		private function powerUpTriggered(m:Message, byteArray:ByteArray):void {
			trace("message received")
			var pupMessage:PowerUpMessage = byteArray.readObject();
			MultiplayerSignals.POWERUP_TRIGGERED.dispatch(pupMessage);
		}
		
		private function playerHasCollidedHandler(m:Message, byteArray:ByteArray):void {
			var manifold:CollisionManifold = byteArray.readObject();
			MultiplayerSignals.USER_HAS_COLLIDED.dispatch(manifold);
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
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		private function handleError(error:PlayerIOError):void{
			trace("got", error);
		}
		
	}

}