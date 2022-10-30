using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class addFundiProfileLocation : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FundiProfiles_Addresses_LocationId",
                table: "FundiProfiles");

            migrationBuilder.AddForeignKey(
                name: "FK_FundiProfiles_Locations_LocationId",
                table: "FundiProfiles",
                column: "LocationId",
                principalTable: "Locations",
                principalColumn: "LocationId",
                onDelete: ReferentialAction.Cascade);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FundiProfiles_Locations_LocationId",
                table: "FundiProfiles");

            migrationBuilder.AddForeignKey(
                name: "FK_FundiProfiles_Addresses_LocationId",
                table: "FundiProfiles",
                column: "LocationId",
                principalTable: "Addresses",
                principalColumn: "AddressId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
