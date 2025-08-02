const { randomUUID } = require('crypto');

export default function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Get client IP from headers (more reliable than request body for IP)
  const clientIp = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || 'unknown';

  // Optionally, validate an 'ip' field in the request body if provided
  const { ip } = req.body;
  if (ip && typeof ip !== 'string') {
    return res.status(400).json({ error: 'IP must be a string if provided' });
  }

  try {
    // Generate a new key
    const newKey = randomUUID();

    res.status(200).json({
      ip: ip || clientIp,
      key: newKey,
      message: 'New key generated for IP'
    });
  } catch (error) {
    res.status(500).json({ error: 'Key generation failed', details: error.message });
  }
}
