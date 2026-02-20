-- ============================================================
-- ForfaitCanada — Supabase Database Setup
-- Run this entire script in your Supabase SQL Editor
-- Dashboard → SQL Editor → New Query → Paste → Run
-- ============================================================


-- ── 1. LEADS TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leads (
  id               BIGSERIAL PRIMARY KEY,
  first_name       TEXT        NOT NULL,
  last_name        TEXT        NOT NULL,
  email            TEXT        NOT NULL,
  phone            TEXT        NOT NULL,
  postal_code      TEXT        NOT NULL,
  service_type     TEXT        NOT NULL DEFAULT 'internet',
  -- Possible values: internet | mobile | tv | landline | bundle | business
  current_provider TEXT,
  language         TEXT        NOT NULL DEFAULT 'fr',
  -- Possible values: fr | en
  status           TEXT        NOT NULL DEFAULT 'new',
  -- Possible values: new | contacted | converted | closed
  source           TEXT        NOT NULL DEFAULT 'website',
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ── 2. AUTO-UPDATE updated_at ON EVERY CHANGE ───────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ── 3. INDEXES FOR FAST QUERIES ─────────────────────────────
CREATE INDEX idx_leads_email       ON leads(email);
CREATE INDEX idx_leads_status      ON leads(status);
CREATE INDEX idx_leads_created_at  ON leads(created_at DESC);
CREATE INDEX idx_leads_service     ON leads(service_type);
CREATE INDEX idx_leads_postal      ON leads(postal_code);


-- ── 4. ROW LEVEL SECURITY ───────────────────────────────────
-- Enables RLS so the anon key CANNOT read/write leads directly
-- Only your service_role key (used in the API) can write
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- Block all public access (anon/authenticated roles)
-- Your API uses service_role which bypasses RLS entirely
CREATE POLICY "No public access" ON leads
  FOR ALL
  TO anon, authenticated
  USING (false);


-- ── 5. USEFUL VIEWS FOR YOUR FUTURE ADMIN DASHBOARD ─────────

-- Daily lead count
CREATE VIEW leads_per_day AS
  SELECT
    DATE(created_at) AS day,
    COUNT(*)         AS total_leads
  FROM leads
  GROUP BY DATE(created_at)
  ORDER BY day DESC;

-- Leads by service type
CREATE VIEW leads_by_service AS
  SELECT
    service_type,
    COUNT(*) AS total
  FROM leads
  GROUP BY service_type
  ORDER BY total DESC;

-- Leads by status
CREATE VIEW leads_by_status AS
  SELECT
    status,
    COUNT(*) AS total
  FROM leads
  GROUP BY status
  ORDER BY total DESC;

-- Recent leads (last 50) — useful for admin dashboard
CREATE VIEW recent_leads AS
  SELECT
    id,
    first_name,
    last_name,
    email,
    phone,
    postal_code,
    service_type,
    current_provider,
    language,
    status,
    created_at
  FROM leads
  ORDER BY created_at DESC
  LIMIT 50;


-- ── 6. VERIFY SETUP ─────────────────────────────────────────
-- Run this after to confirm everything was created:
SELECT 
  table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
