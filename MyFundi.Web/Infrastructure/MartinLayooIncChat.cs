using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Collections.Generic;
using System.Web;
using MyFundi.Web.Infrastructure;

namespace MartinLayooInc.Web.Infrastructure
{
    public partial class MartinLayooIncChat
    {
        public Dictionary<int, List<Queue<Client>>> Rooms;
        public static int RoomNumber = 0;

        public MartinLayooIncChat()
        {
            Rooms = new Dictionary<int, List<Queue<Client>>>();
            var threadRoomCleaner = new ThreadStart(CleanRoom);
            var threadCleaner = new Thread(threadRoomCleaner);
            threadCleaner.IsBackground = true;
            threadCleaner.Start();
        }
       
        private void CleanRoom()
        {
            foreach (var roomKey in Rooms.Keys)
            {
                var firstClient = Rooms[roomKey].First().Dequeue();
                TimeSpan span = DateTime.Now - firstClient.TimeStarted;
                if (span.Minutes >= 30) Rooms.Remove(roomKey);
            }

            Thread.Sleep(20000);
        }

        public bool AddClientToChatRoom(Client client)
        {
            try
            {
                if (client.Messages == null) client.Messages = new Queue<Message>();
                if (Rooms.Keys.Contains(client.RoomNumber))
                {
                    Rooms[client.RoomNumber].First().Enqueue(client);
                }
                else
                {
                    RoomNumber++;
                    Rooms.Add(RoomNumber, new List<Queue<Client>>());
                    Rooms[RoomNumber].Add(new Queue<Client>());
                    client.TimeStarted = DateTime.Now;
                    client.RoomNumber = RoomNumber;
                    client.CurrentMessage = client.CurrentMessage;
                    Rooms[client.RoomNumber].First().Enqueue(client);
                }
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

    }
}