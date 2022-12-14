using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class subscriptionsAdd : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SubscriptionDescription",
                table: "MonthlySubscriptions");

            migrationBuilder.DropColumn(
                name: "SubscriptionFee",
                table: "MonthlySubscriptions");

            migrationBuilder.DropColumn(
                name: "SubscriptionName",
                table: "MonthlySubscriptions");

            migrationBuilder.CreateTable(
                name: "FundiSubscriptions",
                columns: table => new
                {
                    FundiSubscriptionId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DateCreated = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false),
                    StartDate = table.Column<DateTime>(nullable: false),
                    SubscriptionName = table.Column<string>(nullable: true),
                    SubscriptionFee = table.Column<decimal>(nullable: false),
                    SubscriptionDescription = table.Column<string>(nullable: true),
                    EndDate = table.Column<DateTime>(nullable: false),
                    MonthlySubscriptionId = table.Column<int>(nullable: false),
                    FundiWorkCategoryId = table.Column<int>(nullable: false),
                    FundiWorkSubCategoryId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FundiSubscriptions", x => x.FundiSubscriptionId);
                    table.ForeignKey(
                        name: "FK_FundiSubscriptions_WorkSubCategories_FundiWorkSubCategoryId",
                        column: x => x.FundiWorkSubCategoryId,
                        principalTable: "WorkSubCategories",
                        principalColumn: "WorkSubCategoryId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_FundiSubscriptions_MonthlySubscriptions_MonthlySubscriptionId",
                        column: x => x.MonthlySubscriptionId,
                        principalTable: "MonthlySubscriptions",
                        principalColumn: "MonthlySubscriptionId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FundiSubscriptions_FundiWorkSubCategoryId",
                table: "FundiSubscriptions",
                column: "FundiWorkSubCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiSubscriptions_MonthlySubscriptionId",
                table: "FundiSubscriptions",
                column: "MonthlySubscriptionId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FundiSubscriptions");

            migrationBuilder.AddColumn<string>(
                name: "SubscriptionDescription",
                table: "MonthlySubscriptions",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "SubscriptionFee",
                table: "MonthlySubscriptions",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "SubscriptionName",
                table: "MonthlySubscriptions",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
