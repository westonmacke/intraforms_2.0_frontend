-- Grant Quick Links permissions to Super Admin role
-- Run this script after creating the quick_links table

-- Get the Super Admin role ID
DECLARE @SuperAdminRoleId INT
SELECT @SuperAdminRoleId = id FROM roles WHERE name = 'Super Admin'

-- Check if permissions already exist, if not insert them
IF NOT EXISTS (SELECT 1 FROM permissions WHERE name = 'quicklinks.create')
BEGIN
    INSERT INTO permissions (name, resource, action, description)
    VALUES ('quicklinks.create', 'quicklinks', 'create', 'Create new quick links')
END

IF NOT EXISTS (SELECT 1 FROM permissions WHERE name = 'quicklinks.update')
BEGIN
    INSERT INTO permissions (name, resource, action, description)
    VALUES ('quicklinks.update', 'quicklinks', 'update', 'Update existing quick links')
END

IF NOT EXISTS (SELECT 1 FROM permissions WHERE name = 'quicklinks.delete')
BEGIN
    INSERT INTO permissions (name, resource, action, description)
    VALUES ('quicklinks.delete', 'quicklinks', 'delete', 'Delete quick links')
END

-- Get the permission IDs
DECLARE @CreatePermId INT, @UpdatePermId INT, @DeletePermId INT

SELECT @CreatePermId = id FROM permissions WHERE name = 'quicklinks.create'
SELECT @UpdatePermId = id FROM permissions WHERE name = 'quicklinks.update'
SELECT @DeletePermId = id FROM permissions WHERE name = 'quicklinks.delete'

-- Check if role_permissions already exist before inserting
IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = @SuperAdminRoleId AND permission_id = @CreatePermId)
BEGIN
    INSERT INTO role_permissions (role_id, permission_id)
    VALUES (@SuperAdminRoleId, @CreatePermId)
END

IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = @SuperAdminRoleId AND permission_id = @UpdatePermId)
BEGIN
    INSERT INTO role_permissions (role_id, permission_id)
    VALUES (@SuperAdminRoleId, @UpdatePermId)
END

IF NOT EXISTS (SELECT 1 FROM role_permissions WHERE role_id = @SuperAdminRoleId AND permission_id = @DeletePermId)
BEGIN
    INSERT INTO role_permissions (role_id, permission_id)
    VALUES (@SuperAdminRoleId, @DeletePermId)
END

-- Verify permissions were granted
SELECT 
    r.name AS role_name,
    p.name AS permission,
    p.description
FROM role_permissions rp
JOIN roles r ON rp.role_id = r.id
JOIN permissions p ON rp.permission_id = p.id
WHERE r.name = 'Super Admin' AND p.name LIKE 'quicklinks.%';
