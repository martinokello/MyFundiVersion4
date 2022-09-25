using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class FundiProfileCourseTakenRepository : AbstractRepository<FundiProfileCourseTaken>
    {
        public override bool Delete(FundiProfileCourseTaken toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.FundiProfileCourses.SingleOrDefault(p => p.FundiProfileCourseTakenId == toDelete.FundiProfileCourseTakenId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override FundiProfileCourseTaken GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override FundiProfileCourseTaken GetById(int id)
        {
            return MyFundiDBContext.FundiProfileCourses.SingleOrDefault(p => p.FundiProfileCourseTakenId == id);
        }

        public override bool Update(FundiProfileCourseTaken toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.FundiProfileCourseTakenId);
                cert.CourseId = toUpdate.CourseId;
                cert.FundiProfileId = toUpdate.FundiProfileId;
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