# ForfaitCanada — Supabase + Vercel Setup Guide

Complete setup in ~30 minutes. No framework needed.

---

## STEP 1 — Set up your Supabase database

1. Go to https://supabase.com and open your project
2. Click **SQL Editor** in the left sidebar
3. Click **New Query**
4. Open the file `supabase-schema.sql` and paste the entire contents
5. Click **Run** (green button)
6. You should see: `table_name` with `leads` listed at the bottom ✅

---

## STEP 2 — Get your Supabase credentials

1. In Supabase, go to **Project Settings** → **API**
2. Copy these two values — you'll need them in Step 4:

   | Variable name                | Where to find it              |
   |------------------------------|-------------------------------|
   | `SUPABASE_URL`               | "Project URL" section         |
   | `SUPABASE_SERVICE_ROLE_KEY`  | "Project API keys" → service_role (secret) |

   ⚠️ Use the **service_role** key (not the anon key) — it bypasses RLS so your API can write to the DB.
   ⚠️ NEVER put the service_role key in your frontend HTML. It only lives in Vercel env vars.

---

## STEP 3 — Set up your Vercel project structure

Your project folder should look like this:

```
forfaitcanada/
├── index.html          ← your main site file (the updated one)
├── api/
│   └── submit-lead.js  ← the serverless function
└── package.json        ← needed for the Supabase SDK (see below)
```

Create a `package.json` file in your project root:

```json
{
  "name": "forfaitcanada",
  "version": "1.0.0",
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0"
  }
}
```

Then in your terminal (local or Vercel CLI):
```bash
npm install
```

---

## STEP 4 — Add environment variables to Vercel

1. Go to https://vercel.com → your project → **Settings** → **Environment Variables**
2. Add these two variables:

   | Name                        | Value                        | Environment        |
   |-----------------------------|------------------------------|--------------------|
   | `SUPABASE_URL`              | https://xxxxx.supabase.co    | Production, Preview, Development |
   | `SUPABASE_SERVICE_ROLE_KEY` | eyJhbGci...                  | Production, Preview, Development |

3. Click **Save** for each one
4. **Redeploy** your project (Vercel → Deployments → ... → Redeploy)

---

## STEP 5 — Deploy

Push your updated files to GitHub (or drag & drop in Vercel dashboard):

```
index.html          ← updated version with real API call
api/submit-lead.js  ← new serverless function
package.json        ← new file with Supabase dependency
```

Vercel will automatically detect the `/api` folder and deploy `submit-lead.js`
as a serverless function at the URL: `https://yoursite.vercel.app/api/submit-lead`

---

## STEP 6 — Test it

1. Visit your live site
2. Fill in the form and submit
3. Go to Supabase → **Table Editor** → **leads**
4. You should see your test lead appear as a new row ✅

---

## STEP 7 — View your leads in Supabase

Go to **Table Editor** → **leads** to see all submissions with:
- Full name, email, phone, postal code
- Service type (internet, mobile, TV, etc.)
- Current provider
- Language (fr/en)
- Status (new by default)
- Timestamp

You can also run quick queries in the SQL Editor:

```sql
-- See all new leads
SELECT * FROM leads WHERE status = 'new' ORDER BY created_at DESC;

-- Count leads by service type
SELECT * FROM leads_by_service;

-- Count leads by day
SELECT * FROM leads_per_day;
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `405 Method not allowed` | Make sure form is doing a POST, not GET |
| `Database error` in response | Check Supabase logs: Dashboard → Logs → API |
| `Cannot find module '@supabase/supabase-js'` | Run `npm install` and redeploy |
| Lead not appearing in table | Check that RLS policy was created correctly in Step 1 |
| Environment variable not found | Redeploy after adding env vars — they don't auto-apply |

---

## What's next — Admin Dashboard (Phase 2)

Once leads are flowing in, the next step is building a login-protected admin
dashboard where you (or your team) can:

- See all leads in a table
- Filter by status, service type, region
- Mark leads as contacted / converted
- Export to CSV
- Get email notifications on new leads

This will be built as a separate protected page using Supabase Auth.
Ask when you're ready and I'll build it.
