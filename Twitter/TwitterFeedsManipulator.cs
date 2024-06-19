using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;
using System.Xml.Linq;
using Newtonsoft.Json;

namespace Twitter
{
    public enum OAuthSocialNetwork { Twitter, LinkedIn, FaceBook }
    public class TwitterFeedsManipulator<T> where T : WidgetGroupItemList, new()
    {
        private T WidgetGroupItems;
        private string _groupActionText;
        private string _groupActionUrl;
        private string _groupHeaderText;
        private string _cacheKey;
        private string _cacheTimeSecs;

        public TwitterFeedsManipulator(GroupObject twitterConfig)
        {
            _groupActionText = twitterConfig.GroupActionText;
            _groupActionUrl = twitterConfig.GroupActionUrl;
            _groupHeaderText = twitterConfig.GroupHeaderText;
            _cacheKey = twitterConfig.CacheKey;
            _cacheTimeSecs = twitterConfig.CacheTimeInSeconds;
        }

        public string GetOauthTwitterToken(OauthAuthentication oauthAuthentication)
        {
            StreamReader reader = null;
            HttpWebRequest request = null;

            var oauthHeader = GetOauthHeader(oauthAuthentication, OauthHeaderType.Basic, OAuthSocialNetwork.Twitter);
            try
            {
                request = WebRequest.Create("https://api.twitter.com/oauth2/token") as HttpWebRequest;

                request.Headers.Add("Authorization", oauthHeader);
                request.Method = "POST";

                if (request != null)
                {
                    request.ContentType = "application/x-www-form-urlencoded";
                    var bytes = UTF8Encoding.ASCII.GetBytes("grant_type=client_credentials");
                    request.ContentLength = bytes.Length;
                    request.GetRequestStream().Write(bytes, 0, bytes.Length);

                    using (var response = request.GetResponse() as HttpWebResponse)
                    {
                        using (Stream respStream = response.GetResponseStream())
                        {
                            if (respStream != null)
                            {
                                reader = new StreamReader(respStream);

                                string xmlString = reader.ReadToEnd();
                                reader.Close();
                                var tokenResult = xmlString.Split(new char[] { ',' });
                                if (tokenResult[0].Contains("bearer"))
                                    return tokenResult[1].Split(new char[] { ':' })[1].Split(new char[] { '}', '"' }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
                                else return tokenResult[0].Split(new char[] { ':' })[1].Split(new char[] { '}', '"' }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
                            }
                        }
                    }
                }
                return null;
            }
            catch (Exception e)
            {
                if (reader != null)
                    reader.Close();
                throw e;
            }
        }

        public void GetOauthLinkedInToken(OauthAuthentication oauthAuthentication)
        {
            StreamReader reader = null;
            HttpWebRequest request = null;

            //var oauthHeader = GetOauthHeader(oauthAuthentication, OauthHeaderType.Basic, OAuthSocialNetwork.LinkedIn);
            try
            {
                request = WebRequest.Create(string.Format("https://www.linkedin.com/uas/oauth2/authorization?response_type=code&client_id={0}&redirect_uri={1}&scope=r_fullprofile&state=MezZanillionsxein2859", oauthAuthentication.ConsumerKey, "http%3A%2F%2Fmartinlayooinc.test.uk/auth%2Flinkedin%2Fcallback")) as HttpWebRequest;

                //request.Headers.Add("Authorization", oauthHeader);
                request.Method = "GET";

                if (request != null)
                {
                    using (var response = request.GetResponse() as HttpWebResponse)
                    {
                        using (Stream respStream = response.GetResponseStream())
                        {
                            if (respStream != null)
                            {
                                reader = new StreamReader(respStream);

                                string xmlString = reader.ReadToEnd();
                                reader.Close();
                                var tokenResult = xmlString.Split(new char[] { '&' });
                                if (tokenResult.Contains("code"))
                                {
                                    var resultCode = tokenResult.Where(p => p.StartsWith("code")).SingleOrDefault();
                                    if (!string.IsNullOrEmpty(resultCode))
                                    {
                                        oauthAuthentication.TokenKey = resultCode.Split('=')[1];
                                    }
                                    /* 
                                     var resultState = tokenResult.Where(p => p.StartsWith("state")).SingleOrDefault();
                                     if (!string.IsNullOrEmpty(resultCode))
                                     {
                                         oauthAuthentication.TokenSecret = resultTokenSecret.Split('=')[1];
                                     }*/
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                if (reader != null)
                    reader.Close();
                throw e;
            }
            HttpContext.Current.Session["OAuthAuthentication"] = oauthAuthentication;
        }

        private string GetLinkedInAccessToken(OauthAuthentication oauthAuthentication)
        {
            StreamReader reader = null;
            HttpWebRequest request = null;

            try
            {
                request = WebRequest.Create("https://api.linkedin.com/uas/oauth/accessToken") as HttpWebRequest;

                request.Method = "POST";

                if (request != null)
                {
                    request.ContentType = "application/x-www-form-urlencoded";
                    var bytes = UTF8Encoding.ASCII.GetBytes(string.Format("grant_type=authorization_code&redirect_uri={0}&client_id={1}&client_secret={2}&code={3}", "http%3A%2F%2Flocalhost%2Fmartinchaos%2Home%AboutUs", oauthAuthentication.ConsumerKey, oauthAuthentication.TokenSecret, oauthAuthentication.TokenKey));
                    request.ContentLength = bytes.Length;
                    request.GetRequestStream().Write(bytes, 0, bytes.Length);

                    using (var response = request.GetResponse() as HttpWebResponse)
                    {
                        using (Stream respStream = response.GetResponseStream())
                        {
                            if (respStream != null)
                            {
                                reader = new StreamReader(respStream);

                                string jsonString = reader.ReadToEnd();
                                //jsonString ==> {"access_token":xxx, "expires_in":xxx}
                                reader.Close();
                                var tokenResult = jsonString.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0];
                                var accessToken = tokenResult.Split(new char[] { '{', '}', ':' }, StringSplitOptions.RemoveEmptyEntries)[1];
                                return accessToken;
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                if (reader != null)
                    reader.Close();
                throw e;
            }
            return string.Empty;
        }
        public async Task<T> GetLinkedInFeeds(string linkedInGetPostsUrl, OauthAuthentication oauthAuthentication)
        {
            //Using Linked Oauth: http://www.codeproject.com/Articles/247336/Twitter-OAuth-authentication-using-Net

            if (HttpContext.Current.Session["OAuthAuthentication"] == null)
            {
                GetOauthLinkedInToken(oauthAuthentication);
            }
            else
            {
                var queries = HttpContext.Current.Request.QueryString;
                var code = queries.GetValues("code").FirstOrDefault();

                if (!string.IsNullOrEmpty(code))
                {
                    var oauthUnit = HttpContext.Current.Session["OAuthAuthentication"] as OauthAuthentication;
                    oauthUnit.TokenKey = code;

                    var accessToken = GetLinkedInAccessToken(oauthUnit);
                    
                    var oauthHeader = GetOauthHeader(OauthHeaderType.Bearer, accessToken, OAuthSocialNetwork.LinkedIn);
                    Func<XDocument, IEnumerable<TweetObject>> resolveXml = GetLinkedInFeedsFromXdoc;
                    return await MakeGetHttpRequest(linkedInGetPostsUrl, resolveXml, oauthHeader);
                }
            }

            return new T();
        }

        public async Task<T> GetProfileTwitterFeeds(string twitterProfileUrl, OauthAuthentication oauthAuthentication)
        {
            //Using Twitter Oauth: http://www.codeproject.com/Articles/247336/Twitter-OAuth-authentication-using-Net

            var oauthToken = GetOauthTwitterToken(oauthAuthentication);
            var oauthHeader = GetOauthHeader(OauthHeaderType.Bearer, oauthToken, OAuthSocialNetwork.Twitter);
            Func<XDocument, IEnumerable<TweetObject>> resolveXml = GetTweetFeedsFromXdoc;
            return await MakeGetHttpRequest(twitterProfileUrl, resolveXml, oauthHeader);
        }

        private async Task<T> MakeGetHttpRequest(string requestUrl, Func<XDocument, IEnumerable<TweetObject>> resolveXml, params string[] dependencies)
        {
            var network = (requestUrl.ToLower().Contains("twitter")
                ? OAuthSocialNetwork.Twitter
                : requestUrl.ToLower().Contains("linkedin") ? OAuthSocialNetwork.LinkedIn : OAuthSocialNetwork.FaceBook);

            StreamReader reader = null;
            var oauthHeader = string.Empty;

            if (dependencies != null && dependencies.Any())
            {
                oauthHeader = dependencies.FirstOrDefault();
            }
            ServicePointManager.Expect100Continue = false;

            try
            {
                HttpWebRequest request = null;

                request = WebRequest.Create(requestUrl) as HttpWebRequest;

                if (request != null)
                {
                    if (dependencies.Any())
                        request.Headers.Add("Authorization", oauthHeader);
                    request.Method = "GET";
                    request.ContentType = "application/x-www-form-urlencoded";

                    using (var response = request.GetResponse() as HttpWebResponse)
                    {
                        using (Stream respStream = response.GetResponseStream())
                        {
                            if (respStream != null)
                            {
                                reader = new StreamReader(respStream);

                                string xmlString = reader.ReadToEnd();
                                reader.Close();
                                Func<string, Func<XDocument, IEnumerable<TweetObject>>, OAuthSocialNetwork, T> convertRequestToObjects = GetSocalMediaFeedsFromXdoc;
                                return await Task.FromResult(convertRequestToObjects.Invoke(xmlString, resolveXml, network));
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                if (reader != null)
                    reader.Close();
                throw e;
            }
            return null;
        }
        public T GetSearchTwitterFeeds(string twitterSearchUrl, OauthAuthentication oauthAuthentication)
        {
            //Using Twitter Oauth: http://www.codeproject.com/Articles/247336/Twitter-OAuth-authentication-using-Net
            //this.WidgetGroupItems = Cache[cacheKey] as WidgetGroupItemList;

            var oauthToken = GetOauthTwitterToken(oauthAuthentication);
            var oauthHeader = GetOauthHeader(OauthHeaderType.Bearer, oauthToken, OAuthSocialNetwork.Twitter);
            StreamReader reader = null;

            ServicePointManager.Expect100Continue = false;

            try
            {
                HttpWebRequest request = null;

                request = WebRequest.Create(twitterSearchUrl) as HttpWebRequest;

                if (request != null)
                {

                    request.Headers.Add("Authorization", oauthHeader);
                    request.Method = "GET";
                    request.ContentType = "application/x-www-form-urlencoded";

                    using (var response = request.GetResponse() as HttpWebResponse)
                    {
                        using (Stream respStream = response.GetResponseStream())
                        {
                            if (respStream != null)
                            {
                                reader = new StreamReader(respStream);

                                string xmlString = reader.ReadToEnd();
                                reader.Close();
                                return ConvertRawSearchTweetsToXmlConsumables(xmlString);
                            }
                        }
                    }
                }
                return new T();
            }
            catch (Exception e)
            {
                if (reader != null)
                    reader.Close();
                throw e;
            }
        }
        public enum OauthHeaderType { Basic = 0, Bearer = 1 }

        private string GetOauthHeader(OauthAuthentication oauthentication, OauthHeaderType oauthHeaderType,
            OAuthSocialNetwork network)
        {

            var oauth_version = "1.0";
            var oauth_signature_method = "HMAC-SHA1";
            var oauth_nonce = Convert.ToBase64String(new ASCIIEncoding().GetBytes(DateTime.Now.Ticks.ToString()));

            var timeSpan = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0,
                DateTimeKind.Utc);
            var oauth_timestamp = Convert.ToInt64(timeSpan.TotalSeconds).ToString();

            var baseFormat = string.Empty;
            var baseString = string.Empty;

            if (network.Equals(OAuthSocialNetwork.Twitter))
            {
                baseFormat = "oauth_consumer_key={0}&oauth_nonce={1}&oauth_signature_method={2}" +
                             "&oauth_timestamp={3}&oauth_token={4}&oauth_version={5}";
                baseString = string.Format(baseFormat,
                                        oauthentication.ConsumerKey,
                                        oauth_nonce,
                                        oauth_signature_method,
                                        oauth_timestamp,
                                        oauthentication.TokenKey,
                                        oauth_version
                                        );
            }
           /* else if (network.Equals(OAuthSocialNetwork.LinkedIn))
            {
                baseFormat = "oauth_consumer_key={0}&oauth_nonce={1}&oauth_signature_method={2}" +
                             "&oauth_timestamp={3}&oauth_callback={4}&oauth_version={5}&client_id={6}&redirect_uri={7}&scope=r_fullprofile%20w_share&state=MezZanillionsxein2859";
                baseString = string.Format(baseFormat,
                                         oauthentication.ConsumerKey,
                                         oauth_nonce,
                                         oauth_signature_method,
                                         oauth_timestamp,
                                        HttpContext.Current.Request.Url.AbsoluteUri,
                                         oauth_version,
                                         oauthentication.ClientAppId,
                                         HttpContext.Current.Request.Url.AbsoluteUri
                                         );
            }

    */

            var compositeKey = string.Concat(Uri.EscapeDataString(oauthentication.ConsumerSecret),
                        "&", Uri.EscapeDataString(oauthentication.TokenSecret));

            string oauth_signature;

            using (HMACSHA1 hasher = new HMACSHA1(ASCIIEncoding.ASCII.GetBytes(compositeKey)))
            {
                oauth_signature = Convert.ToBase64String(
                    hasher.ComputeHash(ASCIIEncoding.ASCII.GetBytes(baseString)));
            }

            var headerFormat = oauthentication.ConsumerKey + ":" + oauthentication.ConsumerSecret;
            headerFormat = Convert.ToBase64String(ASCIIEncoding.UTF8.GetBytes(headerFormat));

            return oauthHeaderType.ToString() + " " + headerFormat;
        }


        private string GetOauthHeader(OauthHeaderType oauthHeaderType, string bearerToken, OAuthSocialNetwork network)
        {
            switch (network)
            {
                case OAuthSocialNetwork.Twitter:
                case OAuthSocialNetwork.LinkedIn:
                    return oauthHeaderType.ToString() + " " + bearerToken;
                case OAuthSocialNetwork.FaceBook:
                    return string.Empty;
                default:
                    return oauthHeaderType.ToString() + " " + bearerToken;
            }
        }

        public class TweetObject
        {
            public string AvatarUrl { get; set; }
            public string Tweet { get; set; }
            public string StatusId { get; set; }
            public string TimeCreated { get; set; }
            public string Username { get; set; }
            public string GroupUrl { get; set; }
            public string MediaUrl { get; set; }
            public string MediaSizeX { get; set; }
            public string MediaSizeY { get; set; }
            public string MediaType { get; set; }
        }
        private IEnumerable<TweetObject> GetLinkedInFeedsFromXdoc(XDocument xdoc)
        {
            var tweetResults = from tweets in xdoc.Descendants("person")
                               select new TweetObject
                               {
                                   Tweet = tweets.Element("current-status").Value,
                                   AvatarUrl = tweets.Element("picture-url").Value,
                                   Username = "Martin Alex Okello",
                                   StatusId = tweets.Element("headline").Value,
                                   TimeCreated = tweets.Element("current-status-timestamp").Value,
                                   GroupUrl = tweets.Descendants("api-standard-profile-request").Any() && tweets.Descendants("api-standard-profile-request").FirstOrDefault().Descendants("url").Any() ? tweets.Descendants("api-standard-profile-request").FirstOrDefault().Descendants("url").FirstOrDefault().Value : "http://www.martinlayooinc.com",
                                   MediaUrl = tweets.Descendants("member-url-resources").Any() && tweets.Descendants("member-url-resources").FirstOrDefault().Descendants("url").Any() ? tweets.Descendants("member-url-resources").FirstOrDefault().Descendants("url").FirstOrDefault().Value : "",
                                   MediaSizeX = "300px"
                               };
            return tweetResults;
        }

        private IEnumerable<TweetObject> GetTweetFeedsFromXdoc(XDocument xdoc)
        {
            var tweetResults = from tweets in xdoc.Descendants("status")
                               select new TweetObject
                               {
                                   Tweet = tweets.Element("text").Value,
                                   AvatarUrl =
                        tweets.Element("user").Element("profile_image_url").Value,
                                   Username =
                        tweets.Element("user").Element("screen_name").Value,
                                   StatusId = tweets.Element("id_str").Value,
                                   TimeCreated = tweets.Element("created_at").Value,
                                   GroupUrl = tweets.Element("entities").Element("urls") != null ? tweets.Element("entities").Element("urls").Element("url").Value : "http://www.martinlayooinc.com",
                                   MediaUrl = tweets.Descendants("media").Any() && tweets.Descendants("media").FirstOrDefault().Descendants("media_url").Any() ? tweets.Descendants("media").FirstOrDefault().Descendants("media_url").FirstOrDefault().Value : "",
                                   MediaType = tweets.Descendants("media").Any() && tweets.Descendants("media").FirstOrDefault().Descendants("type").Any() ? tweets.Descendants("media").FirstOrDefault().Descendants("type").FirstOrDefault().Value : "",
                                   MediaSizeX = tweets.Descendants("media").Any() && tweets.Descendants("media").FirstOrDefault().Descendants("sizes").Any() ? tweets.Descendants("media").FirstOrDefault().Descendants("sizes").FirstOrDefault().Descendants("small").FirstOrDefault().Descendants("w").FirstOrDefault().Value : "",
                                   MediaSizeY = tweets.Descendants("media").Any() && tweets.Descendants("media").FirstOrDefault().Descendants("sizes").Any() ? tweets.Descendants("media").FirstOrDefault().Descendants("sizes").FirstOrDefault().Descendants("small").FirstOrDefault().Descendants("h").FirstOrDefault().Value : ""
                               };
            return tweetResults;
        }

        private void GetTimeSinceTweeted(TimeSpan period, out string timeSince)
        {
            string timePeriod = string.Empty;

            if (period.Days > 0)
            {
                timePeriod = period.Days.ToString();

                if (period.Days == 1)
                    timeSince = string.Format("{0} day ago", timePeriod);
                else timeSince = string.Format("{0} days ago", timePeriod);
            }
            else if (period.Hours > 0)
            {
                timePeriod = period.Hours.ToString();
                if (period.Hours == 1)
                    timeSince = string.Format("{0} hour ago", timePeriod);
                else timeSince = string.Format("{0} hours ago", timePeriod);
            }
            else if (period.Minutes > 0)
            {
                timePeriod = period.Minutes.ToString();
                if (period.Minutes == 1)
                    timeSince = string.Format("{0} minute ago", timePeriod);
                else timeSince = string.Format("{0} minutes ago", timePeriod);
            }
            else
            {
                timePeriod = period.Seconds.ToString();
                if (period.Seconds == 1)
                    timeSince = string.Format("{0} second ago", timePeriod);
                else timeSince = string.Format("{0} seconds ago", timePeriod);
            }
        }

        private T GetSocalMediaFeedsFromXdoc(string jsonString,
            Func<XDocument, IEnumerable<TweetObject>> socialMediaFeedsFromXml, OAuthSocialNetwork network)
        {
            // To convert JSON text contained in string json into an XML node
            WidgetGroupItems = new T();

            dynamic xmldoc = string.Empty;

            if (network.Equals(OAuthSocialNetwork.Twitter))
            {
                xmldoc = JsonConvert.DeserializeXNode("{\"status\":" + jsonString + "}", "root");
            }
            else if (network.Equals(OAuthSocialNetwork.LinkedIn))
            {
                xmldoc = JsonConvert.DeserializeXNode("jsonString");
            }

            var ProfileTweets = socialMediaFeedsFromXml.Invoke(xmldoc);

            foreach (var profileTweet in ProfileTweets)
            {
                var dateCreated = profileTweet.TimeCreated;
                string[] timeComponents = dateCreated.Split(new char[] { '+' }, StringSplitOptions.RemoveEmptyEntries);
                var dateComponents = timeComponents[0].Split(new char[] { ' ', ',' }, StringSplitOptions.RemoveEmptyEntries);
                var year = timeComponents[1].Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)[1];
                dateCreated = string.Concat(dateComponents[0].Trim(), " ", dateComponents[1], " ", dateComponents[2], " ", dateComponents[3], " ", year);

                string timeSince = string.Empty;
                try
                {
                    DateTime createdDate = DateTime.ParseExact(dateCreated, "ddd MMM dd HH:mm:ss yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None);
                    DateTime current = DateTime.Now;

                    TimeSpan period = current - createdDate;

                    GetTimeSinceTweeted(period, out timeSince);
                }
                catch (Exception e)
                {
                    return default(T);
                }

                WidgetGroupItems.Add(new GroupObject { GroupActionText = _groupActionText, GroupActionUrl = _groupActionUrl, GroupDescription = AddColourToTwitterKnownWords(profileTweet.Tweet), GroupAvatarUrl = profileTweet.AvatarUrl, GroupId = -1, GroupHeaderText = _groupHeaderText, GroupUrl = profileTweet.GroupUrl, Username = profileTweet.Username, Duration = timeSince, TweetStatusId = profileTweet.StatusId, MediaUrl = profileTweet.MediaUrl, MediaSizeX = profileTweet.MediaSizeX, MediaSizeY = profileTweet.MediaSizeY, MediaType = profileTweet.MediaType });
            }


            //int cacheTime = 180;
            //Int32.TryParse(cacheTimeSecs, out cacheTime);
            //Cache.Insert(cacheKey, WidgetGroupItems, null, DateTime.UtcNow.AddSeconds(cacheTime), System.Web.Caching.Cache.NoSlidingExpiration);
            //return WidgetGroupItems.ToSerializerXml();
            return WidgetGroupItems;
        }
        private T GenerateWidgetItems(IEnumerable<TweetObject> profileTweets, int pageSize)
        {
            int tweetIndex = 0;
            var gotLastId = false;

            if (profileTweets.Count() == 0) throw new Exception("There are no results for the search criteria!");

            foreach (var searchedTweet in profileTweets)
            {
                //dateFormat: Wed, 19 Jan 2011 21:16:37 +0000"

                string dateCreated = searchedTweet.TimeCreated;
                string[] timeComponents = dateCreated.Split(new char[] { '+' }, StringSplitOptions.RemoveEmptyEntries);
                var dateComponents = timeComponents[0].Split(new char[] { ' ', ',' }, StringSplitOptions.RemoveEmptyEntries);
                var year = timeComponents[1].Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)[1];
                dateCreated = string.Concat(dateComponents[0].Trim(), " ", dateComponents[1], " ", dateComponents[2], " ", dateComponents[3], " ", year);

                string timeSince = string.Empty;
                try
                {
                    DateTime createdDate = DateTime.ParseExact(dateCreated, "ddd MMM dd HH:mm:ss yyyy", CultureInfo.InvariantCulture, DateTimeStyles.None);
                    DateTime current = DateTime.Now;

                    TimeSpan period = current - createdDate;

                    GetTimeSinceTweeted(period, out timeSince);
                }
                catch (Exception e)
                {

                }
                WidgetGroupItems.Add(new GroupObject { GroupActionText = _groupActionText, GroupActionUrl = _groupActionUrl, GroupDescription = AddColourToTwitterKnownWords(searchedTweet.Tweet), GroupAvatarUrl = searchedTweet.AvatarUrl, GroupId = -1, GroupHeaderText = _groupHeaderText, GroupUrl = searchedTweet.GroupUrl, Username = searchedTweet.Username, Duration = timeSince, TweetStatusId = searchedTweet.StatusId });
                tweetIndex++;

                if (tweetIndex > pageSize - 1)
                {
                    long lastResultId = -1;

                    long.TryParse(WidgetGroupItems[WidgetGroupItems.Count - 1].TweetStatusId, out lastResultId);
                    if (lastResultId > 0)
                    {
                        //Application["LastResultId"] = lastResultId;
                    }
                    gotLastId = true;
                    break;
                }
            }
            if (!gotLastId)
            {
                long lastResultId = -1;

                long.TryParse(WidgetGroupItems[WidgetGroupItems.Count - 1].TweetStatusId, out lastResultId);
                if (lastResultId > 0)
                {
                    //Application["LastResultId"] = lastResultId;
                }
            }
            return WidgetGroupItems;
        }
        private T ConvertRawSearchTweetsToXmlConsumables(string jsonString)
        {
            // To convert JSON text contained in string json into an XML node
            WidgetGroupItems = new T();
            var xmldoc = JsonConvert.DeserializeXNode("{\"status\":" + jsonString + "}", "root");


            var searchTweets = from tweets in xmldoc.Descendants("statuses")
                                select new
                                {
                                    Tweet = tweets.Element("text").Value,
                                    AvatarUrl =
                         tweets.Element("user").Descendants("profile_image_url").SingleOrDefault().Value,
                                    Username =
                         tweets.Element("user").Descendants("screen_name").SingleOrDefault().Value,
                                    TweetStatusId = tweets.Element("id").Value
                                };
            foreach (var searchTweet in searchTweets)
            {
                WidgetGroupItems.Add(new GroupObject { GroupActionText = _groupActionText, GroupActionUrl = _groupActionUrl, GroupDescription = AddColourToTwitterKnownWords(searchTweet.Tweet), GroupAvatarUrl = searchTweet.AvatarUrl, GroupId = -1, GroupHeaderText = _groupHeaderText, GroupUrl = _groupActionUrl, Username = searchTweet.Username, TweetStatusId = searchTweet.TweetStatusId });
            }


            //int cacheTime = 180;
            //Int32.TryParse(cacheTimeSecs, out cacheTime);
            //Cache.Insert(cacheKey, WidgetGroupItems, null, DateTime.UtcNow.AddSeconds(cacheTime), System.Web.Caching.Cache.NoSlidingExpiration);
            return WidgetGroupItems;
        }
        private string AddColourToTwitterKnownWords(string sentence)
        {
            var pattern = @"((?:http://|www\.)\S+\b)|(?:\@\S+)|(?:\#\S+)|((?:https://|www\.)\S+\b)|(?:\@\S+)|(?:\#\S+)";

            string wrapper = @"<span class='greentext'>{0}</span>";
            string linkWrapper = @"<a class='greentext' href='{0}' target='_blank'>{0}</a>";
            MatchCollection collection = Regex.Matches(sentence, pattern);
            foreach (Match match in collection)
            {
                string value = match.Value;

                string wrappedText = string.Empty;
                if (value.Trim().StartsWith("http://", StringComparison.OrdinalIgnoreCase) || value.Trim().StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                {
                    wrappedText = string.Format(linkWrapper, value);
                }
                else
                {
                    wrappedText = string.Format(wrapper, value);
                }

                sentence = sentence.Replace(value, wrappedText);
            }
            return sentence;
        }

    }
}
