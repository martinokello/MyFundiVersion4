using MyFundi.Web.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.ViewModels
{
    public class ClientJobDistanceViewModel
    {
        public JobViewModel Job { get; set; }
        public ClientProfileViewModel Client { get; set; }
        public DistanceApartModel DistanceApart { get; set; }
    }
}
