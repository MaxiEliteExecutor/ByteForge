export default function handler(req, res) {
  // Check if the request method is POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  // Parse the request body
  const { data } = req.body;

  // Validate that data is provided and is a string
  if (!data || typeof data !== 'string') {
    return res.status(400).json({ error: 'Data is required and must be a string' });
  }

  try {
    // Encode the string to Base64
    const encoded = Buffer.from(data).toString('base64');
    // Return the result as JSON
    return res.status(200).json({ result: encoded });
  } catch (error) {
    return res.status(500).json({ error: 'Internal Server Error', details: error.message });
  }
}
