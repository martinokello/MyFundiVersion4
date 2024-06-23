using System;
using MyFundi.Domain;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Text;
using Microsoft.Data.SqlClient;

namespace MyFundi.DataAccess
{
    public class MyFundiDBContext : DbContext
    {
        private string connectionString;
        public MyFundiDBContext(DbContextOptions<MyFundiDBContext> dbOptions) : base(dbOptions)
        {
            connectionString = Database.GetDbConnection().ConnectionString;
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<User>().HasAlternateKey("Username");
            modelBuilder.Entity<UserRole>().HasKey("UserRoleId");
            modelBuilder.Entity<UserRole>().HasAlternateKey("UserId", "RoleId");
            modelBuilder.Entity<Role>().HasKey("RoleId");
            modelBuilder.Entity<User>().HasIndex(e => e.Email)
            .IsUnique();
            modelBuilder.Entity<User>().HasIndex(e => e.Username)
            .IsUnique();
            modelBuilder.Entity<Role>().HasIndex(e => e.RoleName)
            .IsUnique();
        }
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Address> Addresses { get; set; }
        public DbSet<FundiProfile> FundiProfiles { get; set; }
        public DbSet<Course> Courses { get; set; }
        public DbSet<Certification> Certifications { get; set; }
        public DbSet<FundiProfileCourseTaken> FundiProfileCourses { get; set; }
        public DbSet<FundiProfileCertification> FundiProfileCertifications { get; set; }
        public DbSet<WorkCategory> WorkCategories { get; set; }
        public DbSet<FundiWorkCategory> FundiWorkCategories { get; set; }
        public DbSet<FundiRatingAndReview> FundiProfileAndReviewRatings { get; set; }
        public DbSet<ClientFundiContract> ClientFundiContracts { get; set; }
        public DbSet<Invoice> Invoices { get; set; }
        public DbSet<Item> Items { get; set; }
        public DbSet<Location> Locations { get; set; }
        public DbSet<Company> Companies { get; set; }
        public DbSet<ClientProfile> ClientProfiles { get; set; }
        public DbSet<Job> Jobs { get; set; }
        public DbSet<JobWorkCategory> JobWorkCategories { get; set; }
        public DbSet<MonthlySubscription> MonthlySubscriptions { get; set; }
        public DbSet<WorkSubCategory> WorkSubCategories { get; set; }
        public DbSet<FundiLocation> FundiLocations { get; set; }
        public DbSet<FundiSubscription> FundiSubscriptions { get; set; }
        public DbSet<ClientSubscription> ClientSubscriptions { get; set; }
        public DbSet<FundiSubscriptionQueue> FundiSubscriptionQueues { get; set; }
        public DbSet<MonthlySubscriptionQueue> MonthlySubscriptionQueues { get; set; }
        public DbSet<Blog> Blogs { get; set; }
        public DbSet<Question> Questions { get; set; }
        public DbSet<Answer> Answers { get; set; }

        public Tuple<int, int> GetFundiProfileAvgRatingById(int fundiProfileId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[GetFundiAverageRatingByProfileId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    return new Tuple<int, int>(reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                     reader["FundiAverageRating"] == DBNull.Value ? 0 : (int)reader["FundiAverageRating"]);
                }
                con.Close();
                return new Tuple<int, int>(0, 0);
            }
        }

