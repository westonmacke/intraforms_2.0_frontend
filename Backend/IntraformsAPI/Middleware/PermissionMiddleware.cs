using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.Text.Json;

namespace IntraformsAPI.Middleware
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class RequirePermissionAttribute : Attribute, IAuthorizationFilter
    {
        private readonly string[] _permissions;

        public RequirePermissionAttribute(params string[] permissions)
        {
            _permissions = permissions;
        }

        public void OnAuthorization(AuthorizationFilterContext context)
        {
            var user = context.HttpContext.User;

            if (!user.Identity.IsAuthenticated)
            {
                context.Result = new UnauthorizedObjectResult(new { success = false, message = "Authentication required" });
                return;
            }

            var permissionsClaim = user.Claims.FirstOrDefault(c => c.Type == "permissions");
            if (permissionsClaim == null)
            {
                context.Result = new ForbidResult();
                return;
            }

            try
            {
                var userPermissions = JsonSerializer.Deserialize<List<PermissionDto>>(permissionsClaim.Value);
                var hasPermission = userPermissions.Any(p => _permissions.Contains(p.name));

                if (!hasPermission)
                {
                    context.Result = new ObjectResult(new { success = false, message = "Insufficient permissions" })
                    {
                        StatusCode = 403
                    };
                }
            }
            catch
            {
                context.Result = new ForbidResult();
            }
        }
    }

    public class PermissionDto
    {
        public string name { get; set; }
        public string resource { get; set; }
        public string action { get; set; }
    }
}
