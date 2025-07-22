export default function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  try {
    const { playerName, requestTime } = req.body;

    // Validate input
    if (!playerName) {
      return res.status(400).json({ error: "Player name is required" });
    }

    // Generate HTML content
    const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Page for ${playerName}</title>
  <style>
    body {
      font-family: sans-serif;
      text-align: center;
      padding: 30px;
      background: linear-gradient(to bottom, #87ceeb, #f0f8ff);
    }
    h1 {
      color: #2c3e50;
    }
    p {
      font-size: 18px;
    }
  </style>
</head>
<body>
  <h1>Hello, ${playerName}!</h1>
  <p>Page created on: ${new Date(requestTime * 1000).toLocaleString()}</p>
  <p>Visit this page at: ${req.headers.host ? `https://${req.headers.host}/api/create-page` : "your-site.vercel.app/api/create-page"}</p>
</body>
</html>
`;

    // Return JSON with HTML and URL
    res.status(200).json({
      html: htmlContent,
      url: req.headers.host ? `https://${req.headers.host}/api/create-page` : "https://your-site.vercel.app/api/create-page"
    });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Server error" });
  }
}
