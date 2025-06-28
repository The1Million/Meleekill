const express = require('express');
const app = express();
app.use(express.json());

// Store valid keys mapped to userIds
const validKeys = {
  'ABC12345': '123456789'
};

// Store pending currency changes per userId
const pendingPoints = {};
const pendingPlayPoints = {};
let nextId = 1;

// Middleware to validate API key and set req.userId
function checkApiKey(req, res, next) {
  const key = req.headers['x-api-key'];
  if (!key || !validKeys[key]) {
    return res.status(403).json({ error: 'Invalid or missing API key' });
  }
  req.userId = validKeys[key];
  next();
}

// Endpoint to generate a new key for a user (admin only, secure this!)
app.post('/generateKey', (req, res) => {
  const { userId } = req.body;
  if (!userId) return res.status(400).json({ error: 'Missing userId' });

  const newKey = Math.random().toString(36).substr(2, 8).toUpperCase();
  validKeys[newKey] = userId.toString();

  res.json({ key: newKey });
});

// Endpoint to get current currency data for user by key
app.get('/user', checkApiKey, (req, res) => {
  const userId = req.userId;

  const totalPoints = (pendingPoints[userId] || []).reduce((acc, c) => acc + c.amount, 0);
  const totalPlayPoints = (pendingPlayPoints[userId] || []).reduce((acc, c) => acc + c.amount, 0);

  // In real use, store and return actual balances from a database
  res.json({
    points: totalPoints,
    playPoints: totalPlayPoints
  });
});

// Queue Points change for user by key
app.post('/queuePointsChange', checkApiKey, (req, res) => {
  const { amount } = req.body;
  if (typeof amount !== 'number') return res.status(400).json({ error: 'Invalid amount' });

  const userId = req.userId;
  if (!pendingPoints[userId]) pendingPoints[userId] = [];
  pendingPoints[userId].push({ id: nextId++, amount });

  res.json({ status: 'queued' });
});

// Queue PlayPoints change for user by key
app.post('/queuePlayPointsChange', checkApiKey, (req, res) => {
  const { amount } = req.body;
  if (typeof amount !== 'number') return res.status(400).json({ error: 'Invalid amount' });

  const userId = req.userId;
  if (!pendingPlayPoints[userId]) pendingPlayPoints[userId] = [];
  pendingPlayPoints[userId].push({ id: nextId++, amount });

  res.json({ status: 'queued' });
});

// Start server
const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
});
