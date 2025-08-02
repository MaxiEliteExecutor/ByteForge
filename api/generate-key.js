const { randomUUID } = require('crypto');
const { kv } = require('@vercel/kv');

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Get client IP from headers (supports IPv4 and IPv6)
  const clientIp = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.headers['x-vercel-forwarded-for']?.split(',')[0]?.trim() || 'unknown';

  try {
    // Check if a key exists for this IP in Vercel KV
    const existingKey = await kv.get(`ip:${clientIp}`);

    if (existingKey) {
      // Return existing key for this IP (anti-bypass)
      return res.status(200).json({
        ip: clientIp,
        key: existingKey,
        message: 'Existing key retrieved for IP'
      });
    }

    // Generate a new key
    const newKey = randomUUID();

    // Store the key in Vercel KV
    await kv.set(`ip:${clientIp}`, newKey);

    res.status(200).json({
      ip: clientIp,
      key: newKey,
      message: 'New key generated and stored for IP'
    });
  } catch (error) {
    res.status(500).json({ error: 'Operation failed', details: error.message });
  }
}
