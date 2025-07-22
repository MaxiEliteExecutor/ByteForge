export default function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method Not Allowed" });
  }

  try {
    const { playerName, requestTime } = req.body;

    // Validate input
    if (!playerName) {
      return res.status(400).json({ error: "Player name required" });
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
      padding: 40px;
      background: linear-gradient(to right, #74ebd5, #acb6e5);
    }
    h1 {
      color: #1a3c34;
    }
    p {
      font-size: 20px;
      color: #333;
    }
  </style>
</head>
<body>
  <h1>Greetings, ${playerName}!</h1>
  <p>Generated on: ${new Date(requestTime * 1000).toLocaleString()}</p>
  <p>Access this at: https://www.byteforge-getnow.space/api/create-page.js</p>
</body>
</html>
`;

    // Return JSON with HTML and URL
    res.status(200).json({
      html: htmlContent,
      url: "https://www.byteforge-getnow.space/api/create-page.js"
    });
  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: "Server error" });
  }
}
