using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;

namespace Twitter
{
    public class RssFeedsXmlParser
    {
        public int NumberOfItemsToShow { get; set; }
        public string RssTo { get; set; }

        public static RssTo ParseXml(string xml)
        {
            var xdoc = XDocument.Parse(xml);

            var rsstitle = xdoc.Root.Descendants("title").FirstOrDefault();
            var link = xdoc.Root.Descendants("link").FirstOrDefault();
            var description = xdoc.Root.Descendants("description").FirstOrDefault();

            var rssTo = new RssTo();
            rssTo.Title = rsstitle.Value;
            rssTo.Link = link.Value;
            rssTo.Description = description.Value;
            rssTo.Items = new List<Item>();

            var rssItems = xdoc.Root.Descendants("item");
            if (rssItems.Any())
            {
                foreach(var item in rssItems)
                {
                    var itemTo = new Item();
                    itemTo.Title = item.Descendants("title").FirstOrDefault().Value;
                    itemTo.Link = item.Descendants("link").FirstOrDefault().Value;
                    itemTo.Description = item.Descendants("description").FirstOrDefault().Value;
                    rssTo.Items.Add(itemTo);
                }
            }
            return rssTo;
        }
    }
}
