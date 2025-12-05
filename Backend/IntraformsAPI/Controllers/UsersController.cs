using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IntraformsAPI.Services;
using IntraformsAPI.Middleware;
using IntraformsAPI.Data;
using IntraformsAPI.Helpers;
using Dapper;

namespace IntraformsAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly DapperContext _context;
        private readonly PasswordHelper _passwordHelper;

        public UsersController(IUserService userService, DapperContext context, PasswordHelper passwordHelper)
        {
            _userService = userService;
            _context = context;
            _passwordHelper = passwordHelper;
        }

        [HttpGet]
        [RequirePermission("users.read")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var users = await _userService.GetAllUsersAsync();
                return Ok(new { success = true, users });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch users", error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        [RequirePermission("users.read")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var result = await _userService.GetUserByIdAsync(id);
                
                if (result == null)
                {
                    return NotFound(new { success = false, message = "User not found" });
                }

                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch user", error = ex.Message });
            }
        }

        [HttpPost]
        [RequirePermission("users.create")]
        public async Task<IActionResult> Create([FromBody] CreateUserDto userDto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(userDto.username) || string.IsNullOrWhiteSpace(userDto.password))
                {
                    return BadRequest(new { success = false, message = "Username and password are required" });
                }

                using var connection = _context.CreateConnection();
                connection.Open();
                using var transaction = connection.BeginTransaction();

                try
                {
                    // Hash password
                    var passwordHash = _passwordHelper.HashPassword(userDto.password);

                    // Insert user
                    var userId = await connection.ExecuteScalarAsync<int>(
                        @"INSERT INTO users (username, email, password_hash, first_name, last_name, active, department_id, created_at)
                          OUTPUT INSERTED.id
                          VALUES (@Username, @Email, @PasswordHash, @FirstName, @LastName, @Active, @DepartmentId, GETDATE())",
                        new
                        {
                            Username = userDto.username,
                            Email = userDto.email,
                            PasswordHash = passwordHash,
                            FirstName = userDto.first_name,
                            LastName = userDto.last_name,
                            Active = userDto.active ?? true,
                            DepartmentId = userDto.department_id
                        },
                        transaction: transaction
                    );

                    // Insert user roles
                    if (userDto.selectedRoles != null && userDto.selectedRoles.Any())
                    {
                        foreach (var roleId in userDto.selectedRoles)
                        {
                            await connection.ExecuteAsync(
                                "INSERT INTO user_roles (user_id, role_id) VALUES (@UserId, @RoleId)",
                                new { UserId = userId, RoleId = roleId },
                                transaction: transaction
                            );
                        }
                    }

                    transaction.Commit();
                    return Ok(new { success = true, message = "User created successfully", id = userId });
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to create user", error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        [RequirePermission("users.update")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto userDto)
        {
            try
            {
                using var connection = _context.CreateConnection();
                connection.Open();
                using var transaction = connection.BeginTransaction();

                try
                {
                    // Update user
                    var rowsAffected = await connection.ExecuteAsync(
                        @"UPDATE users 
                          SET email = @Email, 
                              first_name = @FirstName, 
                              last_name = @LastName, 
                              active = @Active,
                              department_id = @DepartmentId
                          WHERE id = @Id",
                        new
                        {
                            Id = id,
                            Email = userDto.email,
                            FirstName = userDto.first_name,
                            LastName = userDto.last_name,
                            Active = userDto.active ?? true,
                            DepartmentId = userDto.department_id
                        },
                        transaction: transaction
                    );

                    if (rowsAffected == 0)
                    {
                        transaction.Rollback();
                        return NotFound(new { success = false, message = "User not found" });
                    }

                    // Update roles if provided
                    if (userDto.selectedRoles != null)
                    {
                        // Delete existing roles
                        await connection.ExecuteAsync(
                            "DELETE FROM user_roles WHERE user_id = @UserId",
                            new { UserId = id },
                            transaction: transaction
                        );

                        // Insert new roles
                        foreach (var roleId in userDto.selectedRoles)
                        {
                            await connection.ExecuteAsync(
                                "INSERT INTO user_roles (user_id, role_id) VALUES (@UserId, @RoleId)",
                                new { UserId = id, RoleId = roleId },
                                transaction: transaction
                            );
                        }
                    }

                    transaction.Commit();
                    return Ok(new { success = true, message = "User updated successfully" });
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to update user", error = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [RequirePermission("users.delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var connection = _context.CreateConnection();
                var rowsAffected = await connection.ExecuteAsync(
                    "UPDATE users SET active = 0 WHERE id = @Id",
                    new { Id = id }
                );

                if (rowsAffected == 0)
                {
                    return NotFound(new { success = false, message = "User not found" });
                }

                return Ok(new { success = true, message = "User deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to delete user", error = ex.Message });
            }
        }
    }

    public class CreateUserDto
    {
        public string username { get; set; }
        public string email { get; set; }
        public string password { get; set; }
        public string first_name { get; set; }
        public string last_name { get; set; }
        public bool? active { get; set; }
        public int? department_id { get; set; }
        public List<int> selectedRoles { get; set; }
    }

    public class UpdateUserDto
    {
        public string email { get; set; }
        public string first_name { get; set; }
        public string last_name { get; set; }
        public bool? active { get; set; }
        public int? department_id { get; set; }
        public List<int> selectedRoles { get; set; }
    }
}
