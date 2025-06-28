const express = require('express');
const app = express();
app.use(express.json());

const pendingPointsChanges = {};    // { userId: [{ id, amount }, ...] }
const pendingPlayPointsChanges = {}; // { userId: [{ id, amount }, ...] }
let nextId = 1;

// Queue points change
app.post('/queuePointsChange', (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || typeof amount !== 'number') return res.status(400).json({ error: 'Invalid input' });
  if (!pendingPointsChanges[userId]) pendingPointsChanges[userId] = [];
  pendingPointsChanges[userId].push({ id: nextId++, amount });
  console.log(`Queued +${amount} Points for user ${userId}`);
  res.json({ status: 'queued' });
});

// Queue playPoints change
app.post('/queuePlayPointsChange', (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || typeof amount !== 'number') return res.status(400).json({ error: 'Invalid input' });
  if (!pendingPlayPointsChanges[userId]) pendingPlayPointsChanges[userId] = [];
  pendingPlayPointsChanges[userId].push({ id: nextId++, amount });
  console.log(`Queued +${amount} PlayPoints for user ${userId}`);
  res.json({ status: 'queued' });
});

// Get pending points changes for user
app.get('/pendingPointsChanges', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });
  res.json(pendingPointsChanges[userId] || []);
});

// Get pending playPoints changes for user
app.get('/pendingPlayPointsChanges', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });
  res.json(pendingPlayPointsChanges[userId] || []);
});

// Acknowledge points change applied
app.post('/ackPointsChange', (req, res) => {
  const { userId, id } = req.body;
  if (!userId || !id) return res.status(400).json({ error: 'Missing userId or id' });
  if (!pendingPointsChanges[userId]) return res.status(404).json({ error: 'User not found' });
  pendingPointsChanges[userId] = pendingPointsChanges[userId].filter(change => change.id !== id);
  res.json({ status: 'acknowledged' });
});

// Acknowledge playPoints change applied
app.post('/ackPlayPointsChange', (req, res) => {
  const { userId, id } = req.body;
  if (!userId || !id) return res.status(400).json({ error: 'Missing userId or id' });
  if (!pendingPlayPointsChanges[userId]) return res.status(404).json({ error: 'User not found' });
  pendingPlayPointsChanges[userId] = pendingPlayPointsChanges[userId].filter(change => change.id !== id);
  res.json({ status: 'acknowledged' });
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`API listening on port ${PORT}`));
