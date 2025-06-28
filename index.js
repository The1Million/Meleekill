const express = require('express');
const app = express();
app.use(express.json());

const pendingPoints = {};     // userId => [{id, amount}]
const pendingPlayPoints = {}; // userId => [{id, amount}]
let nextId = 1;

app.post('/queuePointsChange', (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || typeof amount !== 'number') return res.status(400).json({ error: 'Invalid input' });

  if (!pendingPoints[userId]) pendingPoints[userId] = [];
  pendingPoints[userId].push({ id: nextId++, amount });

  res.json({ status: 'queued' });
});

app.post('/queuePlayPointsChange', (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || typeof amount !== 'number') return res.status(400).json({ error: 'Invalid input' });

  if (!pendingPlayPoints[userId]) pendingPlayPoints[userId] = [];
  pendingPlayPoints[userId].push({ id: nextId++, amount });

  res.json({ status: 'queued' });
});

app.get('/pendingPointsChanges', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });
  res.json(pendingPoints[userId] || []);
});

app.get('/pendingPlayPointsChanges', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });
  res.json(pendingPlayPoints[userId] || []);
});

app.post('/ackPointsChange', (req, res) => {
  const { userId, id } = req.body;
  if (!userId || !id) return res.status(400).json({ error: 'Missing userId or id' });

  if (!pendingPoints[userId]) return res.status(404).json({ error: 'User not found' });

  pendingPoints[userId] = pendingPoints[userId].filter(change => change.id !== id);
  res.json({ status: 'acknowledged' });
});

app.post('/ackPlayPointsChange', (req, res) => {
  const { userId, id } = req.body;
  if (!userId || !id) return res.status(400).json({ error: 'Missing userId or id' });

  if (!pendingPlayPoints[userId]) return res.status(404).json({ error: 'User not found' });

  pendingPlayPoints[userId] = pendingPlayPoints[userId].filter(change => change.id !== id);
  res.json({ status: 'acknowledged' });
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`API listening on port ${PORT}`));