        public string ValidateFundiSubscription(int fundiProfileId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[GetFundiProfileDatedOnSubscription]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();
                var message = "Subscription Is Still Valid";
                while (reader.Read())
                {
                    message = "User Subscription Expired!! Please renew Subscription.";
                }
                con.Close();
                return message;

            }

        }
        public string ValidateFundiSubscriptionDaysToExpiry(int fundiProfileId, int daysWithin)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));
                cmd.Parameters.Add(new SqlParameter("@daysWithin", daysWithin));

                cmd.CommandText = "[dbo].[GetFundiProfileDatedWithinDaysOfSubscriptionEnd]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();
                var message = "Subscription Is Still Valid";
                while (reader.Read())
                {
                    message = $"User Subscription Is about to expire in {daysWithin} Days!! Please renew Subscription sooner.";
                }
                con.Close();
                return message;

            }

        }
        

        public List<WorkCategoryTypesTO> GetFundiWorkSubCategoriesForFundiByJobId(int jobId, int fundiProfileId)
        {
            var list = new List<WorkCategoryTypesTO>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@jobid", jobId));
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[GetFundiWorkSubCategoriesForFundiByJobId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(new WorkCategoryTypesTO
                    {
                        WorkCategoryId = (reader["WorkCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkCategoryId"]),
                        WorkCategoryType = (reader["WorkCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkCategoryType"]),
                        WorkSubCategoryId = (reader["WorkSubCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkSubCategoryId"]),
                        WorkSubCategoryType = (reader["WorkSubCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkSubCategoryType"])
                    });

                }
                con.Close();
                return list;

            }
        }
        public List<WorkCategoryTypesTO> GetWorkSubCategoriesForFundiByJobId(int jobId, int fundiProfileId)
        {
            var list = new List<WorkCategoryTypesTO>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@jobid", jobId));
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[GetWorkSubCategoriesForFundiByJobId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(new WorkCategoryTypesTO
                    {
                        WorkCategoryId = (reader["WorkCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkCategoryId"]),
                        WorkCategoryType = (reader["WorkCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkCategoryType"]),
                        WorkSubCategoryId = (reader["WorkSubCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkSubCategoryId"]),
                        WorkSubCategoryType = (reader["WorkSubCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkSubCategoryType"])
                    });

                }
                con.Close();
                return list;

            }
        }
        public List<WorkCategoryTypesTO> GetAllFundiWorkCategoriesForJobId(int jobid)
        {
            var list = new List<WorkCategoryTypesTO>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@jobid", jobid));

                cmd.CommandText = "[dbo].[GetAllFundiWorkCategoriesForJobId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(new WorkCategoryTypesTO
                    {
                        WorkCategoryId = (reader["WorkCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkCategoryId"]),
                        WorkCategoryType = (reader["WorkCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkCategoryType"]),
                        WorkSubCategoryId = (reader["WorkSubCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkSubCategoryId"]),
                        WorkSubCategoryType = (reader["WorkSubCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkSubCategoryType"])
                    });

                }
                con.Close();
                return list;

            }
        }
        public List<dynamic> GetAllFundiRatingByProfileId(int fundiProfileId)
        {
            var list = new List<dynamic>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[GetAllFundiRatingByProfileId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(new
                    {
                        FundiProfileId = (reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"]),
                        ClientReview = (reader["ClientReview"] == DBNull.Value ? "Not Found" : (string)reader["ClientReview"]),
                        ClientFirstName = (reader["FirstName"] == DBNull.Value ? "Not Found" : (string)reader["FirstName"]),
                        ClientLastName = (reader["LastName"] == DBNull.Value ? "Not Found" : (string)reader["LastName"]),
                        FundiRating = (reader["FundiRating"] == DBNull.Value ? 0 : (int)reader["FundiRating"]),
                        ClientUserId = (Guid)reader["ClientUserId"]
                    });

                }
                con.Close();
                return list;

            }

        }
        public List<WorkSubCategory> GetWorkSubCategoriesByWorkCategoryId(int workCategoryId)
        {
            var list = new List<WorkSubCategory>();
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                SqlCommand cmd = con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@workCategoryId", workCategoryId));

                cmd.CommandText = "[dbo].[GetWorkSubCategoriesByWorkCategoryId]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(
                        new WorkSubCategory
                        {
                            WorkSubCategoryType = reader["WorkSubCategoryType"] == DBNull.Value ? "Not Found" : (string)reader["WorkSubCategoryType"],
                            WorkSubCategoryId = reader["WorkSubCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkSubCategoryId"],
                            WorkCategoryId = reader["WorkCategoryId"] == DBNull.Value ? 0 : (int)reader["WorkCategoryId"],
                            WorkSubCategoryDescription = reader["WorkSubCategoryDescription"] == DBNull.Value ? "Not Found" : (string)reader["WorkSubCategoryDescription"]
                        });
                }
                con.Close();
            }
            return list;
        }
        public List<FundiRatingsReviewLocationApart> GetFundiAvgRatingsAndJobWithinDistanceGeoLocation(int clientProfileId, int jobId, string[] fundiCategories, string[] fundiSubCategories, CoordinateTo[] coordinates, float distanceApart, int skip, int take)
        {
            var seqProfIdLatLngBuilder = new StringBuilder();
            foreach (var el in coordinates)
            {
                seqProfIdLatLngBuilder.Append("," + el.ProfileId.ToString() + "," + el.Latitude + "," + el.Longitude);
            }

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@clientProfileId", clientProfileId));

                cmd.Parameters.Add(new SqlParameter("@jobId", jobId));

                cmd.Parameters.Add(new SqlParameter("@distanceApart", distanceApart));

                cmd.Parameters.Add(new SqlParameter("@coordinates", seqProfIdLatLngBuilder.ToString().Trim(',')));

                cmd.Parameters.Add(new SqlParameter("@skip", skip));

                cmd.Parameters.Add(new SqlParameter("@take", take));

                var strBuilder = new StringBuilder();
                foreach (var st in fundiCategories)
                {
                    strBuilder.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workCategories", strBuilder.ToString().Trim(',')));

                var strBuilder2 = new StringBuilder();
                foreach (var st in fundiSubCategories)
                {
                    strBuilder2.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workSubCategories", strBuilder2.ToString().Trim(',')));

                var listItems = new List<FundiRatingsReviewLocationApart>();

                cmd.CommandText = "dbo.[GetFundiRatingsGeoLocations]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    listItems.Add(new FundiRatingsReviewLocationApart
                    {
                        FundiProfileId = reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                        FundiUsername = reader["FundiUsername"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsername"],
                        FundiFirstName = reader["FundiFirstName"] == DBNull.Value ? "Not Found" : (string)reader["FundiFirstName"],
                        FundiLastName = reader["FundiLastName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLastName"],
                        FundiLocationId = reader["FundiLocationId"] == DBNull.Value ? 0 : (int)reader["FundiLocationId"],
                        FundiLocationLat = reader["FundiLocationLat"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLat"]),
                        FundiLocationLong = reader["FundiLocationLong"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLong"]),
                        FundiProfileSummary = reader["FundiProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["FundiProfileSummary"],
                        FundiSkills = reader["FundiSkills"] == DBNull.Value ? "" : (string)reader["FundiSkills"],
                        FundiUsedPowerTools = reader["FundiUsedPowerTools"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsedPowerTools"],
                        JobId = reader["JobId"] == DBNull.Value ? 0 : (int)reader["JobId"],
                        JobName = reader["JobName"] == DBNull.Value ? "Not Found" : (string)reader["JobName"],
                        FundiLocationName = reader["FundiLocationName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLocationName"],
                        JobLocationId = reader["JobLocationId"] == DBNull.Value ? 0 : (int)reader["JobLocationId"],
                        JobLocationName = reader["JobLocationName"] == DBNull.Value ? "Not Found" : (string)reader["JobLocationName"],
                        JobDescription = reader["JobDescription"] == DBNull.Value ? "Not Found" : (string)reader["JobDescription"],
                        JobLocationLatitude = reader["JobLocationLatitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLatitude"]),
                        JobLocationLongitude = reader["JobLocationLongitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLongitude"]),
                        ClientUsername = reader["ClientUsername"] == DBNull.Value ? "Not Found" : (string)reader["ClientUsername"],
                        ClientFirstName = reader["ClientFirstName"] == DBNull.Value ? "Not Found" : (string)reader["ClientFirstName"],
                        ClientLastName = reader["ClientLastName"] == DBNull.Value ? "Not Found" : (string)reader["ClientLastName"],
                        ClientProfileId = reader["ClientProfileId"] == DBNull.Value ? 0 : (int)reader["ClientProfileId"],
                        ClientAddressId = reader["ClientAddressId"] == DBNull.Value ? 0 : (int)reader["ClientAddressId"],
                        ClientProfileSummary = reader["ClientProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["ClientProfileSummary"],
                        DistanceApart = reader["DistanceApart"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["DistanceApart"]),
                        FundiUserId = (Guid)reader["FundiUserId"],
                        ClientUserId = (Guid)reader["ClientUserId"]
                    });
                }
                con.Close();
                return listItems;
            }

        }

        public bool IsClientToPaySubscriptionFee(string username, int durationInDaysDue)
        {
            var list = new List<dynamic>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = con.CreateCommand();
                cmd.Parameters.Add(new SqlParameter("@clientUsername", username));
                cmd.Parameters.Add(new SqlParameter("@durationInDays", durationInDaysDue));

                cmd.CommandText = "[dbo].[CheckClientIsDueSubscriptionPayment]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();
                var isDueToPaySubscription = 0;
                while (reader.Read())
                {
                    isDueToPaySubscription = (int)reader[0];
                }
                con.Close();
                return isDueToPaySubscription > 0;
            }

        }

        public List<FundiRatingsReviewLocationApart> GetFundiAvgRatingsAndJobWithinDistance(int clientProfileId, int jobId, string[] fundiCategories, string[] fundiSubCategories, float distanceApart, int skip, int take)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@clientProfileId", clientProfileId));

                cmd.Parameters.Add(new SqlParameter("@jobId", jobId));

                cmd.Parameters.Add(new SqlParameter("@distanceApart", distanceApart));


                cmd.Parameters.Add(new SqlParameter("@skip", skip));

                cmd.Parameters.Add(new SqlParameter("@take", take));

                var strBuilder = new StringBuilder();
                foreach (var st in fundiCategories)
                {
                    strBuilder.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workCategories", strBuilder.ToString().Trim(',')));

                var strBuilder2 = new StringBuilder();
                foreach (var st in fundiSubCategories)
                {
                    strBuilder2.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workSubCategories", strBuilder2.ToString().Trim(',')));

                var listItems = new List<FundiRatingsReviewLocationApart>();

                cmd.CommandText = "dbo.[GetFundiRatings]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    listItems.Add(new FundiRatingsReviewLocationApart
                    {
                        FundiProfileId = reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                        FundiUsername = reader["FundiUsername"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsername"],
                        FundiFirstName = reader["FundiFirstName"] == DBNull.Value ? "Not Found" : (string)reader["FundiFirstName"],
                        FundiLastName = reader["FundiLastName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLastName"],
                        FundiLocationId = reader["FundiLocationId"] == DBNull.Value ? 0 : (int)reader["FundiLocationId"],
                        FundiLocationLat = reader["FundiLocationLat"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLat"]),
                        FundiLocationLong = reader["FundiLocationLong"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLong"]),
                        FundiProfileSummary = reader["FundiProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["FundiProfileSummary"],
                        FundiSkills = reader["FundiSkills"] == DBNull.Value ? "" : (string)reader["FundiSkills"],
                        FundiUsedPowerTools = reader["FundiUsedPowerTools"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsedPowerTools"],
                        JobId = reader["JobId"] == DBNull.Value ? 0 : (int)reader["JobId"],
                        JobName = reader["JobName"] == DBNull.Value ? "Not Found" : (string)reader["JobName"],
                        FundiLocationName = reader["FundiLocationName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLocationName"],
                        JobLocationId = reader["JobLocationId"] == DBNull.Value ? 0 : (int)reader["JobLocationId"],
                        JobLocationName = reader["JobLocationName"] == DBNull.Value ? "Not Found" : (string)reader["JobLocationName"],
                        JobDescription = reader["JobDescription"] == DBNull.Value ? "Not Found" : (string)reader["JobDescription"],
                        JobLocationLatitude = reader["JobLocationLatitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLatitude"]),
                        JobLocationLongitude = reader["JobLocationLongitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLongitude"]),
                        ClientUsername = reader["ClientUsername"] == DBNull.Value ? "Not Found" : (string)reader["ClientUsername"],
                        ClientFirstName = reader["ClientFirstName"] == DBNull.Value ? "Not Found" : (string)reader["ClientFirstName"],
                        ClientLastName = reader["ClientLastName"] == DBNull.Value ? "Not Found" : (string)reader["ClientLastName"],
                        ClientProfileId = reader["ClientProfileId"] == DBNull.Value ? 0 : (int)reader["ClientProfileId"],
                        ClientAddressId = reader["ClientAddressId"] == DBNull.Value ? 0 : (int)reader["ClientAddressId"],
                        ClientProfileSummary = reader["ClientProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["ClientProfileSummary"],
                        DistanceApart = reader["DistanceApart"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["DistanceApart"]),
                        FundiUserId = (Guid)reader["FundiUserId"],
                        ClientUserId = (Guid)reader["ClientUserId"]
                    });
                }
                con.Close();
                return listItems;
            }

        }

        public List<JobsFundiCategoriesLocationApart> GetJobsByFundiWorkCategoriesWithinDistanceGeoLocation(string[] fundiCategories, string[] fundiSubCategories, CoordinateTo[] coordinates, float distanceApart, int skip, int take)
        {
            var seqProfIdLatLngBuilder = new StringBuilder();
            foreach (var el in coordinates)
            {
                seqProfIdLatLngBuilder.Append("," + el.ProfileId.ToString() + "," + el.Latitude + "," + el.Longitude);
            }
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@distanceApart", distanceApart));

                cmd.Parameters.Add(new SqlParameter("@coordinates", seqProfIdLatLngBuilder.ToString().Trim(',')));

                cmd.Parameters.Add(new SqlParameter("@skip", skip));

                cmd.Parameters.Add(new SqlParameter("@take", take));

                var strBuilder = new StringBuilder();
                foreach (var st in fundiCategories)
                {
                    strBuilder.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workCategories", strBuilder.ToString().Trim(',')));

                var strBuilder2 = new StringBuilder();
                foreach (var st in fundiSubCategories)
                {
                    strBuilder2.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workSubCategories", strBuilder2.ToString().Trim(',')));

                var listItems = new List<JobsFundiCategoriesLocationApart>();

                cmd.CommandText = "dbo.[GetFundiByLocationVsJobLocationGeoLocation]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;


                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    listItems.Add(new JobsFundiCategoriesLocationApart
                    {
                        FundiProfileId = reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                        FundiUsername = reader["FundiUsername"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsername"],
                        FundiFirstName = reader["FundiFirstName"] == DBNull.Value ? "Not Found" : (string)reader["FundiFirstName"],
                        FundiLastName = reader["FundiLastName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLastName"],
                        FundiLocationId = reader["FundiLocationId"] == DBNull.Value ? 0 : (int)reader["FundiLocationId"],
                        FundiLocationLat = reader["FundiLocationLat"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLat"]),
                        FundiLocationLong = reader["FundiLocationLong"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLong"]),
                        FundiProfileSummary = reader["FundiProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["FundiProfileSummary"],
                        FundiSkills = reader["FundiSkills"] == DBNull.Value ? "" : (string)reader["FundiSkills"],
                        FundiUsedPowerTools = reader["FundiUsedPowerTools"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsedPowerTools"],
                        JobId = reader["JobId"] == DBNull.Value ? 0 : (int)reader["JobId"],
                        JobName = reader["JobName"] == DBNull.Value ? "Not Found" : (string)reader["JobName"],
                        FundiLocationName = reader["FundiLocationName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLocationName"],
                        JobLocationId = reader["JobLocationId"] == DBNull.Value ? 0 : (int)reader["JobLocationId"],
                        JobLocationName = reader["JobLocationName"] == DBNull.Value ? "Not Found" : (string)reader["JobLocationName"],
                        JobDescription = reader["JobDescription"] == DBNull.Value ? "Not Found" : (string)reader["JobDescription"],
                        JobLocationLatitude = reader["JobLocationLatitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLatitude"]),
                        JobLocationLongitude = reader["JobLocationLongitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLongitude"]),
                        ClientUsername = reader["ClientUsername"] == DBNull.Value ? "Not Found" : (string)reader["ClientUsername"],
                        ClientFirstName = reader["ClientFirstName"] == DBNull.Value ? "Not Found" : (string)reader["ClientFirstName"],
                        ClientLastName = reader["ClientLastName"] == DBNull.Value ? "Not Found" : (string)reader["ClientLastName"],
                        ClientProfileId = reader["ClientProfileId"] == DBNull.Value ? 0 : (int)reader["ClientProfileId"],
                        ClientAddressId = reader["ClientAddressId"] == DBNull.Value ? 0 : (int)reader["ClientAddressId"],
                        ClientProfileSummary = reader["ClientProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["ClientProfileSummary"],
                        DistanceApart = reader["DistanceApart"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["DistanceApart"]),
                        FundiUserId = (Guid)reader["FundiUserId"],
                        ClientUserId = (Guid)reader["ClientUserId"],
                    });
                }
                con.Close();
                return listItems;
            }
        }

        public decimal GetFundiExpectedSubscriptionFee(Guid? userId,decimal baseFundiSubsFee, decimal secondFundiSubsFee, decimal thirdFundiSubsFee)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                SqlCommand cmd = con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@fundiUserId", userId.ToString())); 
                cmd.Parameters.Add(new SqlParameter("@baseFundiSubsFee", baseFundiSubsFee));
                cmd.Parameters.Add(new SqlParameter("@secondFundiSubsFee", secondFundiSubsFee));
                cmd.Parameters.Add(new SqlParameter("@thirdFundiSubsFee", thirdFundiSubsFee));

                cmd.CommandText = "[dbo].[GetAbsoluteFundiFee]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.CommandTimeout = 50;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();
                decimal absoluteChargedFee = (decimal)0.00;

                while (reader.Read())
                {
                    absoluteChargedFee = reader[0] == DBNull.Value ? (decimal)0.00 : (decimal)reader[0];
                }
                con.Close();
                return absoluteChargedFee;
            }
        }
		public decimal GetFundiLastPaidSubscriptionFee(Guid? userId, decimal baseFundiSubsFee, decimal secondFundiSubsFee, decimal thirdFundiSubsFee)
		{
			using (SqlConnection con = new SqlConnection(connectionString))
			{

				SqlCommand cmd = con.CreateCommand();

				cmd.Parameters.Add(new SqlParameter("@fundiUserId", userId.ToString()));
				cmd.Parameters.Add(new SqlParameter("@baseFundiSubsFee", baseFundiSubsFee));
				cmd.Parameters.Add(new SqlParameter("@secondFundiSubsFee", secondFundiSubsFee));
				cmd.Parameters.Add(new SqlParameter("@thirdFundiSubsFee", thirdFundiSubsFee));

				cmd.CommandText = "[dbo].[GetAbsolutePaidFundiFee]";
				cmd.CommandType = System.Data.CommandType.StoredProcedure;
				cmd.CommandTimeout = 50;

				if (cmd.Connection.State != System.Data.ConnectionState.Open)
				{
					con.Open();
				}
				var reader = cmd.ExecuteReader();
				decimal absoluteChargedFee = (decimal)0.00;

				while (reader.Read())
				{
					absoluteChargedFee = reader[0] == DBNull.Value ? (decimal)0.00 : (decimal)reader[0];
				}
				con.Close();
				return absoluteChargedFee;
			}
		}
		public decimal GetFundiLastSubscriptionFees(Guid userId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                SqlCommand cmd = con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@fundiUserId", userId));

                cmd.CommandText = "[dbo].[GetLastSubscriptionExistingTotalAbsoluteFundiFee]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();
                decimal absoluteExistingFee = (decimal)0.00;

                while (reader.Read())
                {
                    absoluteExistingFee = reader["AbsoluteExistingFee"] == DBNull.Value ? (decimal)0.00 : (decimal)reader["AbsoluteExistingFee"];
                }
                con.Close();
                return absoluteExistingFee;
            }
        }

        public List<JobsFundiCategoriesLocationApart> GetJobsByFundiWorkCategoriesWithinDistance(int fundiProfileId, string[] fundiCategories, string[] fundiSubCategories, float distanceApart, int skip, int take)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = (SqlCommand)con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.Parameters.Add(new SqlParameter("@distanceApart", distanceApart));

                cmd.Parameters.Add(new SqlParameter("@skip", skip));

                cmd.Parameters.Add(new SqlParameter("@take", take));

                var strBuilder = new StringBuilder();
                foreach (var st in fundiCategories)
                {
                    strBuilder.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workCategories", strBuilder.ToString().Trim(',')));

                var strBuilder2 = new StringBuilder();
                foreach (var st in fundiSubCategories)
                {
                    strBuilder2.Append(st + ",");
                }
                cmd.Parameters.Add(new SqlParameter("@workSubCategories", strBuilder2.ToString().Trim(',')));

                var listItems = new List<JobsFundiCategoriesLocationApart>();

                cmd.CommandText = "dbo.[GetFundiByLocationVsJobLocation]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;


                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }

                var reader = cmd.ExecuteReader();
                while (reader.Read())
                {
                    listItems.Add(new JobsFundiCategoriesLocationApart
                    {
                        FundiProfileId = reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                        FundiUsername = reader["FundiUsername"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsername"],
                        FundiFirstName = reader["FundiFirstName"] == DBNull.Value ? "Not Found" : (string)reader["FundiFirstName"],
                        FundiLastName = reader["FundiLastName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLastName"],
                        FundiLocationId = reader["FundiLocationId"] == DBNull.Value ? 0 : (int)reader["FundiLocationId"],
                        FundiLocationLat = reader["FundiLocationLat"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLat"]),
                        FundiLocationLong = reader["FundiLocationLong"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["FundiLocationLong"]),
                        FundiProfileSummary = reader["FundiProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["FundiProfileSummary"],
                        FundiSkills = reader["FundiSkills"] == DBNull.Value ? "" : (string)reader["FundiSkills"],
                        FundiUsedPowerTools = reader["FundiUsedPowerTools"] == DBNull.Value ? "Not Found" : (string)reader["FundiUsedPowerTools"],
                        JobId = reader["JobId"] == DBNull.Value ? 0 : (int)reader["JobId"],
                        JobName = reader["JobName"] == DBNull.Value ? "Not Found" : (string)reader["JobName"],
                        FundiLocationName = reader["FundiLocationName"] == DBNull.Value ? "Not Found" : (string)reader["FundiLocationName"],
                        JobLocationId = reader["JobLocationId"] == DBNull.Value ? 0 : (int)reader["JobLocationId"],
                        JobLocationName = reader["JobLocationName"] == DBNull.Value ? "Not Found" : (string)reader["JobLocationName"],
                        JobDescription = reader["JobDescription"] == DBNull.Value ? "Not Found" : (string)reader["JobDescription"],
                        JobLocationLatitude = reader["JobLocationLatitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLatitude"]),
                        JobLocationLongitude = reader["JobLocationLongitude"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["JobLocationLongitude"]),
                        ClientUsername = reader["ClientUsername"] == DBNull.Value ? "Not Found" : (string)reader["ClientUsername"],
                        ClientFirstName = reader["ClientFirstName"] == DBNull.Value ? "Not Found" : (string)reader["ClientFirstName"],
                        ClientLastName = reader["ClientLastName"] == DBNull.Value ? "Not Found" : (string)reader["ClientLastName"],
                        ClientProfileId = reader["ClientProfileId"] == DBNull.Value ? 0 : (int)reader["ClientProfileId"],
                        ClientAddressId = reader["ClientAddressId"] == DBNull.Value ? 0 : (int)reader["ClientAddressId"],
                        ClientProfileSummary = reader["ClientProfileSummary"] == DBNull.Value ? "Not Found" : (string)reader["ClientProfileSummary"],
                        DistanceApart = reader["DistanceApart"] == DBNull.Value ? (float)0.0 : Convert.ToSingle(reader["DistanceApart"]),
                        FundiUserId = (Guid)reader["FundiUserId"],
                        ClientUserId = (Guid)reader["ClientUserId"],
                    });
                }
                con.Close();
                return listItems;
            }
        }

        public List<dynamic> GetFundiLevelOfEngagementById(int fundiProfileId)
        {
            var list = new List<dynamic>();
            using (SqlConnection con = new SqlConnection(connectionString))
            {

                SqlCommand cmd = con.CreateCommand();

                cmd.Parameters.Add(new SqlParameter("@fundiProfileId", fundiProfileId));

                cmd.CommandText = "[dbo].[FundiLevelOfEngagement]";
                cmd.CommandType = System.Data.CommandType.StoredProcedure;

                if (cmd.Connection.State != System.Data.ConnectionState.Open)
                {
                    con.Open();
                }
                var reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    list.Add(
                        new
                        {
                            FundiProfileId = reader["FundiProfileId"] == DBNull.Value ? 0 : (int)reader["FundiProfileId"],
                            FirstName = reader["FirstName"] == DBNull.Value ? "Not Found" : (string)reader["FirstName"],
                            LastName = reader["LastName"] == DBNull.Value ? "Not Found" : (string)reader["LastName"],
                            NumberOfAssignments = reader["NumberOfAssignments"] == DBNull.Value ? 0 : (int)reader["NumberOfAssignments"]
                        });
                }
                con.Close();
            }
            return list;
        }

    }
}
