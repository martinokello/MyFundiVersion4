using System;
using MyFundi.Domain;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace MyFundi.DataAccess
{
    public class MyFundiDBContext : DbContext
    {
        public MyFundiDBContext(DbContextOptions<MyFundiDBContext> dbOptions) : base(dbOptions)
        {

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
        


        public List<dynamic> GetFoodHubCommoditiesStockStorageUsage()
        {
            var con = base.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.[AllFoodHubDateAnalysisCommoditiesStockStorageUsage]";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                listItems.Add(new
                {
                    FoodHubId = reader["FoodHubId"] == DBNull.Value ? 0 : (int)reader["FoodHubId"],
                    FoodHubName = reader["FoodHubName"] == DBNull.Value ? "Not Found" : (string)reader["FoodHubName"],
                    FoodHubStorageId = reader["FoodHubStorageId"] == DBNull.Value ? 0 : (int)reader["FoodHubStorageId"],
                    RefreigeratedStorageCapacity = reader["RefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0.00 : (decimal)reader["RefreigeratedStorageCapacity"],
                    DryStorageCapacity = reader["DryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["DryStorageCapacity"],
                    UsedDryStorageCapacity = reader["UsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["UsedDryStorageCapacity"],
                    UsedRefreigeratedStorageCapacity = reader["UsedRefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0 : (decimal)reader["UsedRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }


        public List<dynamic> FoodHubCommoditiesStockStorageUsageById(int foodHubId)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            var foodHub = cmd.CreateParameter();
            foodHub.ParameterName = "@foodHubId";
            foodHub.Value = foodHubId;
            cmd.Parameters.Add(foodHub);

            cmd.CommandText = "dbo.FoodHubCommoditiesStockStorageUsageById";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                listItems.Add(new
                {
                    FoodHubId = reader["FoodHubId"] == DBNull.Value ? 0 : (int)reader["FoodHubId"],
                    FoodHubName = reader["FoodHubName"] == DBNull.Value ? "Not Found" : (string)reader["FoodHubName"],
                    FoodHubStorageId = reader["FoodHubStorageId"] == DBNull.Value ? 0 : (int)reader["FoodHubStorageId"],
                    RefreigeratedStorageCapacity = reader["RefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0.00 : (decimal)reader["RefreigeratedStorageCapacity"],
                    DryStorageCapacity = reader["DryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["DryStorageCapacity"],
                    UsedDryStorageCapacity = reader["UsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["UsedDryStorageCapacity"],
                    UsedRefreigeratedStorageCapacity = reader["UsedRefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0 : (decimal)reader["UsedRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetTop5DryCommoditiesInDemandRatingAccordingToStorageFacilities()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.Top5DryCommoditiesInDemandRatingAccordingToStorageFacilities";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityCategoryName"],
                    TotalUsedDryStorageCapacity = reader["TotalUsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalUsedDryStorageCapacity"],
                    TotalDryStorageCapacity = reader["TotalDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalDryStorageCapacity"]
                });
            }
            return listItems;
        }
        public List<dynamic> GetTop5RefreigeratedCommoditiesInDemandRatingAccordingToStorageFacilities()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.Top5RefreigeratedCommoditiesInDemandRatingAccordingToStorageFacilities";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityCategoryName"],
                    TotalUsedRefreigeratedStorageCapacity = reader["TotalUsedRefreigeratedStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalUsedRefreigeratedStorageCapacity"],
                    TotalRefreigeratedStorageCapacity = reader["TotalRefreigeratedStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetTop5FarmerCommoditiesInUnitPricings()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.Top5FarmerCommoditiesInUnitPricing";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    FarmerId = reader["FarmerId"] == DBNull.Value ? 0 : (int)reader["FarmerId"],
                    FarmerName = reader["FarmerName"] == DBNull.Value ? "Not Found" : (string)reader["FarmerName"],
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityCategoryName"],
                    CommodityUnitName = reader["CommodityUnitName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityUnitName"],
                    FarmerCommodityUnitPrice = reader["FarmerCommodityUnitPrice"] == DBNull.Value ? 0 : (decimal)reader["FarmerCommodityUnitPrice"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetFoodHubDateAnalysisCommoditiesStockStorageUsage(DateTime dateFrom, DateTime dateTo)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();

            var from = cmd.CreateParameter();
            from.ParameterName = "@dateFrom";
            from.Value = dateFrom;
            cmd.Parameters.Add(from);

            var to = cmd.CreateParameter();
            to.ParameterName = "@dateTo";
            to.Value = dateTo;
            cmd.Parameters.Add(to);
            cmd.CommandText = "dbo.FoodHubDateAnalysisCommoditiesStockStorageUsage";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    FoodHubId = reader["FoodHubId"] == DBNull.Value ? 0 : (int)reader["FoodHubId"],
                    FoodHubName = reader["FoodHubName"] == DBNull.Value ? "Not Found" : (string)reader["FoodHubName"],
                    FoodHubStorageId = reader["FoodHubStorageId"] == DBNull.Value ? 0 : (int)reader["FoodHubStorageId"],
                    RefreigeratedStorageCapacity = reader["RefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0.00 : (decimal)reader["RefreigeratedStorageCapacity"],
                    DryStorageCapacity = reader["DryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["DryStorageCapacity"],
                    UsedDryStorageCapacity = reader["UsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["UsedDryStorageCapacity"],
                    UsedRefreigeratedStorageCapacity = reader["UsedRefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0 : (decimal)reader["UsedRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetAllFoodHubDateAnalysisCommoditiesStockStorageUsage(DateTime dateFrom, DateTime dateTo)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();

            var from = cmd.CreateParameter();
            from.ParameterName = "@dateFrom";
            from.Value = dateFrom;
            cmd.Parameters.Add(from);

            var to = cmd.CreateParameter();
            to.ParameterName = "@dateTo";
            to.Value = dateTo;
            cmd.Parameters.Add(to);

            cmd.CommandText = "dbo.AllFoodHubDateAnalysisCommoditiesStockStorageUsage";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    FoodHubId = reader["FoodHubId"] == DBNull.Value ? 0 : (int)reader["FoodHubId"],
                    FoodHubName = reader["FoodHubName"] == DBNull.Value ? "Not Found" : (string)reader["FoodHubName"],
                    FoodHubStorageId = reader["FoodHubStorageId"] == DBNull.Value ? 0 : (int)reader["FoodHubStorageId"],
                    RefreigeratedStorageCapacity = reader["RefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0.00 : (decimal)reader["RefreigeratedStorageCapacity"],
                    DryStorageCapacity = reader["DryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["DryStorageCapacity"],
                    UsedDryStorageCapacity = reader["UsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["UsedDryStorageCapacity"],
                    UsedRefreigeratedStorageCapacity = reader["UsedRefreigeratedStorageCapacity"] == DBNull.Value ? (decimal)0 : (decimal)reader["UsedRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetTop5DryCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilities(DateTime dateFrom, DateTime dateTo)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();

            var from = cmd.CreateParameter();
            from.ParameterName = "@dateFrom";
            from.Value = dateFrom;
            cmd.Parameters.Add(from);

            var to = cmd.CreateParameter();
            to.ParameterName = "@dateTo";
            to.Value = dateTo;
            cmd.Parameters.Add(to);

            cmd.CommandText = "dbo.Top5DryCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilities";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                listItems.Add(new
                {
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommCommodityCategoryNameodityName"],
                    TotalUsedDryStorageCapacity = reader["TotalUsedDryStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalUsedDryStorageCapacity"],
                    TotalDryStorageCapacity = reader["TotalDryStorageCapacity"] == DBNull.Value ? "Not Found" : (string)reader["FoodHubName"],
                });
            }
            return listItems;
        }

        public List<dynamic> GetTop5RefreigeratedCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilitiess(DateTime dateFrom, DateTime dateTo)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();

            var from = cmd.CreateParameter();
            from.ParameterName = "@dateFrom";
            from.Value = dateFrom;
            cmd.Parameters.Add(from);

            var to = cmd.CreateParameter();
            to.ParameterName = "@dateTo";
            to.Value = dateTo;
            cmd.Parameters.Add(to);
            cmd.CommandText = "dbo.Top5DryCommoditiesDateAnalysisInDemandRatingAccordingToStorageFacilities";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            con.Open();
            var reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                listItems.Add(new
                {
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommCommodityCategoryNameodityName"],
                    TotalUsedRefreigeratedStorageCapacity = reader["TotalUsedRefreigeratedStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalUsedRefreigeratedStorageCapacity"],
                    TotalRefreigeratedStorageCapacity = reader["TotalRefreigeratedStorageCapacity"] == DBNull.Value ? 0 : (decimal)reader["TotalRefreigeratedStorageCapacity"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetTop5FarmerCommoditiesDateAnalysisInUnitPricingOverDate(DateTime dateFrom, DateTime dateTo)
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();

            var from = cmd.CreateParameter();
            from.ParameterName = "@dateFrom";
            from.Value = dateFrom;
            cmd.Parameters.Add(from);

            var to = cmd.CreateParameter();
            to.ParameterName = "@dateTo";
            to.Value = dateTo;
            cmd.Parameters.Add(to);

            cmd.CommandText = "dbo.Top5FarmerCommoditiesDateAnalysisInUnitPricingOverDate";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    FarmerId = reader["FarmerId"] == DBNull.Value ? 0 : (int)reader["FarmerId"],
                    FarmerName = reader["FarmerName"] == DBNull.Value ? "Not Found" : (string)reader["FarmerName"],
                    CommodityId = reader["CommodityId"] == DBNull.Value ? 0 : (int)reader["CommodityId"],
                    CommodityName = reader["CommodityName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityName"],
                    CommodityCategoryName = reader["CommodityCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityCategoryName"],
                    CommodityUnitName = reader["CommodityUnitName"] == DBNull.Value ? "Not Found" : (string)reader["CommodityUnitName"],
                    FarmerCommodityUnitPrice = reader["FarmerCommodityUnitPrice"] == DBNull.Value ? 0 : (decimal)reader["FarmerCommodityUnitPrice"]
                });
            }
            return listItems;
        }

        public List<dynamic> GetAllUnScheduledVehiclesByStorageCapacityLowestPrice()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.AllUnScheduledVehiclesByStorageCapacityLowestPrice";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    VehicleId = reader["VehicleId"] == DBNull.Value ? 0 : (int)reader["VehicleId"],
                    VehicleRegistration = reader["VehicleRegistration"] == DBNull.Value ? "Not Found" : (string)reader["VehicleRegistration"],
                    CompanyName = reader["CompanyName"] == DBNull.Value ? "" : (string)reader["CompanyName"],
                    VehicleCategoryName = reader["VehicleCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["VehicleCategoryName"],
                    Description = reader["Description"] == DBNull.Value ? "Not Found" : (string)reader["Description"],
                    Cost = reader["Cost"] == DBNull.Value ? 0 : (decimal)reader["Cost"]
                });
            }
            return listItems;
        }
        public List<dynamic> GetAllScheduledVehiclesByStorageCapacityLowestPrice()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "select * from dbo.AllScheduledVehiclesByStorageCapacityLowestPrice()";
            cmd.CommandType = System.Data.CommandType.Text;

            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    VehicleId = reader["VehicleId"] == DBNull.Value ? 0 : (int)reader["VehicleId"],
                    VehicleRegistration = reader["VehicleRegistration"] == DBNull.Value ? "Not Found" : (string)reader["VehicleRegistration"],
                    CompanyName = reader["CompanyName"] == DBNull.Value ? "" : (string)reader["CompanyName"],
                    VehicleCategoryName = reader["VehicleCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["VehicleCategoryName"],
                    Description = reader["Description"] == DBNull.Value ? "Not Found" : (string)reader["Description"],
                    Cost = reader["Cost"] == DBNull.Value ? 0 : (decimal)reader["Cost"]
                });
            }
            return listItems;
        }
        public List<dynamic> GetTop5PricingAllUnScheduledVehiclesByStorageCapacityLowestPrice()
        {
            var con = this.Database.GetDbConnection();

            var listItems = new List<dynamic>();

            var cmd = con.CreateCommand();
            cmd.CommandText = "dbo.Top5PricingAllUnScheduledVehiclesByStorageCapacityLowestPrice";
            cmd.CommandType = System.Data.CommandType.StoredProcedure;

            con.Open();
            var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                listItems.Add(new
                {
                    VehicleId = reader["VehicleId"] == DBNull.Value ? 0 : (int)reader["VehicleId"],
                    VehicleRegistration = reader["VehicleRegistration"] == DBNull.Value ? "Not Found" : (string)reader["VehicleRegistration"],
                    CompanyName = reader["CompanyName"] == DBNull.Value ? "" : (string)reader["CompanyName"],
                    VehicleCategoryName = reader["VehicleCategoryName"] == DBNull.Value ? "Not Found" : (string)reader["VehicleCategoryName"],
                    Description = reader["Description"] == DBNull.Value ? "Not Found" : (string)reader["Description"],
                    Cost = reader["Cost"] == DBNull.Value ? 0 : (decimal)reader["Cost"]
                });
            }
            return listItems;
        }
    }
}

