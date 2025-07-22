let pageName = null; // Store the random page name for the session

export default function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  try {
    let requestTime = Date.now() / 1000;
    if (req.method === "POST") {
      requestTime = req.body.requestTime || requestTime;
    }

    // Generate random page name if not already set
    if (!pageName) {
      const randomId = Math.random().toString(36).substring(2, 8);
      pageName = `${randomId}.html`;
    }
    const publicUrl = `https://www.byteforge-getnow.space/${pageName}`;

    // Generate HTML content
    const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ByteForge Public Page</title>
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
  <h1>ByteForge Public Page</h1>
  <p>Generated on: ${new Date(requestTime * 1000).toLocaleString()}</p>
  <p>Access this page at: <a href="${publicUrl}">${publicUrl}</a></p>
</body>
</html>
`;

    if (req.method === "GET" && req.url === `/${pageName}`) {
      res.setHeader("Content-Type", "text/html");
      res.status(200).send(htmlContent);
    } else if (req.method === "POST") {
      res.status(200).json({
        html: htmlContent,
        url: publicUrl
      });
    } else {
      res.status(405).json({ error: "Method Not Allowed" });
    }
  } catch (error) {
    console.error("Server error:", error.message);
    res.status(500).json({ error: "Server error", details: error.message });
  }
}
