using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class addingFundiClientSubscriptions : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "ClientSubscriptions",
                columns: table => new
                {
                    SubscriptionId = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<Guid>(nullable: true),
                    Username = table.Column<string>(nullable: true),
                    SubscriptionName = table.Column<string>(nullable: true),
                    SubscriptionDescription = table.Column<string>(nullable: true),
                    ClientProfileId = table.Column<int>(nullable: true),
                    HasPaid = table.Column<bool>(nullable: false),
                    SubscriptionFee = table.Column<decimal>(nullable: false),
                    StartDate = table.Column<DateTime>(nullable: false),
                    DateUpdated = table.Column<DateTime>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ClientSubscriptions", x => x.SubscriptionId);
                    table.ForeignKey(
                        name: "FK_ClientSubscriptions_ClientProfiles_ClientProfileId",
                        column: x => x.ClientProfileId,
                        principalTable: "ClientProfiles",
                        principalColumn: "ClientProfileId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ClientSubscriptions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ClientSubscriptions_ClientProfileId",
                table: "ClientSubscriptions",
                column: "ClientProfileId");

            migrationBuilder.CreateIndex(
                name: "IX_ClientSubscriptions_UserId",
                table: "ClientSubscriptions",
                column: "UserId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ClientSubscriptions");
        }
    }
}
