using IntraformsAPI.Models;

namespace IntraformsAPI.Services
{
    public interface IUserService
    {
        Task<List<object>> GetAllUsersAsync();
        Task<object> GetUserByIdAsync(int userId);
    }
}
