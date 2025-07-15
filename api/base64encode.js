export default function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }
  const { data } = req.body;
  if (!data || typeof data !== 'string') {
    return res.status(400).json({ error: 'Data is required and must be a string' });
  }
  try {
    const encoded = Buffer.from(data).toString('base64');
    return res.status(200).json({ result: encoded });
  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error', details: error.message });
  }
}
