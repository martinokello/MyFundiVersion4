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

 /*       public override bool Equals(object obj)
        {
            return this.Username.ToLower().Equals(((Client)obj).Username.ToLower());
        }
        public override int GetHashCode()
        {
            return this.Username.Length;
        }*/
    }

    public class Message
    {
        public string MessageFrom { get; set; }
        public string ClientMessage { get; set; }
        public DateTime TimeSent { get; set; }
        public bool MessageWasSent { get; set; }
    }
}
