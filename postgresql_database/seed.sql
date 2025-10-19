-- Seed data for Site Verification and Workflow Management
-- This script is idempotent-safe via INSERT ... ON CONFLICT and conditional checks
-- Assumes Django migrations will create auth tables and application tables:
--   sites(id, name, address, status, created_at, updated_at)
--   workflow_steps(id, site_id, name, "order", status, due_date, completed_at)
--   verifications(id, site_id, initiated_by, result, notes, created_at, completed_at)
--   audit_logs(id, actor_id, action, entity_type, entity_id, metadata, created_at)

-- Note: If these tables do not exist yet, the inserts will fail. Run after migrations.

-- Create minimal roles if not already present (optional)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'appuser') THEN
    CREATE ROLE appuser LOGIN PASSWORD 'dbuser123';
  END IF;
END $$;

-- Ensure public schema grants (safe if already set)
GRANT USAGE ON SCHEMA public TO appuser;
GRANT CREATE ON SCHEMA public TO appuser;

-- Insert sample sites
INSERT INTO sites (id, name, address, status, created_at, updated_at)
VALUES
  (1, 'Downtown Office', '123 Main St, Cityville', 'pending', NOW(), NOW()),
  (2, 'Warehouse 7', '45 Industrial Rd, Factorytown', 'in_progress', NOW(), NOW()),
  (3, 'Remote Tower', 'Hilltop Sector 9, Highlands', 'approved', NOW(), NOW())
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name,
    address = EXCLUDED.address,
    status = EXCLUDED.status,
    updated_at = NOW();

-- Insert workflow steps for site 1
INSERT INTO workflow_steps (id, site_id, name, "order", status, due_date, completed_at)
VALUES
  (101, 1, 'Initial Inspection', 1, 'completed', NOW() - INTERVAL '7 days', NOW() - INTERVAL '6 days'),
  (102, 1, 'Compliance Check', 2, 'in_progress', NOW() + INTERVAL '3 days', NULL),
  (103, 1, 'Final Approval', 3, 'pending', NOW() + INTERVAL '10 days', NULL)
ON CONFLICT (id) DO UPDATE
SET site_id = EXCLUDED.site_id,
    name = EXCLUDED.name,
    "order" = EXCLUDED."order",
    status = EXCLUDED.status,
    due_date = EXCLUDED.due_date,
    completed_at = EXCLUDED.completed_at;

-- Insert workflow steps for site 2
INSERT INTO workflow_steps (id, site_id, name, "order", status, due_date, completed_at)
VALUES
  (201, 2, 'Safety Review', 1, 'in_progress', NOW() + INTERVAL '5 days', NULL),
  (202, 2, 'Equipment Check', 2, 'pending', NOW() + INTERVAL '9 days', NULL)
ON CONFLICT (id) DO UPDATE
SET site_id = EXCLUDED.site_id,
    name = EXCLUDED.name,
    "order" = EXCLUDED."order",
    status = EXCLUDED.status,
    due_date = EXCLUDED.due_date,
    completed_at = EXCLUDED.completed_at;

-- Insert verifications
-- initiated_by references a user id; using 1 as a placeholder if Django auth_user has such an ID
-- If auth_user table exists and user 1 doesn't exist, adjust as needed.
INSERT INTO verifications (id, site_id, initiated_by, result, notes, created_at, completed_at)
VALUES
  (301, 1, 1, 'pass', 'All checks passed with minor notes.', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
  (302, 2, 1, 'pending', 'Awaiting equipment list.', NOW() - INTERVAL '1 days', NULL)
ON CONFLICT (id) DO UPDATE
SET site_id = EXCLUDED.site_id,
    initiated_by = EXCLUDED.initiated_by,
    result = EXCLUDED.result,
    notes = EXCLUDED.notes,
    created_at = EXCLUDED.created_at,
    completed_at = EXCLUDED.completed_at;

-- Insert audit logs
-- actor_id references auth_user.id; using 1 as a placeholder
INSERT INTO audit_logs (id, actor_id, action, entity_type, entity_id, metadata, created_at)
VALUES
  (401, 1, 'create', 'site', 1, '{"source":"seed"}', NOW() - INTERVAL '7 days'),
  (402, 1, 'update', 'workflow_step', 102, '{"status":"in_progress"}', NOW() - INTERVAL '2 days'),
  (403, 1, 'verify', 'site', 1, '{"result":"pass"}', NOW() - INTERVAL '5 days')
ON CONFLICT (id) DO UPDATE
SET actor_id = EXCLUDED.actor_id,
    action = EXCLUDED.action,
    entity_type = EXCLUDED.entity_type,
    entity_id = EXCLUDED.entity_id,
    metadata = EXCLUDED.metadata,
    created_at = EXCLUDED.created_at;

-- Optional check messages
DO $$
BEGIN
  RAISE NOTICE 'Seed data applied for sites, workflow_steps, verifications, and audit_logs';
EXCEPTION WHEN others THEN
  RAISE NOTICE 'Seeding encountered an error. Ensure tables exist via Django migrations.';
END $$;
