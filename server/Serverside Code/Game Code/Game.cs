using System;
using System.Collections.Generic;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace MyGame {
	public class Player : BasePlayer {
		public string Name;
        public Point Coords;
	}

	[RoomType("OfficeMayhem")]
	public class GameCode : Game<Player> {

        private Dictionary<string, Player> allUsers;

		// This method is called when an instance of your the game is created
		public override void GameStarted() {
            allUsers = new Dictionary<string,Player>();
			// anything you write to the Console will show up in the 
			// output window of the development server
			Console.WriteLine("Game is started: " + RoomId);

			// This is how you setup a timer
			AddTimer(delegate {
				// code here will code every 100th millisecond (ten times a second)
			}, 100);
			
			// Debug Example:
			// Sometimes, it can be very usefull to have a graphical representation
			// of the state of your game.
			// An easy way to accomplish this is to setup a timer to update the
			// debug view every 250th second (4 times a second).
			AddTimer(delegate {
				// This will cause the GenerateDebugImage() method to be called
				// so you can draw a grapical version of the game state.
				RefreshDebugView(); 
			}, 250);
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

            PlayerIO.BigDB.LoadOrCreate("PlayerObjects", player.ConnectUserId, delegate(DatabaseObject userInfo)
            {
                if (!userInfo.Contains("username"))
                {
                    //Empty object, initialize it
                    userInfo.Set("username", player.JoinData["name"]);
                }
                userInfo.Save();
            });

			// this is how you send a player a message
            Console.WriteLine("userId: " + player.ConnectUserId);

            allUsers.Add(player.ConnectUserId, player);

            Point spawnPoint = new Point();
            Random rand = new Random();
            spawnPoint.X = rand.Next(-1250, 1250);
            spawnPoint.Y = rand.Next(-1250, 1250);
            player.Coords = spawnPoint;

            Broadcast("UserJoined", player.ConnectUserId, spawnPoint.X, spawnPoint.Y);
		}

		// This method is called when a player leaves the game
		public override void UserLeft(Player player) {
            allUsers.Remove(player.ConnectUserId);
            Console.WriteLine("userId left: " + player.ConnectUserId);
            Broadcast("UserLeft", player.ConnectUserId);
		}

		// This method is called when a player sends a message into the server code
		public override void GotMessage(Player player, Message message) {
            switch(message.Type) {
                case "GetRoomUsers":
                    Message msg = Message.Create("SetRoomUsers");
                    foreach (KeyValuePair<string, Player> plyr in allUsers)
                    {
                        msg.Add(plyr.Value.ConnectUserId);
                        msg.Add(plyr.Value.Coords.X);
                        msg.Add(plyr.Value.Coords.Y);
                    }
                    player.Send(msg);
                    break;
                case "PlayerIsMoving":
                    player.Coords = new Point((int)message.GetFloat(0), (int)message.GetFloat(1));
                    Broadcast("PlayerHasMoved",player.ConnectUserId, message.GetFloat(0), message.GetFloat(1));
                    break;
			}
		}

		Point debugPoint;

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
			debugPoint = new Point(x,y);
		}
	}
}
