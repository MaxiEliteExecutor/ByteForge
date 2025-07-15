export default function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }
  const { data } = req.body;
  if (!data || typeof data !== 'string') {
    return res.status(400).json({ error: 'Data must be a non-empty string' });
  }
  try {
    const encoded = Buffer.from(data, 'utf-8').toString('base64');
    res.status(200).json({ result: encoded });
  } catch (error) {
    res.status(500).json({ error: 'Encoding failed', details: error.message });
  }
}
