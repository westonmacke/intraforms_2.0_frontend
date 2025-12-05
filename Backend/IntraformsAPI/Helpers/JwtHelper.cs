using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace IntraformsAPI.Helpers
{
    public class JwtHelper
    {
        private readonly IConfiguration _configuration;

        public JwtHelper(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string GenerateToken(int userId, string username, List<string> roles, List<object> permissions, int? departmentId = null)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var secret = _configuration["Jwt:Secret"];
            var key = Encoding.ASCII.GetBytes(secret);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim(ClaimTypes.Name, username),
                new Claim("userId", userId.ToString()),
                new Claim("username", username)
            };

            // Add department if present
            if (departmentId.HasValue)
            {
                claims.Add(new Claim("department_id", departmentId.Value.ToString()));
            }

            // Add roles
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            // Add permissions as JSON string
            claims.Add(new Claim("permissions", System.Text.Json.JsonSerializer.Serialize(permissions)));

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddMinutes(int.Parse(_configuration["Jwt:ExpiresInMinutes"])),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public string GenerateRefreshToken(int userId)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var secret = _configuration["Jwt:RefreshSecret"];
            var key = Encoding.ASCII.GetBytes(secret);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[] { new Claim("userId", userId.ToString()) }),
                Expires = DateTime.UtcNow.AddDays(int.Parse(_configuration["Jwt:RefreshExpiresInDays"])),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        public ClaimsPrincipal ValidateRefreshToken(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var secret = _configuration["Jwt:RefreshSecret"];
            var key = Encoding.ASCII.GetBytes(secret);

            try
            {
                var principal = tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return principal;
            }
            catch
            {
                return null;
            }
        }
    }
}
