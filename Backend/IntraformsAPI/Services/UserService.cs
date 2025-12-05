using Dapper;
using IntraformsAPI.Data;

namespace IntraformsAPI.Services
{
    public class UserService : IUserService
    {
        private readonly DapperContext _context;

        public UserService(DapperContext context)
        {
            _context = context;
        }

        public async Task<List<object>> GetAllUsersAsync()
        {
            using var connection = _context.CreateConnection();
            var result = await connection.QueryAsync(@"
                SELECT 
                    u.id,
                    u.username,
                    u.email,
                    u.first_name,
                    u.last_name,
                    u.active,
                    u.department_id,
                    STRING_AGG(r.name, ', ') as roles
                FROM users u
                LEFT JOIN user_roles ur ON u.id = ur.user_id
                LEFT JOIN roles r ON ur.role_id = r.id
                GROUP BY u.id, u.username, u.email, u.first_name, u.last_name, u.active, u.department_id
                ORDER BY u.username
            ");
            return result.Cast<object>().ToList();
        }

        public async Task<object> GetUserByIdAsync(int userId)
        {
            using var connection = _context.CreateConnection();
            
            var parameters = new DynamicParameters();
            parameters.Add("user_id", userId);

            using var multi = await connection.QueryMultipleAsync(
                "sp_GetUserWithPermissions",
                parameters,
                commandType: System.Data.CommandType.StoredProcedure
            );

            var user = await multi.ReadFirstOrDefaultAsync();
            var roles = await multi.ReadAsync();
            var permissions = await multi.ReadAsync();

            return new
            {
                user,
                roles,
                permissions
            };
        }
    }
}
