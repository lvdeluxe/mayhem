using System;
using System.Collections.Generic;
using System.Drawing;
using PlayerIO.GameLibrary;
using System.Text;

namespace MyGame {

	public class Player : BasePlayer {
		public string Name;
        public int UserIndex;
        public int XP;
        public uint VehicleId;
        public uint TextureId;
        public Byte[] RigidBodyDescription;
	}

	[RoomType("OfficeMayhem")]
	public class GameCode : Game<Player> {

        private Dictionary<string, Player> allUsers;
        private Dictionary<string, Player> allAICubes;
        private int maxPerRoom = 12;


		// This method is called when an instance of your the game is created
		public override void GameStarted() {
            allUsers = new Dictionary<string, Player>();
            allAICubes = new Dictionary<string, Player>();
            
            for (int i = 0; i < maxPerRoom; i++)
            {
                allAICubes["ai_" + allAICubes.Count.ToString()] = GetAICube(i);
            }

            Console.WriteLine("Game is started: " + RoomId);

			// This is how you setup a timer
            //AddTimer(delegate {
            //    // code here will code every 100th millisecond (ten times a second)
            //}, 100);
			
			// Debug Example:
			// Sometimes, it can be very usefull to have a graphical representation
			// of the state of your game.
			// An easy way to accomplish this is to setup a timer to update the
			// debug view every 250th second (4 times a second).
            //AddTimer(delegate {
            //    // This will cause the GenerateDebugImage() method to be called
            //    // so you can draw a grapical version of the game state.
            //    RefreshDebugView(); 
            //}, 250);
		}

		// This method is called when the last player leaves the room, and it's closed down.
		public override void GameClosed() {
			Console.WriteLine("RoomId: " + RoomId);
		}

		// This method is called whenever a player joins the game
		public override void UserJoined(Player player) {

            if (allUsers.ContainsKey(player.ConnectUserId))
            {
                Console.WriteLine("User already in the game");
                return;
            }

            PlayerIO.BigDB.Load("PlayerObjects", player.ConnectUserId, delegate(DatabaseObject userInfo)
            {
                //if (!userInfo.Contains("username"))
                //{
                //    //Empty object, initialize it
                //    userInfo.Set("username", player.JoinData["name"]);
                //    userInfo.Set("xp", 0);
                    
                //}else{
                //    player.XP = userInfo.GetInt("xp");
                //}
                userInfo.Set("vehicleId", player.JoinData["vehicleId"]);
                userInfo.Set("textureId", player.JoinData["textureId"]);
                userInfo.Save();

                Console.WriteLine("userId: " + player.ConnectUserId);
                player.UserIndex = allUsers.Count;
                player.TextureId = Convert.ToUInt32(player.JoinData["textureId"]);
                player.VehicleId = Convert.ToUInt32(player.JoinData["vehicleId"]);
                Console.WriteLine(player.TextureId); ;
                Console.WriteLine(player.JoinData["textureId"]); ;
                allUsers.Add(player.ConnectUserId, player);
                allAICubes.Remove("ai_" + player.UserIndex.ToString());
                player.PayVault.Refresh(delegate()
                {
                    Broadcast("UserJoined", player.ConnectUserId, player.UserIndex, player.XP, player.PayVault.Coins, player.VehicleId, player.TextureId);
                });
            });    
            
		}

        private Player GetAICube(int index)
        {
            Player p = new Player();
            p.Name = "ai_" + index.ToString();
            p.UserIndex = index;
            return p;
        }

		public override void UserLeft(Player player) {
            allUsers.Remove(player.ConnectUserId);
            allAICubes.Add("ai_" + player.UserIndex.ToString(), GetAICube(player.UserIndex));
            Console.WriteLine("userId left: " + player.ConnectUserId);
            Broadcast("UserLeft", player.ConnectUserId, player.UserIndex);
		}

