using Dapper;
using IntraformsAPI.Data;
using IntraformsAPI.Models;
using IntraformsAPI.Helpers;
using System.Data;

namespace IntraformsAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly DapperContext _context;
        private readonly JwtHelper _jwtHelper;
        private readonly PasswordHelper _passwordHelper;

        public AuthService(DapperContext context, JwtHelper jwtHelper, PasswordHelper passwordHelper)
        {
            _context = context;
            _jwtHelper = jwtHelper;
            _passwordHelper = passwordHelper;
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            using var connection = _context.CreateConnection();

            // Get user
            var user = await connection.QueryFirstOrDefaultAsync<User>(
                "SELECT id, username, email, password_hash, first_name, last_name, active FROM users WHERE username = @Username AND active = 1",
                new { request.Username }
            );

            if (user == null)
            {
                return new AuthResponse { Success = false, Message = "Invalid credentials" };
            }

            // Verify password
            if (!_passwordHelper.VerifyPassword(request.Password, user.password_hash))
            {
                return new AuthResponse { Success = false, Message = "Invalid credentials" };
            }

            // Get roles
            var roles = (await connection.QueryAsync<RoleDto>(
                @"SELECT r.id, r.name, r.description
                  FROM roles r
                  INNER JOIN user_roles ur ON r.id = ur.role_id
                  WHERE ur.user_id = @UserId AND r.active = 1",
                new { UserId = user.id }
            )).ToList();

            // Get permissions
            var permissions = (await connection.QueryAsync<PermissionDto>(
                @"SELECT DISTINCT p.id, p.name, p.resource, p.action, p.description
                  FROM permissions p
                  INNER JOIN role_permissions rp ON p.id = rp.permission_id
                  INNER JOIN user_roles ur ON rp.role_id = ur.role_id
                  WHERE ur.user_id = @UserId",
                new { UserId = user.id }
            )).ToList();

            // Update last login
            await connection.ExecuteAsync(
                "UPDATE users SET last_login = GETDATE() WHERE id = @UserId",
                new { UserId = user.id }
            );

            // Generate tokens
            var roleNames = roles.Select(r => r.Name).ToList();
            var permissionsForToken = permissions.Select(p => new { p.Name, p.Resource, p.Action }).Cast<object>().ToList();

            var token = _jwtHelper.GenerateToken(user.id, user.username, roleNames, permissionsForToken);
            var refreshToken = _jwtHelper.GenerateRefreshToken(user.id);

            return new AuthResponse
            {
                Success = true,
                Token = token,
                RefreshToken = refreshToken,
                User = new UserDto
                {
                    Id = user.id,
                    Username = user.username,
                    Email = user.email,
                    First_Name = user.first_name,
                    Last_Name = user.last_name
                },
                Roles = roles,
                Permissions = permissions
            };
        }

        public async Task<AuthResponse> RefreshTokenAsync(string refreshToken)
        {
            var principal = _jwtHelper.ValidateRefreshToken(refreshToken);
            if (principal == null)
            {
                return new AuthResponse { Success = false, Message = "Invalid refresh token" };
            }

            var userIdClaim = principal.Claims.FirstOrDefault(c => c.Type == "userId");
            if (userIdClaim == null)
            {
                return new AuthResponse { Success = false, Message = "Invalid token claims" };
            }

            var userId = int.Parse(userIdClaim.Value);

            using var connection = _context.CreateConnection();

            // Get user
            var user = await connection.QueryFirstOrDefaultAsync<User>(
                "SELECT id, username, email, first_name, last_name, active FROM users WHERE id = @UserId AND active = 1",
                new { UserId = userId }
            );

            if (user == null)
            {
                return new AuthResponse { Success = false, Message = "User not found" };
            }

            // Get roles and permissions (same as login)
            var roles = (await connection.QueryAsync<RoleDto>(
                @"SELECT r.id, r.name, r.description
                  FROM roles r
                  INNER JOIN user_roles ur ON r.id = ur.role_id
                  WHERE ur.user_id = @UserId AND r.active = 1",
                new { UserId = userId }
            )).ToList();

            var permissions = (await connection.QueryAsync<PermissionDto>(
                @"SELECT DISTINCT p.id, p.name, p.resource, p.action, p.description
                  FROM permissions p
                  INNER JOIN role_permissions rp ON p.id = rp.permission_id
                  INNER JOIN user_roles ur ON rp.role_id = ur.role_id
                  WHERE ur.user_id = @UserId",
                new { UserId = userId }
            )).ToList();

            // Generate new tokens
            var roleNames = roles.Select(r => r.Name).ToList();
            var permissionsForToken = permissions.Select(p => new { p.Name, p.Resource, p.Action }).Cast<object>().ToList();

            var newToken = _jwtHelper.GenerateToken(user.id, user.username, roleNames, permissionsForToken);
            var newRefreshToken = _jwtHelper.GenerateRefreshToken(user.id);

            return new AuthResponse
            {
                Success = true,
                Token = newToken,
                RefreshToken = newRefreshToken,
                User = new UserDto
                {
                    Id = user.id,
                    Username = user.username,
                    Email = user.email,
                    First_Name = user.first_name,
                    Last_Name = user.last_name
                },
                Roles = roles,
                Permissions = permissions
            };
        }

        private class User
        {
            public int id { get; set; }
            public string username { get; set; }
            public string email { get; set; }
            public string password_hash { get; set; }
            public string first_name { get; set; }
            public string last_name { get; set; }
            public bool active { get; set; }
        }
    }
}
