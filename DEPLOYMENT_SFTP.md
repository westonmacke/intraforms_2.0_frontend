# SFTP Deployment to IIS with IP Whitelisting

This guide explains how to set up automated SFTP deployment from GitHub Actions to your Windows Server 2022 IIS with IP whitelisting for security.

## Overview

- **Deployment Method**: SFTP (SSH File Transfer Protocol)
- **Security**: IP Whitelist on Windows Firewall
- **Automation**: GitHub Actions deploys on every push to main
- **Manual Option**: Script available for Mac deployment

---

## Windows Server 2022 Setup

### Step 1: Install OpenSSH Server

Windows Server 2022 has OpenSSH built-in:

```powershell
# Run PowerShell as Administrator

# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the service
Start-Service sshd

# Set to start automatically
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the service is running
Get-Service sshd
```

### Step 2: Configure SFTP Access

```powershell
# Create or identify the deployment user
# Option 1: Use existing IIS user
# Option 2: Create dedicated user
net user sftpuser YourSecurePassword123! /add
net localgroup Administrators sftpuser /add

# Set up the web root permissions
$webRoot = "C:\inetpub\wwwroot\intraforms"
New-Item -Path $webRoot -ItemType Directory -Force

# Grant permissions to the SFTP user
$acl = Get-Acl $webRoot
$permission = "sftpuser","FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $webRoot $acl
```

### Step 3: Configure Windows Firewall with IP Whitelist

This is the critical security step - only allow GitHub Actions and your Mac to connect:

```powershell
# Get GitHub Actions IP ranges (they publish these)
# Current GitHub Actions IP ranges (check https://api.github.com/meta for latest)

# Remove any existing SSH rules
Remove-NetFirewallRule -DisplayName "OpenSSH SSH Server (sshd)" -ErrorAction SilentlyContinue

# Create new rule with IP whitelist
# Example: Allow GitHub Actions and your Mac IP
$allowedIPs = @(
    "192.30.252.0/22",    # GitHub Actions IP range 1
    "185.199.108.0/22",   # GitHub Actions IP range 2
    "140.82.112.0/20",    # GitHub Actions IP range 3
    "143.55.64.0/20",     # GitHub Actions IP range 4
    "20.201.28.151/32",   # GitHub Actions IP range 5
    "20.205.243.166/32",  # GitHub Actions IP range 6
    "YOUR.MAC.IP.HERE/32" # Your Mac's public IP (get from https://ipify.org)
)

New-NetFirewallRule -Name "SFTP-Whitelist" `
    -DisplayName "SFTP Server (IP Whitelist)" `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -Action Allow `
    -LocalPort 22 `
    -RemoteAddress $allowedIPs

# Verify the rule
Get-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)" | Get-NetFirewallAddressFilter
```

### Step 4: Get Current GitHub Actions IP Ranges

GitHub publishes their IP ranges. Get the latest:

```powershell
# Download current GitHub Actions IP ranges
Invoke-RestMethod -Uri "https://api.github.com/meta" | 
    Select-Object -ExpandProperty actions | 
    ForEach-Object { Write-Host $_ }
```

Or visit: https://api.github.com/meta

Update your firewall rule with these IPs.

### Step 5: Get Your Mac's Public IP

From your Mac terminal:
```bash
curl https://api.ipify.org
```

Add this IP to the whitelist above.

### Step 6: Test SFTP Connection

From your Mac:
```bash
# Test SFTP connection
sftp -P 22 sftpuser@your-server-ip

# If connected successfully, try listing directory
ls

# Exit
exit
```

---

## GitHub Repository Setup

### Configure GitHub Secrets

Go to your GitHub repository: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Add these secrets:

1. **SFTP_HOST**
   - Value: Your Windows Server IP or hostname (e.g., `192.168.1.100`)

2. **SFTP_PORT**
   - Value: `22`

3. **SFTP_USERNAME**
   - Value: `sftpuser` (or your deployment user)

4. **SFTP_PASSWORD**
   - Value: Your secure password

5. **SFTP_REMOTE_PATH**
   - Value: `/c/inetpub/wwwroot/intraforms` or `C:\\inetpub\\wwwroot\\intraforms`

---

## How It Works

### Automated Deployment (GitHub Actions)

1. You push code to `main` branch
2. GitHub Actions workflow triggers
3. Builds your Vue app (`npm run build`)
4. Connects to your server via SFTP (only allowed IPs can connect)
5. Uploads `dist/` folder to your IIS directory
6. Your site is live!

### Manual Deployment (From Mac)

Use the provided script:
```bash
./deploy_sftp.sh
```

---

## Security Features

✅ **IP Whitelisting**: Only GitHub Actions and your Mac can connect
✅ **SSH Protocol**: Encrypted file transfers
✅ **Strong Authentication**: Username + password
✅ **Windows Firewall**: Hardware-level protection
✅ **No Public Access**: SSH port not open to internet

---

## Updating IP Whitelist

### Add Your Home/Office IP

```powershell
# Add another IP to existing rule
$newIP = "NEW.IP.ADDRESS.HERE/32"
$rule = Get-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)"
$currentIPs = ($rule | Get-NetFirewallAddressFilter).RemoteAddress
$updatedIPs = $currentIPs + $newIP

Set-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)" -RemoteAddress $updatedIPs
```

