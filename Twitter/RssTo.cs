using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Twitter
{
    public class RssTo
    {
        public string Title { get; set; }
        public string Link { get; set; }
        public string Description { get; set; }
        public IList<Item> Items{get;set;} 
    }

    public class Item
    {
        public string Title { get; set; }
        public string Link { get; set; }
        public string Description { get; set; }
    }
}
