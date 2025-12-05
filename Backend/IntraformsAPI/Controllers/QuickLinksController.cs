using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using IntraformsAPI.Data;
using IntraformsAPI.Middleware;
using IntraformsAPI.Models;
using Dapper;

namespace IntraformsAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class QuickLinksController : ControllerBase
    {
        private readonly DapperContext _context;

        public QuickLinksController(DapperContext context)
        {
            _context = context;
        }

        // GET: api/quicklinks - Get all active quick links (available to all authenticated users)
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                using var connection = _context.CreateConnection();
                var links = await connection.QueryAsync(
                    @"SELECT id, title, icon, url, link_type as linkType, order_index as orderIndex, active 
                      FROM quick_links 
                      WHERE active = 1 
                      ORDER BY order_index"
                );

                return Ok(new { success = true, links });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch quick links", error = ex.Message });
            }
        }

        // POST: api/quicklinks - Create new quick link (Super Admin only)
        [HttpPost]
        [RequirePermission("quicklinks.create")]
        public async Task<IActionResult> Create([FromBody] QuickLinkDto linkDto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(linkDto.Title) || string.IsNullOrWhiteSpace(linkDto.Url))
                {
                    return BadRequest(new { success = false, message = "Title and URL are required" });
                }

                using var connection = _context.CreateConnection();
                
                // Get max order_index
                var maxOrder = await connection.ExecuteScalarAsync<int?>(
                    "SELECT MAX(order_index) FROM quick_links"
                ) ?? 0;

                var id = await connection.ExecuteScalarAsync<int>(
                    @"INSERT INTO quick_links (title, icon, url, link_type, order_index, active) 
                      OUTPUT INSERTED.id
                      VALUES (@Title, @Icon, @Url, @LinkType, @OrderIndex, 1)",
                    new 
                    { 
                        linkDto.Title, 
                        Icon = linkDto.Icon ?? "mdi-link",
                        linkDto.Url, 
                        LinkType = linkDto.LinkType ?? "internal",
                        OrderIndex = maxOrder + 1
                    }
                );

                return Ok(new { success = true, message = "Quick link created", id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to create quick link", error = ex.Message });
            }
        }

        // PUT: api/quicklinks/{id} - Update quick link (Super Admin only)
        [HttpPut("{id}")]
        [RequirePermission("quicklinks.update")]
        public async Task<IActionResult> Update(int id, [FromBody] QuickLinkDto linkDto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(linkDto.Title) || string.IsNullOrWhiteSpace(linkDto.Url))
                {
                    return BadRequest(new { success = false, message = "Title and URL are required" });
                }

                using var connection = _context.CreateConnection();
                
                var rowsAffected = await connection.ExecuteAsync(
                    @"UPDATE quick_links 
                      SET title = @Title, 
                          icon = @Icon, 
                          url = @Url, 
                          link_type = @LinkType,
                          updated_at = GETDATE()
                      WHERE id = @Id",
                    new 
                    { 
                        Id = id,
                        linkDto.Title, 
                        Icon = linkDto.Icon ?? "mdi-link",
                        linkDto.Url, 
                        LinkType = linkDto.LinkType ?? "internal"
                    }
                );

                if (rowsAffected == 0)
                {
                    return NotFound(new { success = false, message = "Quick link not found" });
                }

                return Ok(new { success = true, message = "Quick link updated" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to update quick link", error = ex.Message });
            }
        }

        // DELETE: api/quicklinks/{id} - Soft delete quick link (Super Admin only)
        [HttpDelete("{id}")]
        [RequirePermission("quicklinks.delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                // Soft delete by setting active = 0
                var rowsAffected = await connection.ExecuteAsync(
                    "UPDATE quick_links SET active = 0, updated_at = GETDATE() WHERE id = @Id",
                    new { Id = id }
                );

                if (rowsAffected == 0)
                {
                    return NotFound(new { success = false, message = "Quick link not found" });
                }

                return Ok(new { success = true, message = "Quick link deleted" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to delete quick link", error = ex.Message });
            }
        }

        // POST: api/quicklinks/reorder - Reorder quick links (Super Admin only)
        [HttpPost("reorder")]
        [RequirePermission("quicklinks.update")]
        public async Task<IActionResult> Reorder([FromBody] ReorderDto reorderDto)
        {
            try
            {
                if (reorderDto.LinkIds == null || !reorderDto.LinkIds.Any())
                {
                    return BadRequest(new { success = false, message = "Link IDs are required" });
                }

                using var connection = _context.CreateConnection();
                
                // Update order_index for each link
                for (int i = 0; i < reorderDto.LinkIds.Count; i++)
                {
                    await connection.ExecuteAsync(
                        "UPDATE quick_links SET order_index = @OrderIndex WHERE id = @Id",
                        new { Id = reorderDto.LinkIds[i], OrderIndex = i + 1 }
                    );
                }

                return Ok(new { success = true, message = "Quick links reordered" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to reorder quick links", error = ex.Message });
            }
        }
    }

    public class QuickLinkDto
    {
        public string Title { get; set; }
        public string Icon { get; set; }
        public string Url { get; set; }
        public string LinkType { get; set; }
    }
}
