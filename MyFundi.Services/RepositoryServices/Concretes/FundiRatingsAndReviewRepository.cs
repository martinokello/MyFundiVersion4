using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiRatingsAndReviewRepository : AbstractRepository<FundiRatingAndReview>
    {
        public override bool Delete(FundiRatingAndReview toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiProfileAndReviewRatings.SingleOrDefault(p => p.FundiRatingAndReviewId == toDelete.FundiRatingAndReviewId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiRatingAndReview GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiRatingAndReview GetById(int id)
        {
            return MyFundiDBContext.FundiProfileAndReviewRatings.SingleOrDefault(p => p.FundiRatingAndReviewId == id);
        }

        public override bool Update(FundiRatingAndReview toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiRatingAndReviewId);
                cert.FundiProfileId = toUpdate.FundiProfileId;
                cert.Rating = toUpdate.Rating;
                cert.Review = toUpdate.Review;
                cert.UserId = toUpdate.UserId;
                cert.DateUpdated = toUpdate.DateUpdated;
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }
    }
}