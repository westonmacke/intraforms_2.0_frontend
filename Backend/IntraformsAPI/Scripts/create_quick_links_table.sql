-- Create quick_links table for managing navigation links
-- Run this script in your SampleDB database

CREATE TABLE quick_links (
    id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(100) NOT NULL,
    icon NVARCHAR(100) NOT NULL DEFAULT 'mdi-link',
    url NVARCHAR(500) NOT NULL,
    link_type NVARCHAR(20) NOT NULL DEFAULT 'internal', -- 'internal' or 'external'
    order_index INT NOT NULL DEFAULT 0,
    active BIT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT CK_link_type CHECK (link_type IN ('internal', 'external'))
);

-- Create index on order_index for efficient sorting
CREATE INDEX IX_quick_links_order ON quick_links(order_index, active);

-- Insert default quick links
INSERT INTO quick_links (title, icon, url, link_type, order_index, active)
VALUES 
    ('Intraforms', 'mdi-file-document-multiple', '/intraforms', 'internal', 1, 1),
    ('Security Administration', 'mdi-shield-lock', '/security', 'internal', 2, 1);

-- Select to verify
SELECT * FROM quick_links ORDER BY order_index;
