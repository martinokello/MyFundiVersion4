using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MyFundi.UnitOfWork.Concretes;
using MyFundi.Web.ViewModels;
using MyFundi.Domain;
using MyFundi.Services.EmailServices.Interfaces;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Twitter;
using MartinLayooInc.SocialMedia;
using SimbaToursEastAfrica.Caching;
using MyFundi.AppConfigurations;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Cors;

namespace MyFundi.Web.Controllers
{
    [EnableCors(PolicyName = "CorsPolicy")]
    public class SocialMediaController : Controller
    {
        private IConfigurationSection _applicationConstants;
        private IConfigurationSection _businessSmtpDetails;
        private IConfigurationSection _twitterProfileFiguration;
        private IMailService _emailService;
        private MyFundiUnitOfWork _unitOfWork;
        private Mapper _Mapper;

        public SocialMediaController(IMailService emailService, MyFundiUnitOfWork unitOfWork, Mapper mapper, AppSettingsConfigurations appSettings)
        {
            _applicationConstants = appSettings.AppSettings.GetSection("ApplicationConstants");
            _twitterProfileFiguration = appSettings.AppSettings.GetSection("TwitterProfileFiguration");
            _businessSmtpDetails = appSettings.AppSettings.GetSection("BusinessSmtpDetails");
            _emailService = emailService;
            _unitOfWork = unitOfWork;
            _Mapper = mapper;
        }
        // GET: Twitter Feeds   
        [HttpGet]
        public async Task<IActionResult> TwitterProfileFeeds()
        {
            try
            {
                var caching = new SimbaToursEastAfrica.Caching.Concretes.SimbaToursEastAfricaCahing();

                var twitterEngine = new TwitterProfileFeed<WidgetGroupItemList>();
                twitterEngine.TwitterProfileFiguration = _twitterProfileFiguration;
                var tweets = new WidgetGroupItemList();
                Int32.TryParse(_twitterProfileFiguration["cacheTimeSecs"], out int cacheTimeSecs);
                tweets = await caching.GetOrSaveToCache<WidgetGroupItemList>(_twitterProfileFiguration["cachKey"], cacheTimeSecs, twitterEngine.GetFeeds);

                if (tweets != null && tweets.Any())
                {
                    Ok(tweets);
                }
                else if (tweets == null || !tweets.Any())
                    tweets = new WidgetGroupItemList();
                return Ok(tweets);
            }
            catch(Exception ex)
            {
                return BadRequest(ex.Message + System.Environment.NewLine + ex.StackTrace);
            }
        }
    }
}
