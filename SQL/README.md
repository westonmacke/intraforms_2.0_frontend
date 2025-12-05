# Microsoft SQL Server Express Docker Container

A containerized Microsoft SQL Server Express setup with automatic initialization scripts.

## Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/westonmacke/intraforms_2.0_SQL.git
cd intraforms_2.0_SQL
```

### 2. Setup Environment (Optional)
The project works with default settings, but you can customize by creating a `.env` file:

```bash
cp .env.example .env
# Edit .env with your preferred settings
```

**Default Connection Details:**
- Host: `localhost`
- Port: `1433`
- User: `sa`
- Password: `Skittles123!`
- Database: `SampleDB`

### 3. Start SQL Server
```bash
./start.sh
```

### 4. Check Status
```bash
./status.sh
```

### 5. Stop SQL Server
```bash
./stop.sh
```

## Environment Variables

- `MSSQL_SA_PASSWORD`: SA user password (default: `Skittles123!`)
- `MSSQL_PID`: Product ID (default: `Express`)
- `SQL_PORT`: Port to expose SQL Server on (default: `1433`)
- `DATA_PATH`: Path where database files will be stored (default: `./data`)

## Manual Docker Commands

```bash
# Build the image
docker-compose build

# Start the container
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

## Connect to SQL Server

```bash
# Using sqlcmd inside container
docker exec mssql-express /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Skittles123! -C

# Or connect via Azure Data Studio / SQL Server Management Studio
# Server: localhost,1433
# Authentication: SQL Server Authentication
# Login: sa
# Password: Skittles123! (or your custom password)
```

## GitHub Container Registry

### Prerequisites

1. Create a GitHub Personal Access Token (PAT) with `write:packages` scope
2. Log in to GitHub Container Registry:

```bash
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

### Manual Push to GitHub

```bash
# Build the image
docker build -t ghcr.io/YOUR_USERNAME/mssql-express:latest .

# Push to GitHub Container Registry
docker push ghcr.io/YOUR_USERNAME/mssql-express:latest

# Tag with version
docker tag ghcr.io/YOUR_USERNAME/mssql-express:latest ghcr.io/YOUR_USERNAME/mssql-express:v1.0.0
docker push ghcr.io/YOUR_USERNAME/mssql-express:v1.0.0
```

### Automated Push via GitHub Actions

The repository includes a GitHub Actions workflow that automatically:
- Builds the Docker image on push to main/master
- Pushes to GitHub Container Registry
- Creates version tags from git tags

To trigger automated deployment:

```bash
# Push to main branch
git push origin main

# Or create a version tag
git tag v1.0.0
git push origin v1.0.0
```

### Pull and Run from GitHub

```bash
# Pull the image
docker pull ghcr.io/YOUR_USERNAME/mssql-express:latest

# Run the container
docker run -d \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=YourStrong@Password123 \
  -p 1433:1433 \
  --name mssql \
  ghcr.io/YOUR_USERNAME/mssql-express:latest

# With persistent data
docker run -d \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=YourStrong@Password123 \
  -p 1433:1433 \
  -v $(pwd)/data:/var/opt/mssql/data \
  --name mssql \
  ghcr.io/YOUR_USERNAME/mssql-express:latest
```

## Customization

### Adding Initialization Scripts

Place `.sql` files in the `init-scripts/` directory. They will be executed in alphabetical order when the container starts.

Example:
- `01-create-database.sql` - Creates databases and schemas
- `02-create-tables.sql` - Creates tables
- `03-seed-data.sql` - Inserts initial data

### Modifying SQL Paths

Edit the `Dockerfile` and `entrypoint.sh` to change:
- Script location: Change `/usr/src/app/init-scripts/` to your preferred path
- Working directory: Modify `WORKDIR` directive

### Changing SA Password

**Important**: Never commit passwords to version control!

1. Update password in `.env` file (not tracked by git)
2. Or pass as environment variable when running:

```bash
docker run -e MSSQL_SA_PASSWORD=NewPassword123! ...
```

## Troubleshooting

### Container won't start

Check logs:
```bash
docker-compose logs mssql
```

Common issues:
- Weak password (must meet complexity requirements)
- Port 1433 already in use
- Insufficient memory (SQL Server needs at least 2GB)

### Reset database

```bash
# Stop and remove container
docker-compose down

# Remove data directory
rm -rf ./data

# Start fresh
docker-compose up -d
```

## License

This project uses Microsoft SQL Server which requires accepting the EULA. See [Microsoft's SQL Server License](https://go.microsoft.com/fwlink/?linkid=857698).
