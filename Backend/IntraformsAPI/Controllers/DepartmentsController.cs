using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IntraformsAPI.Data;
using IntraformsAPI.Middleware;
using Dapper;

namespace IntraformsAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class DepartmentsController : ControllerBase
    {
        private readonly DapperContext _context;

        public DepartmentsController(DapperContext context)
        {
            _context = context;
        }

        // GET: api/departments - Get all departments
        [HttpGet]
        [RequirePermission("departments.view")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                using var connection = _context.CreateConnection();
                var departments = await connection.QueryAsync(
                    "SELECT id, name, description FROM departments ORDER BY name"
                );

                return Ok(new { success = true, departments });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch departments", error = ex.Message });
            }
        }

        // POST: api/departments - Create new department
        [HttpPost]
        [RequirePermission("departments.create")]
        public async Task<IActionResult> Create([FromBody] CreateDepartmentDto dto)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                var id = await connection.ExecuteScalarAsync<int>(
                    @"INSERT INTO departments (name, description) 
                      OUTPUT INSERTED.id
                      VALUES (@name, @description)",
                    new { name = dto.name, description = dto.description }
                );

                var department = new
                {
                    id = id,
                    name = dto.name,
                    description = dto.description
                };

                return Ok(new { success = true, department });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to create department", error = ex.Message });
            }
        }

        // PUT: api/departments/{id} - Update department
        [HttpPut("{id}")]
        [RequirePermission("departments.update")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateDepartmentDto dto)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                var result = await connection.ExecuteAsync(
                    @"UPDATE departments 
                      SET name = @name, description = @description 
                      WHERE id = @id",
                    new { id, name = dto.name, description = dto.description }
                );

                if (result == 0)
                {
                    return NotFound(new { success = false, message = "Department not found" });
                }

                var department = new
                {
                    id = id,
                    name = dto.name,
                    description = dto.description
                };

                return Ok(new { success = true, department });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to update department", error = ex.Message });
            }
        }

        // DELETE: api/departments/{id} - Delete department
        [HttpDelete("{id}")]
        [RequirePermission("departments.delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                // Check if department has assigned users
                var userCount = await connection.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM users WHERE department_id = @id AND deleted_at IS NULL",
                    new { id }
                );

                if (userCount > 0)
                {
                    return BadRequest(new { success = false, message = $"Cannot delete department. {userCount} user(s) are assigned to this department." });
                }

                // Check if department has assigned links
                var linkCount = await connection.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM department_link_assignments WHERE department_id = @id",
                    new { id }
                );

                if (linkCount > 0)
                {
                    return BadRequest(new { success = false, message = $"Cannot delete department. {linkCount} link(s) are assigned to this department." });
                }

                var result = await connection.ExecuteAsync(
                    "DELETE FROM departments WHERE id = @id",
                    new { id }
                );

                if (result == 0)
                {
                    return NotFound(new { success = false, message = "Department not found" });
                }

                return Ok(new { success = true, message = "Department deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to delete department", error = ex.Message });
            }
        }

        public class CreateDepartmentDto
        {
            public string name { get; set; }
            public string? description { get; set; }
        }

        public class UpdateDepartmentDto
        {
            public string name { get; set; }
            public string? description { get; set; }
        }
    }
}
