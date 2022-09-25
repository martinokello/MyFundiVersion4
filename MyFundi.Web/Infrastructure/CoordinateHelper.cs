using MyFundi.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyFundi.Web.Infrastructure
{
    public class CoordinateHelper
    {
        public static DistanceApartModel ArePointsNear(CoordinateViewModel checkPoint, CoordinateViewModel centerPoint, float km)
        {
            var ky = 40000 / 360;
            var kx = Math.Cos(Math.PI * ((double)centerPoint.Latitude) / 180.0) * ky;
            var dx = Math.Abs(((double)centerPoint.Longitude) - ((double)checkPoint.Longitude)) * kx;
            var dy = Math.Abs(((double)centerPoint.Latitude) - ((double)checkPoint.Latitude)) * ky;
            double dist = Math.Sqrt(dx * dx + dy * dy);
            var distApart = dist <= km;

            return new DistanceApartModel { DistanceApart = (decimal)Math.Round(dist,2), IsWithinDistance = distApart };
        }
    }
}
