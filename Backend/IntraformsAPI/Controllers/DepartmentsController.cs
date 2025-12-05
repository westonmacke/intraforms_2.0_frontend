using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IntraformsAPI.Data;
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
    }
}
