export default function handler(req, res) {
  // Set CORS headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  try {
    const { playerName, requestTime } = req.body;

    // Validate input
    if (!playerName) {
      return res.status(400).json({ error: "Player name required" });
    }

    // Generate unique URL with query parameter to simulate .html page
    const uniqueUrl = `https://www.byteforge-getnow.space/api/create-page.js?player=${encodeURIComponent(playerName)}`;

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
      font-family: Arial, sans-serif;
      text-align: center;
      padding: 50px;
      background: linear-gradient(to right, #a1c4fd, #c2e9fb);
    }
    h1 {
      color: #2a4365;
    }
    p {
      font-size: 18px;
      color: #1a202c;
    }
    a {
      color: #3182ce;
      text-decoration: none;
      font-weight: bold;
    }
    a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>
  <h1>Hello, ${playerName}!</h1>
  <p>Generated on: ${new Date(requestTime * 1000).toLocaleString()}</p>
  <p>Access this at: <a href="${uniqueUrl}">${uniqueUrl}</a></p>
</body>
</html>
`;

    // Return JSON response
    res.status(200).json({
      html: htmlContent,
      url: uniqueUrl
    });
  } catch (error) {
    console.error("Server error:", error.message);
    res.status(500).json({ error: "Server error", details: error.message });
  }
}
