module.exports = async (req, res) => {
  const { content } = req.body;

  if (!content) {
    return res.status(400).json({ message: 'Введите содержимое файла!' });
  }

  const currentUsername = process.env.GITHUB_USERNAME;
  const currentToken = process.env.GITHUB_TOKEN;

  if (!currentToken || !currentUsername) {
    return res.status(400).json({ message: 'Ошибка: отсутствует имя пользователя или токен!' });
  }

  const repo = `${currentUsername}/ByteForge`;
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let randomName = '';
  for (let i = 0; i < 12; i++) {
    randomName += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  const path = `luashieldfree/${randomName}.lua`;

  const apiUrl = `https://api.github.com/repos/${repo}/contents/${path}`;
  const rawUrl = `https://raw.githubusercontent.com/${repo}/${path.replace(/.*?\//, '')}`;

  try {
    let sha = null;
    const getResp = await fetch(apiUrl, {
      headers: { 
        Authorization: `token ${currentToken}`,
        'Accept': 'application/vnd.github.v3+json'
      }
    });

    if (getResp.ok) {
      const data = await getResp.json();
      sha = data.sha;
    } else if (getResp.status !== 404) {
      const errData = await getResp.json();
      return res.status(getResp.status).json({ message: `Ошибка при проверке файла: ${errData.message}` });
    }

    const base64Content = Buffer.from(content).toString('base64');

    const putResp = await fetch(apiUrl, {
      method: 'PUT',
      headers: {
        Authorization: `token ${currentToken}`,
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.github.v3+json'
      },
      body: JSON.stringify({
        message: sha ? `Update ${path}` : `Create ${path}`,
        content: base64Content,
        sha: sha || undefined
      })
    });

    if (putResp.ok) {
      return res.status(200).json({ sha, rawUrl });
    } else {
      const err = await putResp.json();
      return res.status(putResp.status).json({ message: `Ошибка создания/обновления файла: ${err.message}` });
    }
  } catch (e) {
    return res.status(500).json({ message: `Ошибка: ${e.message}` });
  }
};