		public override void GotMessage(Player player, Message message) {
            switch(message.Type) {
                case "GetRoomUsers":
                    Message msg = Message.Create("SetRoomUsers");
                    foreach (KeyValuePair<string, Player> plyr in allUsers)
                    {
                        if (plyr.Value.ConnectUserId != player.ConnectUserId)
                        {
                            msg.Add(plyr.Value.ConnectUserId);
                            msg.Add(plyr.Value.VehicleId);
                            msg.Add(plyr.Value.TextureId);
                            Console.WriteLine(plyr.Value.TextureId);
                            msg.Add(plyr.Value.RigidBodyDescription);
                        }
                    }
                    player.Send(msg);
                    break;
                case "PlayerStoppedMoving":
                    Broadcast("PlayerHasStoppedMoving", player.ConnectUserId, message.GetUInt(0), message.GetDouble(1));
                    break;
                case "AIUpdateState":
                    Byte[] AIByteArray = message.GetByteArray(0);
                    Broadcast("AIHasStateUpdate", AIByteArray);
                    break;
                case "PlayerUpdateState":                   
                    Byte[] byteArray = message.GetByteArray(0);
                    player.RigidBodyDescription = byteArray;
                    Broadcast("PlayerHasStateUpdate", player.ConnectUserId, byteArray);
                    break;
                case "PlayerIsMoving":
                    Broadcast("PlayerHasMoved",player.ConnectUserId, message.GetUInt(0), message.GetDouble(1));
                    break;
                case "PlayerIsColliding":
                    Byte[] collisionByteArray = message.GetByteArray(0);
                    Broadcast("PlayerHasCollided", collisionByteArray);
                    break;
                case "PowerUpTrigger":
                    Console.WriteLine("PowerUpTrigger");
                    Byte[] pUpByteArray = message.GetByteArray(0);
                    Broadcast("PowerUpTriggered", pUpByteArray);
                    break;
                case "UserSessionExpire":
                    Byte[] statsBytes = message.GetByteArray(0);
                    int uidLength = statsBytes[1];
                    int readStart = 2;
                    int offset = 4;
                    string uid = Encoding.UTF8.GetString(statsBytes, readStart, uidLength);
                    Console.WriteLine((readStart + uidLength + 1).ToString());
                    int index = readStart + uidLength;

                    int CurrentKillsReceived = byteArrayToInt(statsBytes, index);
                    index += offset;
                    int CurrentKillsInflicted = byteArrayToInt(statsBytes, index);
                    index += offset;
                    int CurrentHitsReceived = byteArrayToInt(statsBytes, index);
                    index += offset;
                    int CurrentHitsInflicted = byteArrayToInt(statsBytes, index);
                    index += offset;
                    int CurrentFelt = byteArrayToInt(statsBytes, index);
                    index += offset;
                    int CurrentMaxSpeed = byteArrayToInt(statsBytes, index);

                    PlayerIO.BigDB.LoadOrCreate("UserStats", uid, delegate(DatabaseObject statsInfo)
                    {
                        object obj = new object();
                        if (statsInfo.TryGetValue("AllTimeKillsReceived", out obj))
                        {
                            //Empty object, initialize it
                            int AllTimeKillsReceived = statsInfo.GetInt("AllTimeKillsReceived");
                            statsInfo.Set("AllTimeKillsReceived", AllTimeKillsReceived + CurrentKillsReceived);
                            int AllTimeKillsInflicted = statsInfo.GetInt("AllTimeKillsInflicted");
                            statsInfo.Set("AllTimeKillsInflicted", AllTimeKillsInflicted + CurrentKillsInflicted);
                            int AllTimeHitsReceived = statsInfo.GetInt("AllTimeHitsReceived");
                            statsInfo.Set("AllTimeHitsReceived", AllTimeHitsReceived + CurrentHitsReceived);
                            int AllTimeHitsInflicted = statsInfo.GetInt("AllTimeHitsInflicted");
                            statsInfo.Set("AllTimeHitsInflicted", AllTimeHitsInflicted + CurrentHitsInflicted);
                            int AllTimeFelt = statsInfo.GetInt("AllTimeFelt");
                            statsInfo.Set("AllTimeFelt", AllTimeFelt + CurrentFelt);
                            int AllTimeMaxSpeed = statsInfo.GetInt("AllTimeMaxSpeed");
                            statsInfo.Set("AllTimeMaxSpeed", Math.Max(AllTimeMaxSpeed, CurrentMaxSpeed));
                            int AllTimeSessionsPlayed = statsInfo.GetInt("AllTimeSessionsPlayed");
                            statsInfo.Set("AllTimeSessionsPlayed", AllTimeSessionsPlayed + 1);
                        }
                        else
                        {
                            statsInfo.Set("AllTimeKillsReceived", CurrentKillsReceived);
                            statsInfo.Set("AllTimeKillsInflicted", CurrentKillsInflicted);
                            statsInfo.Set("AllTimeHitsReceived", CurrentHitsReceived);
                            statsInfo.Set("AllTimeHitsInflicted", CurrentHitsInflicted);
                            statsInfo.Set("AllTimeFelt", CurrentFelt);
                            statsInfo.Set("AllTimeMaxSpeed", CurrentMaxSpeed);
                            statsInfo.Set("AllTimeSessionsPlayed", 1);
                        }
                        player.PayVault.Credit(100, "EndSession", delegate()
                        {
                            PlayerIO.BigDB.Load("PlayerObjects", player.ConnectUserId, delegate(DatabaseObject userInfo){
                                player.XP += 5;
                                userInfo.Set("xp", player.XP);
                                userInfo.Save();
                                statsInfo.Save();
                                Broadcast("UserSessionExpired", uid, player.PayVault.Coins, player.XP);
                            });                            
                        });                        
                    });                   
                    break;
                case "UserSessionRestart":                    
                    string user_id_restart = message.GetString(0);
                    int spawnIndex_restart = message.GetInt(1);
                    Broadcast("UserSessionRestarted", user_id_restart, spawnIndex_restart);
                    break;
                case "SetAITarget":
                    string chaser_id = message.GetString(0);
                    string target_id = message.GetString(1);
                    Broadcast("AITargetUpdated", chaser_id, target_id);
                    break;
			}
		}

