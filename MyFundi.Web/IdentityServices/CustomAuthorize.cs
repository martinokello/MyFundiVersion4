using MyFundi.IdentityServices;
using Microsoft.AspNetCore.Mvc.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
namespace MyFundi.Web.IdentityServices
{
    public class CustomAuthorize : ActionFilterAttribute
    {
        public string[] Roles { get; set; }
        UserService _userService;
        public CustomAuthorize(params string[] Roles)
        {
            this.Roles = Roles;
        }
        public override void OnActionExecuting(ActionExecutingContext context)
        {
            _userService = context.HttpContext.RequestServices.GetService(typeof(IUserService)) as UserService;

            var authToken = context.HttpContext.Request.Headers["authToken"];
            if (!string.IsNullOrEmpty(authToken))
            {
                var userClaims = _userService.GetUserClaimsFromToken(authToken);

                Array.ForEach(Roles, role =>
                {
                    if (userClaims.Where(c => c.Key.ToLower() == "role" && c.Value.ToString().ToLower().Contains(role.ToLower())).Any())
                    {
                        return;
                    }
                    context.Result = new Microsoft.AspNetCore.Mvc.JsonResult(new { Message = "Forbidden", StatusCode = "403" });

                });
            }
            else
            {
                context.Result = new Microsoft.AspNetCore.Mvc.JsonResult(new { Message = "Forbidden", StatusCode = "403" });
            }
        }

    }
}
