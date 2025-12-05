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
    public class DepartmentLinksController : ControllerBase
    {
        private readonly DapperContext _context;

        public DepartmentLinksController(DapperContext context)
        {
            _context = context;
        }

        // GET: api/departmentlinks - Get department links visible to current user
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var userDepartmentId = User.Claims.FirstOrDefault(c => c.Type == "department_id")?.Value;

                if (string.IsNullOrEmpty(userDepartmentId))
                {
                    return Ok(new { success = true, links = new List<object>() });
                }

                using var connection = _context.CreateConnection();
                
                // Get links assigned to user's department
                var links = await connection.QueryAsync(
                    @"SELECT DISTINCT dl.id, dl.title, dl.icon, dl.url, dl.link_type as linkType, dl.order_index as orderIndex
                      FROM department_links dl
                      INNER JOIN department_link_assignments dla ON dl.id = dla.department_link_id
                      WHERE dl.active = 1 AND dla.department_id = @DepartmentId
                      ORDER BY dl.order_index",
                    new { DepartmentId = userDepartmentId }
                );

                return Ok(new { success = true, links });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch department links", error = ex.Message });
            }
        }

        // GET: api/departmentlinks/all - Get all department links with their assigned departments (Super Admin only)
        [HttpGet("all")]
        [RequirePermission("departmentlinks.create")]
        public async Task<IActionResult> GetAllWithDepartments()
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                // Get all links
                var linksDict = new Dictionary<int, DepartmentLinkWithDepartments>();
                
                await connection.QueryAsync<DepartmentLinkDto, int?, DepartmentLinkWithDepartments>(
                    @"SELECT dl.id, dl.title, dl.icon, dl.url, dl.link_type as linkType, dl.order_index as orderIndex, 
                             dla.department_id as departmentId
                      FROM department_links dl
                      LEFT JOIN department_link_assignments dla ON dl.id = dla.department_link_id
                      WHERE dl.active = 1
                      ORDER BY dl.order_index",
                    (link, deptId) =>
                    {
                        if (!linksDict.TryGetValue(link.Id, out var linkWithDepts))
                        {
                            linkWithDepts = new DepartmentLinkWithDepartments
                            {
                                Id = link.Id,
                                Title = link.Title,
                                Icon = link.Icon,
                                Url = link.Url,
                                LinkType = link.LinkType,
                                OrderIndex = link.OrderIndex,
                                DepartmentIds = new List<int>()
                            };
                            linksDict[link.Id] = linkWithDepts;
                        }
                        
                        if (deptId.HasValue && !linkWithDepts.DepartmentIds.Contains(deptId.Value))
                        {
                            linkWithDepts.DepartmentIds.Add(deptId.Value);
                        }
                        
                        return linkWithDepts;
                    },
                    splitOn: "departmentId"
                );

                return Ok(new { success = true, links = linksDict.Values.ToList() });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to fetch department links", error = ex.Message });
            }
        }

        // POST: api/departmentlinks - Create new department link (Super Admin only)
        [HttpPost]
        [RequirePermission("departmentlinks.create")]
        public async Task<IActionResult> Create([FromBody] DepartmentLinkCreateDto linkDto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(linkDto.Title) || string.IsNullOrWhiteSpace(linkDto.Url))
                {
                    return BadRequest(new { success = false, message = "Title and URL are required" });
                }

                if (linkDto.DepartmentIds == null || !linkDto.DepartmentIds.Any())
                {
                    return BadRequest(new { success = false, message = "At least one department must be selected" });
                }

                using var connection = _context.CreateConnection();
                connection.Open();
                using var transaction = connection.BeginTransaction();

                try
                {
                    // Get the highest order_index
                    var maxOrder = await connection.ExecuteScalarAsync<int?>(
                        "SELECT MAX(order_index) FROM department_links WHERE active = 1",
                        transaction: transaction
                    );
                    var newOrderIndex = (maxOrder ?? 0) + 1;

                    // Insert the link
                    var linkId = await connection.ExecuteScalarAsync<int>(
                        @"INSERT INTO department_links (title, icon, url, link_type, order_index, active, created_at, updated_at)
                          OUTPUT INSERTED.id
                          VALUES (@Title, @Icon, @Url, @LinkType, @OrderIndex, 1, GETDATE(), GETDATE())",
                        new
                        {
                            linkDto.Title,
                            Icon = linkDto.Icon ?? "mdi-link",
                            linkDto.Url,
                            LinkType = linkDto.LinkType ?? "internal",
                            OrderIndex = newOrderIndex
                        },
                        transaction: transaction
                    );

                    // Insert department assignments
                    foreach (var deptId in linkDto.DepartmentIds)
                    {
                        await connection.ExecuteAsync(
                            @"INSERT INTO department_link_assignments (department_link_id, department_id, created_at)
                              VALUES (@LinkId, @DepartmentId, GETDATE())",
                            new { LinkId = linkId, DepartmentId = deptId },
                            transaction: transaction
                        );
                    }

                    transaction.Commit();
                    return Ok(new { success = true, message = "Department link created successfully", linkId });
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to create department link", error = ex.Message });
            }
        }

        // PUT: api/departmentlinks/{id} - Update department link (Super Admin only)
        [HttpPut("{id}")]
        [RequirePermission("departmentlinks.update")]
        public async Task<IActionResult> Update(int id, [FromBody] DepartmentLinkCreateDto linkDto)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(linkDto.Title) || string.IsNullOrWhiteSpace(linkDto.Url))
                {
                    return BadRequest(new { success = false, message = "Title and URL are required" });
                }

                if (linkDto.DepartmentIds == null || !linkDto.DepartmentIds.Any())
                {
                    return BadRequest(new { success = false, message = "At least one department must be selected" });
                }

                using var connection = _context.CreateConnection();
                connection.Open();
                using var transaction = connection.BeginTransaction();

                try
                {
                    // Update the link
                    var rowsAffected = await connection.ExecuteAsync(
                        @"UPDATE department_links 
                          SET title = @Title, icon = @Icon, url = @Url, link_type = @LinkType, updated_at = GETDATE()
                          WHERE id = @Id AND active = 1",
                        new
                        {
                            Id = id,
                            linkDto.Title,
                            Icon = linkDto.Icon ?? "mdi-link",
                            linkDto.Url,
                            LinkType = linkDto.LinkType ?? "internal"
                        },
                        transaction: transaction
                    );

                    if (rowsAffected == 0)
                    {
                        transaction.Rollback();
                        return NotFound(new { success = false, message = "Department link not found" });
                    }

                    // Delete existing department assignments
                    await connection.ExecuteAsync(
                        "DELETE FROM department_link_assignments WHERE department_link_id = @LinkId",
                        new { LinkId = id },
                        transaction: transaction
                    );

                    // Insert new department assignments
                    foreach (var deptId in linkDto.DepartmentIds)
                    {
                        await connection.ExecuteAsync(
                            @"INSERT INTO department_link_assignments (department_link_id, department_id, created_at)
                              VALUES (@LinkId, @DepartmentId, GETDATE())",
                            new { LinkId = id, DepartmentId = deptId },
                            transaction: transaction
                        );
                    }

                    transaction.Commit();
                    return Ok(new { success = true, message = "Department link updated successfully" });
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to update department link", error = ex.Message });
            }
        }

        // DELETE: api/departmentlinks/{id} - Soft delete department link (Super Admin only)
        [HttpDelete("{id}")]
        [RequirePermission("departmentlinks.delete")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                using var connection = _context.CreateConnection();
                var rowsAffected = await connection.ExecuteAsync(
                    "UPDATE department_links SET active = 0, updated_at = GETDATE() WHERE id = @Id",
                    new { Id = id }
                );

                if (rowsAffected == 0)
                {
                    return NotFound(new { success = false, message = "Department link not found" });
                }

                return Ok(new { success = true, message = "Department link deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to delete department link", error = ex.Message });
            }
        }

        // POST: api/departmentlinks/reorder - Reorder department links (Super Admin only)
        [HttpPost("reorder")]
        [RequirePermission("departmentlinks.update")]
        public async Task<IActionResult> Reorder([FromBody] ReorderDto reorderDto)
        {
            try
            {
                using var connection = _context.CreateConnection();
                
                for (int i = 0; i < reorderDto.LinkIds.Count; i++)
                {
                    await connection.ExecuteAsync(
                        "UPDATE department_links SET order_index = @OrderIndex, updated_at = GETDATE() WHERE id = @Id",
                        new { Id = reorderDto.LinkIds[i], OrderIndex = i + 1 }
                    );
                }

                return Ok(new { success = true, message = "Department links reordered successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = "Failed to reorder department links", error = ex.Message });
            }
        }
    }

    // DTOs
    public class DepartmentLinkDto
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Icon { get; set; }
        public string Url { get; set; }
        public string LinkType { get; set; }
        public int OrderIndex { get; set; }
    }

    public class DepartmentLinkWithDepartments
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Icon { get; set; }
        public string Url { get; set; }
        public string LinkType { get; set; }
        public int OrderIndex { get; set; }
        public List<int> DepartmentIds { get; set; }
    }

    public class DepartmentLinkCreateDto
    {
        public string Title { get; set; }
        public string Icon { get; set; }
        public string Url { get; set; }
        public string LinkType { get; set; }
        public List<int> DepartmentIds { get; set; }
    }
}
