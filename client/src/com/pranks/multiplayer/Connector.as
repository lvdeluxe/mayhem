package com.pranks.multiplayer 
{
	/**
	 * ...
	 * @author availlant
	 */
	
	import com.pranks.social.model.SocialUser;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	import playerio.*;
	import com.pranks.signals.*;
	 
	public class Connector 
	{
		
		private var _allUsers:Dictionary;
		private var _mainUserId:uint = 0;
		private var _client:Client;
		private var _socialUser:SocialUser;
		private var _mainConnection:Connection;
		
		//url for live deployment
		//https://office-mayhem-g9omnsmpskqoxaolbzotca.fb.playerio.com/fb/omfb/
		
		public function Connector(pStage:Stage, user:SocialUser) 
		{
			_allUsers = new Dictionary();
			_socialUser = user;
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
			//Set developmentsever (Comment out to connect to your server online)
			_client.multiplayer.developmentServer = "localhost:8184";
			
			//Create pr join the room test
			_client.multiplayer.listRooms("OfficeMayhem", { }, 20, 0, onGetRoomList, handleError);		
			
			UserInputSignals.USER_IS_MOVING.add(onPlayerMoving);
			UserInputSignals.USER_STOPPED_MOVING.add(onPlayerStopMoving);
			UserInputSignals.USER_UPDATE_STATE.add(onPlayerUpdateState);
			
		}
		
		private function onPlayerUpdateState(rotation:Vector3D, position:Vector3D):void {
			var mess:Message = _mainConnection.createMessage("PlayerUpdateState");
			mess.add(rotation.x);
			mess.add(rotation.y);
			mess.add(rotation.z);
			mess.add(position.x);
			mess.add(position.y);
			mess.add(position.z);
			_mainConnection.sendMessage(mess);	
		}
		
		private function onPlayerStopMoving(keyCode:uint):void {
			var mess:Message = _mainConnection.createMessage("PlayerStoppedMoving");
			//mess.add("PlayerIsMoving");
			mess.add(keyCode);
			//mess.add(position.z);
			_mainConnection.sendMessage(mess);			
		}
		
		private function onPlayerMoving(keyCode:uint, timestamp:Number):void {
			var mess:Message = _mainConnection.createMessage("PlayerIsMoving");
			//mess.add("PlayerIsMoving");
			mess.add(keyCode);
			mess.add(timestamp);
			//mess.add(position.z);
			_mainConnection.sendMessage(mess);
		}
		
		private function onGetRoomList(rooms:Array):void {
			for each(var room:RoomInfo in rooms) {
				trace(room.id)
				trace(room.onlineUsers)
				trace(room.roomType)
			}
			if (rooms.length > 0) {
				_client.multiplayer.joinRoom(rooms[0].id, {name:_socialUser.name }, handleJoin, handleError);
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
		
		private function handleJoin(connection:Connection):void {
			_mainConnection = connection;
			trace("Sucessfully connected to the multiplayer server");			
			//Add disconnect listener
			connection.addDisconnectHandler(handleDisconnect);
			//Add message listener for users joining the room
			connection.addMessageHandler("SetRoomUsers", function(m:Message):void {
				var arr_args:Array = []
				for (var i:uint = 0; i < m.length ; i++ ) {
					arr_args.push( m.getString(i))
					if (i % 3 == 2) {
						var isMain:Boolean = arr_args[0] == "user_" + _socialUser.social_id;
						if(!isMain)MultiplayerSignals.USER_CREATED.dispatch( { uid:arr_args[0], isMainUser:isMain, coords:new Point(arr_args[1], arr_args[2]) } );
						arr_args = [];
					}
				}
			});
			
			//Add message listener for users joining the room
			connection.addMessageHandler("UserJoined", function(m:Message, userid:String, coordsX:int, coordsY:int):void {
				_allUsers[userid] = new GameUserVO(userid);
				var isMain:Boolean;
				if (userid == "user_"+_socialUser.social_id){
					trace("You are the main user", userid);
					isMain = true
				}else{
					trace("Player with the userid", userid, "just joined the room");
					isMain = false;
				}
				MultiplayerSignals.USER_CREATED.dispatch( { uid:userid, isMainUser:isMain, coords:new Point(coordsX, coordsY) } );
				if (isMain)
					connection.send("GetRoomUsers");
			});

			connection.addMessageHandler("PlayerHasStateUpdate", function(m:Message, userid:String, rotX:Number, rotY:Number, rotZ:Number, posX:Number, posY:Number, posZ:Number):void {
				var rotation:Vector3D = new Vector3D(rotX, rotY, rotZ);
				var position:Vector3D = new Vector3D(posX, posY, posZ);
				UserInputSignals.USER_HAS_UPDATE_STATE.dispatch(userid, rotation,position);
			});
			connection.addMessageHandler("PlayerHasMoved", function(m:Message, userid:String, keyCode:uint, timestamp:Number):void {
				//if (userid != "user_" + _socialUser.social_id) {
					UserInputSignals.USER_HAS_MOVED.dispatch(userid, keyCode,timestamp);
				//}
			});
			connection.addMessageHandler("PlayerHasStoppedMoving", function(m:Message, userid:String, keyCode:uint):void {
				//if (userid != "user_" + _socialUser.social_id) {
					UserInputSignals.USER_HAS_STOPPED_MOVING.dispatch(userid, keyCode);
				//}
			});
			
			
			
			//Add message listener for users leaving the room
			connection.addMessageHandler("UserLeft", function(m:Message, userid:String):void{
				trace("Player with the userid", userid, "just left the room");
				MultiplayerSignals.USER_REMOVED.dispatch(userid);
			});
			
			//Listen to all messages using a private function
			//connection.addMessageHandler("*", handleMessages);
		}
		
		private function handleMessages(m:Message):void{
			trace("Recived the message", m)
		}
		
		private function handleDisconnect():void{
			trace("Disconnected from server")
		}
		
		private function handleError(error:PlayerIOError):void{
			trace("got", error);
		}
		
	}

}