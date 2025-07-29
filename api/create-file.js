export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const GITHUB_API_KEY = process.env.githubnigakey;
  const REPO_PATH = process.env.Repo;

  if (!GITHUB_API_KEY || !REPO_PATH) {
    return res.status(500).json({ error: 'GitHub API key or repository path is missing' });
  }

  const { content } = req.body;

  if (!content) {
    return res.status(400).json({ error: 'File content is required' });
  }

  const randomString = Math.random().toString(36).substring(2, 10);
  const path = `script_${randomString}.lua`;
  const apiUrl = `https://api.github.com/repos/${REPO_PATH}/contents/${path}`;

  try {
    let sha = null;

    const getResp = await fetch(apiUrl, {
      headers: { Authorization: `Bearer ${GITHUB_API_KEY}` },
    });

    if (getResp.ok) {
      const data = await getResp.json();
      sha = data.sha;
    } else if (getResp.status !== 404) {
      const errData = await getResp.json();
      return res.status(getResp.status).json({ error: `Error checking file: ${errData.message}` });
    }

    const base64Content = Buffer.from(content).toString('base64');

    const putResp = await fetch(apiUrl, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${GITHUB_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: sha ? `Update file ${path}` : `Create file ${path}`,
        content: base64Content,
        sha: sha || undefined,
      }),
    });

    if (putResp.ok) {
      return res.status(200).json({ message: sha ? 'File updated successfully!' : 'File created successfully!' });
    } else {
      const err = await putResp.json();
      return res.status(putResp.status).json({ error: `Error creating/updating file: ${err.message}` });
    }
  } catch (e) {
    return res.status(500).json({ error: `Server error: ${e.message}` });
  }
}
