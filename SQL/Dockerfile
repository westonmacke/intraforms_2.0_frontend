# Use the official Microsoft SQL Server 2022 Express image
FROM mcr.microsoft.com/mssql/server:2022-latest

# Set environment variables
ENV ACCEPT_EULA=Y
ENV MSSQL_SA_PASSWORD=Skittles123!
ENV MSSQL_PID=Express

# Create directory for initialization scripts
USER root
RUN mkdir -p /docker-entrypoint-initdb.d
WORKDIR /

# Copy initialization scripts
COPY ./init-scripts/ /docker-entrypoint-initdb.d/
COPY ./entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Expose SQL Server port
EXPOSE 1433

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
