using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class redressClientFundiContract : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ClientFirstName",
                table: "ClientFundiContracts",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClientLastName",
                table: "ClientFundiContracts",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClientUsername",
                table: "ClientFundiContracts",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FundiFirstName",
                table: "ClientFundiContracts",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FundiLastName",
                table: "ClientFundiContracts",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "FundiUsername",
                table: "ClientFundiContracts",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ClientFirstName",
                table: "ClientFundiContracts");

            migrationBuilder.DropColumn(
                name: "ClientLastName",
                table: "ClientFundiContracts");

            migrationBuilder.DropColumn(
                name: "ClientUsername",
                table: "ClientFundiContracts");

            migrationBuilder.DropColumn(
                name: "FundiFirstName",
                table: "ClientFundiContracts");

            migrationBuilder.DropColumn(
                name: "FundiLastName",
                table: "ClientFundiContracts");

            migrationBuilder.DropColumn(
                name: "FundiUsername",
                table: "ClientFundiContracts");
        }
    }
}
