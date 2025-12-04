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
            var result = await connection.QueryAsync("sp_GetAllUsersWithRoles", commandType: System.Data.CommandType.StoredProcedure);
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
