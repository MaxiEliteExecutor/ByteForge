export default function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Only POST allowed' });

  try {
    const { data } = req.body;
    const decoded = Buffer.from(data, 'base64').toString('utf8');
    res.status(200).json({ result: decoded });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
}
