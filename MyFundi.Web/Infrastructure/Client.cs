using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.Infrastructure
{
    public class Client
    {
        public int RoomNumber { get; set; }
        public string Username { get; set; }
        public Queue<Message> Messages { get; set; }
        public DateTime TimeStarted { get; set; }
        public string ClientBooker { get; set; }
        public string CurrentMessage { get; set; }
        public bool RemoveFromRoom { get; set; }
    }

    public class Message
    {
        public string ClientMessage { get; set; }
        public DateTime TimeSent { get; set; }
        public bool MessageWasSent { get; set; }
    }
}
