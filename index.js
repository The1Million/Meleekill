const express = require('express');
const app = express();
app.use(express.json());

const pendingGives = {}; // { userId: [{id, points, playPoints}, ...] }
let giveIdCounter = 1;

// Endpoint to queue a give request
app.post('/queueGive', (req, res) => {
  const { userId, points, playPoints } = req.body;
  if (!userId) return res.status(400).send('Missing userId');
  
  if (!pendingGives[userId]) pendingGives[userId] = [];

  pendingGives[userId].push({
    id: giveIdCounter++,
    points: points || 0,
    playPoints: playPoints || 0
  });

  console.log(`Queued give for user ${userId}: +${points} points, +${playPoints} playPoints`);

  res.json({ status: "queued" });
});

// Endpoint for player to get pending gives
app.get('/pendingGives', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).send('Missing userId');

  const gives = pendingGives[userId] || [];
  res.json(gives);
});

// Endpoint to acknowledge a processed give
app.post('/ackGive', (req, res) => {
  const { giveId, userId } = req.body;
  if (!userId || !giveId) return res.status(400).send('Missing giveId or userId');

  if (!pendingGives[userId]) return res.status(404).send('User not found');

  pendingGives[userId] = pendingGives[userId].filter(g => g.id ~= giveId);

  res.json({ status: "acknowledged" });
});

const port = process.env.PORT || 10000;
app.listen(port, () => console.log(`API listening on port ${port}`));