        int byteArrayToInt(byte[] b, int index) {
            return (b[index] << 24) + ((b[index + 1] & 0xFF) << 16) + ((b[index + 2] & 0xFF) << 8) + (b[index + 3] & 0xFF); 
        }

        System.Drawing.Point debugPoint;

		// This method get's called whenever you trigger it by calling the RefreshDebugView() method.
		public override System.Drawing.Image GenerateDebugImage() {
			// we'll just draw 400 by 400 pixels image with the current time, but you can
			// use this to visualize just about anything.
			var image = new Bitmap(400,400);
			using(var g = Graphics.FromImage(image)) {
				// fill the background
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);

				// draw the current time
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);

				// draw a dot based on the DebugPoint variable
				g.FillRectangle(Brushes.Red, debugPoint.X,debugPoint.Y,5,5);
			}
			return image;
		}

		// During development, it's very usefull to be able to cause certain events
		// to occur in your serverside code. If you create a public method with no
		// arguments and add a [DebugAction] attribute like we've down below, a button
		// will be added to the development server. 
		// Whenever you click the button, your code will run.
		[DebugAction("Play", DebugAction.Icon.Play)]
		public void PlayNow() {
			Console.WriteLine("The Jouer button was clicked!");
		}

		// If you use the [DebugAction] attribute on a method with
		// two int arguments, the action will be triggered via the
		// debug view when you click the debug view on a running game.
		[DebugAction("Set Debug Point", DebugAction.Icon.Green)]
		public void SetDebugPoint(int x, int y) {
            debugPoint = new System.Drawing.Point(x, y);
		}
	}
}