### Update GitHub Actions IPs (Do Monthly)

```powershell
# Get latest GitHub IPs
$githubMeta = Invoke-RestMethod -Uri "https://api.github.com/meta"
$githubIPs = $githubMeta.actions

# Add your Mac IP
$yourMacIP = "YOUR.MAC.IP.HERE/32"
$allAllowedIPs = $githubIPs + $yourMacIP

# Update firewall rule
Set-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)" -RemoteAddress $allAllowedIPs

Write-Host "Firewall updated with latest GitHub Actions IPs"
```

---

## Testing Deployment

### Test Locally First

```bash
# Build locally
npm run build

# Test the build
npm run preview

# Deploy manually
./deploy_sftp.sh
```

### Test GitHub Actions

1. Make a small change (e.g., update README)
2. Commit and push to `main`:
   ```bash
   git add .
   git commit -m "Test deployment"
   git push origin main
   ```
3. Go to GitHub → Actions tab
4. Watch the workflow run
5. Check your IIS site

---

## Troubleshooting

### Connection Refused

**Problem**: Cannot connect via SFTP

**Solutions**:
```powershell
# 1. Check if SSH service is running
Get-Service sshd

# 2. Check firewall rule
Get-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)"

# 3. Verify your IP is whitelisted
# Get your current IP
curl https://api.ipify.org

# Check if it's in the whitelist
Get-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)" | 
    Get-NetFirewallAddressFilter | 
    Select-Object -ExpandProperty RemoteAddress
```

### Permission Denied

**Problem**: Can connect but cannot upload files

**Solutions**:
```powershell
# Check folder permissions
$webRoot = "C:\inetpub\wwwroot\intraforms"
Get-Acl $webRoot | Format-List

# Grant full control to SFTP user
$acl = Get-Acl $webRoot
$permission = "sftpuser","FullControl","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $webRoot $acl
```

### GitHub Actions Failing

**Problem**: GitHub Actions workflow fails to connect

**Solutions**:
1. Verify GitHub Secrets are set correctly
2. Check GitHub Actions IPs are whitelisted
3. Test connection manually from another IP to verify server is working
4. Check GitHub Actions logs for specific error

**Get detailed logs**:
- Go to GitHub → Actions → Click failed workflow
- Expand "Deploy to IIS via SFTP" step
- Look for connection errors

### Mac Cannot Connect

**Problem**: Manual deployment from Mac fails

**Solutions**:
```bash
# 1. Get your current public IP
curl https://api.ipify.org

# 2. Test basic connectivity
ping your-server-ip

# 3. Test SSH port
nc -zv your-server-ip 22

# 4. Try verbose SFTP connection
sftp -vvv -P 22 sftpuser@your-server-ip
```

If connection times out, your IP is likely not whitelisted.

---

## Advanced: Dynamic IP Handling

If your Mac has a dynamic IP that changes frequently:

### Option 1: Use VPN with Static IP
- Connect to VPN with static IP
- Whitelist the VPN's IP

### Option 2: Allow Broader Range
```powershell
# Allow your ISP's IP range (less secure)
$yourIPRange = "YOUR.ISP.RANGE.0/24"
# Add to whitelist
```

### Option 3: Use Dynamic DNS + Script
- Set up dynamic DNS for your Mac
- Create script to auto-update whitelist

---

## Monitoring

### Check Recent SFTP Connections

```powershell
# View SSH/SFTP logs
Get-WinEvent -LogName "Microsoft-Windows-OpenSSH/Operational" -MaxEvents 50
```

### Check Deployment History

- GitHub: Repository → Actions → View workflow runs
- Windows: Check IIS logs in `C:\inetpub\logs\LogFiles`

---

## Security Best Practices

1. ✅ **Use IP Whitelisting** (configured above)
2. ✅ **Use Strong Passwords** (minimum 16 characters)
3. ✅ **Update GitHub IPs Monthly** (they change occasionally)
4. ✅ **Monitor Logs** (check for unauthorized attempts)
5. ✅ **Limit User Permissions** (only what's needed for deployment)
6. ✅ **Use Secrets** (never commit credentials)
7. ✅ **Regular Backups** (before deployments)

---

## Quick Reference Commands

### Windows Server

```powershell
# Start SSH service
Start-Service sshd

# Stop SSH service
Stop-Service sshd

# Check firewall rule
Get-NetFirewallRule -DisplayName "SFTP Server (IP Whitelist)"

# View recent connections
Get-WinEvent -LogName "Microsoft-Windows-OpenSSH/Operational" -MaxEvents 10
```

### Mac (Your Machine)

```bash
# Get your IP
curl https://api.ipify.org

# Test connection
sftp -P 22 sftpuser@server-ip

# Deploy manually
./deploy_sftp.sh

# Deploy via Git
git push origin main
```

---

## Additional Resources

- [GitHub Actions IP Ranges](https://api.github.com/meta)
- [OpenSSH Server on Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)
- [Windows Firewall Configuration](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/)

---

## Need Help?

1. Check Windows Event Viewer: `eventvwr.msc`
2. Check GitHub Actions logs
3. Verify IPs are whitelisted
4. Test SFTP connection manually
5. Check folder permissions on Windows
