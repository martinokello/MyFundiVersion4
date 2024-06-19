using System;
using Twitter;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;

namespace MartinLayooInc.SocialMedia
{
    public class TwitterProfileFeed<T> where T : WidgetGroupItemList, new()
    {       //Holds url of Widget setup config
        private String Setup_Url;
        //Holds xslt for widget display
        private String Html_Url;

        //Holds xslt for error display on service not available.
        private String ErrorHtml_Url;

        private String Profile_Url;


        private string TwitterStatusBaseUrl = "https://api.twitter.com/1.1/statuses/user_timeline.json?";
        private string TwitterHomeBaseurl = "https://api.twitter.com/1.1/statuses/home_timeline.json?";
        //parameters
        //"include_entities=true&include_rts=true&screen_name=jordanharold&count=2"
        
        public IConfiguration TwitterProfileFiguration { get; set; }
        public async Task<T> GetFeeds()
        {
            var result = new T();

            var widgetControl = new TwitterFeedsManipulator<WidgetGroupItemList>(new GroupObject()
            {
                GroupActionUrl = TwitterProfileFiguration.GetSection("GroupActionUrl").Value,
                GroupHeaderText = TwitterProfileFiguration.GetSection("GroupHeaderText").Value,
                CacheKey = TwitterProfileFiguration.GetSection("cachKey").Value,
                CacheTimeInSeconds = TwitterProfileFiguration.GetSection("cacheTimeSecs").Value.ToString(),
                PageSize = TwitterProfileFiguration.GetSection("PageSize").Value,
                GroupActionText = TwitterProfileFiguration.GetSection("GroupActionText").Value
            });

            var oauthAthentication = new OauthAuthentication
            {
                ConsumerKey = TwitterProfileFiguration.GetSection("OauthConsumerKey").Value,
                ConsumerSecret = TwitterProfileFiguration.GetSection("OauthConsumerSecret").Value,
                TokenKey = TwitterProfileFiguration.GetSection("OauthToken").Value,
                TokenSecret = TwitterProfileFiguration.GetSection("OauthTokenSecret").Value
            };

            result = default(T);

            string profileTweetUrl = TwitterStatusBaseUrl +
                                       string.Format(
                                           "include_entities={0}&include_rts={1}&screen_name={2}&count={3}",
                                           true, true, TwitterProfileFiguration.GetSection("TwitterProfile").Value, TwitterProfileFiguration.GetSection("PageSize").Value);

            result = await (widgetControl.GetProfileTwitterFeeds(profileTweetUrl, oauthAthentication) as Task<T>);
            return result;
        }
    }
}