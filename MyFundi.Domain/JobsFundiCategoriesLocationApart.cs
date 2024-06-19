using System;
using System.Collections.Generic;
using System.Text;

namespace MyFundi.Domain
{
    public class JobsFundiCategoriesLocationApart
    {

       public int FundiProfileId { get; set; }
        public int JobId { get; set; }
        public int FundiLocationId { get; set; }
        public int JobLocationId { get; set; }
        public Guid ClientUserId { get; set; }
        public int ClientProfileId { get; set; }
        public int ClientAddressId { get; set; }
        public int JobWorkCategoryId { get; set; }
        public int WorkSubCategoryId { get; set; }
        public string FundiUsername { get; set; }
        public int FundiRating { get; set; }
        public float FundiLocationLat { get; set; }
        public float FundiLocationLong { get; set; }
        public float JobLocationLatitude { get; set; }
        public float JobLocationLongitude { get; set; }
        public string FundiProfileSummary { get; set; }
        public string FundiSkills { get; set; }
        public string FundiUsedPowerTools { get; set; }
        public string FundiLocationName { get; set; }
        public string JobName { get; set; }
        public Guid FundiUserId { get; set; }
        public string ClientUsername { get; set; }
        public string ClientProfileSummary { get; set; }
        public double DistanceApart { get; set; }
        public string WorkCategoryType { get; set; }
        public int WorkCategoryId { get; set; }
        public string WorkSubCategoryType { get; set; }
        public string WorkCategoryDescription { get; set; }
        public string WorkSubCategoryDescription { get; set; }
        public string JobLocationName { get; set; }
        public string ClientFirstName { get; set; }
        public string ClientLastName { get; set; }
        public string JobDescription { get; set; }
        public string FundiFirstName { get; set; }
        public string FundiLastName { get; set; }
    }

    public class FundiRatingsReviewLocationApart
    {

        public int FundiProfileId { get; set; }
        public int JobId { get; set; }
        public int FundiLocationId { get; set; }
        public int JobLocationId { get; set; }
        public Guid ClientUserId { get; set; }
        public int ClientProfileId { get; set; }
        public int ClientAddressId { get; set; }
        public int WorkCategoryId { get; set; }
        public int JobWorkCategoryId { get; set; }
        public int WorkSubCategoryId { get; set; }
        public string FundiUsername { get; set; }
        public int FundiRating { get; set; }
        public int AverageFundiRating { get; set; }
        public float FundiLocationLat { get; set; }
        public float FundiLocationLong { get; set; }
        public float JobLocationLatitude { get; set; }
        public float JobLocationLongitude { get; set; }
        public string FundiProfileSummary { get; set; }
        public string FundiSkills { get; set; }
        public string FundiUsedPowerTools { get; set; }
        public string FundiLocationName { get; set; }
        public string JobName { get; set; }
        public Guid FundiUserId { get; set; }
        public string ClientUsername { get; set; }
        public string ClientProfileSummary { get; set; }
        public float DistanceApart { get; set; }
        public string WorkCategoryType { get; set; }
        public string WorkSubCategoryType { get; set; }
        public string WorkCategoryDescription { get; set; }
        public string WorkSubCategoryDescription { get; set; }
        public string ClientReview { get; set; }
        public string ClientLastName { get; set; }
        public string ClientFirstName { get; set; }
        public string JobDescription { get; set; }
        public string JobLocationName { get; set; }
        public string FundiFirstName { get; set; }
        public string FundiLastName { get; set; }
    }
}
