using Microsoft.EntityFrameworkCore.Migrations;

namespace MyFundi.Web.Migrations
{
    public partial class addSubCategories : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "WorkSubCategoryId",
                table: "JobWorkCategories",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "WorkSubCategoryId",
                table: "FundiWorkCategories",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_JobWorkCategories_WorkSubCategoryId",
                table: "JobWorkCategories",
                column: "WorkSubCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_FundiWorkCategories_WorkSubCategoryId",
                table: "FundiWorkCategories",
                column: "WorkSubCategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_FundiWorkCategories_WorkSubCategories_WorkSubCategoryId",
                table: "FundiWorkCategories",
                column: "WorkSubCategoryId",
                principalTable: "WorkSubCategories",
                principalColumn: "WorkSubCategoryId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_JobWorkCategories_WorkSubCategories_WorkSubCategoryId",
                table: "JobWorkCategories",
                column: "WorkSubCategoryId",
                principalTable: "WorkSubCategories",
                principalColumn: "WorkSubCategoryId",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_FundiWorkCategories_WorkSubCategories_WorkSubCategoryId",
                table: "FundiWorkCategories");

            migrationBuilder.DropForeignKey(
                name: "FK_JobWorkCategories_WorkSubCategories_WorkSubCategoryId",
                table: "JobWorkCategories");

            migrationBuilder.DropIndex(
                name: "IX_JobWorkCategories_WorkSubCategoryId",
                table: "JobWorkCategories");

            migrationBuilder.DropIndex(
                name: "IX_FundiWorkCategories_WorkSubCategoryId",
                table: "FundiWorkCategories");

            migrationBuilder.DropColumn(
                name: "WorkSubCategoryId",
                table: "JobWorkCategories");

            migrationBuilder.DropColumn(
                name: "WorkSubCategoryId",
                table: "FundiWorkCategories");
        }
    }
}
