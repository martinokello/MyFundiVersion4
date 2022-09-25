using Microsoft.Extensions.Configuration;
using System;

namespace MyFundi.AppConfigurations
{
    public class AppSettingsConfigurations
    {
        public AppSettingsConfigurations() { }
        public AppSettingsConfigurations(IConfiguration appSettings)
        {
            AppSettings = appSettings;
        }
        public IConfiguration AppSettings { get; set; }

        public string GetConfigSetting(string setting)
        {
            return AppSettings.GetSection(setting).Value;
        }
    }
}
