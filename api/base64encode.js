export default function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Only POST allowed' });

  try {
    const { data } = req.body;
    const encoded = Buffer.from(data, 'utf8').toString('base64');
    res.status(200).json({ result: encoded });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
}
