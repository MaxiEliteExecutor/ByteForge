const fs = require("fs");

let html = fs.readFileSync("luashieldfree/create.html", "utf8");
html = html
  .replace("__GITHUB_TOKEN__", process.env.GITHUB_TOKEN)
  .replace("__GITHUB_USERNAME__", process.env.GITHUB_USERNAME)
  .replace("__GITHUB_REPO__", process.env.GITHUB_REPO);

if (!fs.existsSync("public")) fs.mkdirSync("public");
fs.writeFileSync("public/luashieldfree/create.html", html);
