# Intraforms Backend API

ASP.NET Core 8.0 Web API with JWT authentication and SQL Server integration.

## 🚀 Quick Start

### Prerequisites
- .NET 8.0 SDK or higher
- SQL Server running on localhost:1433
- Database: SampleDB (with users, roles, permissions tables)

### Installation

```bash
cd Backend/IntraformsAPI
dotnet restore
dotnet build
```

### Configuration

The API is configured via `appsettings.json`:

- **Connection String**: Points to `localhost,1433` with database `SampleDB`
- **JWT Settings**: Secret keys (change in production!)
- **CORS**: Allows `http://localhost:3000` and `https://localhost:3000`

### Running the API

```bash
# Run in development mode
dotnet run

# Or run in watch mode (auto-reload)
dotnet watch run

# Or run in background
nohup dotnet run > /tmp/intraforms_api.log 2>&1 &
```

The API will start on: **https://localhost:5001**

### HTTPS Certificate

Trust the development certificate:

```bash
dotnet dev-certs https --trust
```

## 📡 API Endpoints

### Health Check
```bash
curl -k https://localhost:5001/api/health
```

### Authentication

**Login**
```bash
curl -k -X POST https://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin123!"}'
```

**Refresh Token**
```bash
curl -k -X POST https://localhost:5001/api/auth/refresh \
  -H "Authorization: Bearer YOUR_REFRESH_TOKEN"
```

### Users (Protected - Requires JWT)

**Get All Users**
```bash
curl -k https://localhost:5001/api/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Get User By ID**
```bash
curl -k https://localhost:5001/api/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 🧪 Test Accounts

From the database seed data:

| Username | Password | Role |
|----------|----------|------|
| admin | Admin123! | Super Administrator |
| formadmin | Admin123! | Form Administrator |
| creator | Admin123! | Form Creator |
| viewer | Admin123! | Form Viewer |

## 📚 Swagger Documentation

Access the Swagger UI at: https://localhost:5001/swagger

## 🔧 Troubleshooting

### Cannot connect to SQL Server
```bash
# Verify SQL Server is running
# Check connection string in appsettings.json
```

### CORS Errors
```bash
# Verify frontend URL in appsettings.json matches your Vue app
```

### JWT Token Errors
```bash
# Ensure JWT:Secret is at least 32 characters
# Check token expiration settings
```

## 🏗️ Project Structure

```
Backend/IntraformsAPI/
├── Controllers/
│   ├── AuthController.cs      # Login, refresh endpoints
│   └── UsersController.cs     # User management endpoints
├── Models/
│   ├── LoginRequest.cs
│   └── AuthResponse.cs
├── Services/
│   ├── IAuthService.cs
│   ├── AuthService.cs
│   ├── IUserService.cs
│   └── UserService.cs
├── Data/
│   └── DapperContext.cs       # Database connection
├── Helpers/
│   ├── JwtHelper.cs           # JWT token generation
│   └── PasswordHelper.cs      # Password hashing with BCrypt
├── Middleware/
│   └── PermissionMiddleware.cs # Permission-based authorization
├── Program.cs                 # Main entry point
└── appsettings.json          # Configuration
```

## 📦 NuGet Packages

- Microsoft.Data.SqlClient
- Dapper
- Microsoft.AspNetCore.Authentication.JwtBearer
- BCrypt.Net-Next
- System.IdentityModel.Tokens.Jwt
- Swashbuckle.AspNetCore

## 🚀 Deployment

For production deployment to IIS:

```bash
dotnet publish -c Release -o ./publish
```

Then copy the publish folder to your IIS server and configure as per the main BACKEND_GUIDE.md.

---

**Backend API is running and ready to connect with the Vue frontend!** 🎉
