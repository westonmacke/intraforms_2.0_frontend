using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IntraformsAPI.Data;
using Dapper;

namespace IntraformsAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RolesController : ControllerBase
    {
        private readonly DapperContext _context;

        public RolesController(DapperContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                using var connection = _context.CreateConnection();
                var roles = await connection.QueryAsync(
                    "SELECT id, name, description FROM roles WHERE active = 1 ORDER BY name"
                );

                return Ok(new { success = true, roles });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch roles", error = ex.Message });
            }
        }
    }
}
