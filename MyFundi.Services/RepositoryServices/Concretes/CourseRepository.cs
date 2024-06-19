using MyFundi.Domain;
using MyFundi.Services.RepositoryServices.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFundi.Services.RepositoryServices.Concretes
{
    public class CourseRepository : AbstractRepository<Course>
    {
        public override bool Delete(Course toDelete)
        {
            try
            {
                toDelete = MyFundiDBContext.Courses.SingleOrDefault(p => p.CourseId == toDelete.CourseId);
                MyFundiDBContext.Remove(toDelete);
                return true;
            }
            catch (Exception e)
            {
                return false;
            }
        }

        public override Course GetByGuid(Guid id)
        {
            throw new NotImplementedException();
        }

        public override Course GetById(int id)
        {
            return MyFundiDBContext.Courses.SingleOrDefault(p => p.CourseId == id);
        }

        public override bool Update(Course toUpdate)
        {
            try
            {
                var cert = GetById(toUpdate.CourseId);
                cert.CourseDescription = toUpdate.CourseDescription;
                cert.CourseName = toUpdate.CourseName;
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
