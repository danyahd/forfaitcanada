// api/submit-lead.js
// Vercel Serverless Function — receives form POST, saves to Supabase
// Deploy this file at: /api/submit-lead.js in your Vercel project root

import { createClient } from '@supabase/supabase-js';

// These come from your Vercel Environment Variables (never hardcode them)
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY  // service role = can write to DB
);

export default async function handler(req, res) {
  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const {
      first_name,
      last_name,
      email,
      phone,
      postal_code,
      current_provider,
      service_type,
      language
    } = req.body;

    // Basic validation
    if (!first_name || !last_name || !email || !phone || !postal_code) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Basic email format check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email address' });
    }

    // Insert into Supabase
    const { data, error } = await supabase
      .from('leads')
      .insert([
        {
          first_name:       first_name.trim(),
          last_name:        last_name.trim(),
          email:            email.trim().toLowerCase(),
          phone:            phone.trim(),
          postal_code:      postal_code.trim().toUpperCase(),
          current_provider: current_provider || null,
          service_type:     service_type || 'internet',
          language:         language || 'fr',
          status:           'new',          // new | contacted | converted | closed
          source:           'website',
          created_at:       new Date().toISOString()
        }
      ])
      .select();

    if (error) {
      console.error('Supabase insert error:', error);
      return res.status(500).json({ error: 'Database error' });
    }

    // Success
    return res.status(200).json({
      success: true,
      message: 'Lead saved successfully',
      id: data[0].id
    });

  } catch (err) {
    console.error('Server error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
