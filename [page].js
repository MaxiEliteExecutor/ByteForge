let pageName = null;

export default function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  try {
    const { page } = req.query;

    // Check if the page matches the current random page name
    if (!pageName) {
      pageName = Math.random().toString(36).substring(2, 8) + ".html";
    }
    const publicUrl = `https://www.byteforge-getnow.space/${pageName}`;

    if (req.method === "GET" && page === pageName.replace(".html", "")) {
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
  <p>Generated on: ${new Date((Date.now() / 1000) * 1000).toLocaleString()}</p>
  <p>Access this page at: <a href="${publicUrl}">${publicUrl}</a></p>
</body>
</html>
`;
      res.setHeader("Content-Type", "text/html");
      res.status(200).send(htmlContent);
    } else {
      res.status(404).json({ error: "Page not found" });
    }
  } catch (error) {
    console.error("Server error:", error.message);
    res.status(500).json({ error: "Server error", details: error.message });
  }
}
