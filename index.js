const express = require('express');
const app = express();
app.use(express.json());

const pendingGives = {}; // Format: { userId: [{ id, points, playPoints }, ...] }
let nextGiveId = 1;

// Queue a give request
app.post('/queueGive', (req, res) => {
  const { userId, points = 0, playPoints = 0 } = req.body;

  if (!userId) return res.status(400).json({ error: "Missing userId" });

  if (!pendingGives[userId]) pendingGives[userId] = [];

  const newGive = {
    id: nextGiveId++,
    points,
    playPoints
  };

  pendingGives[userId].push(newGive);

  console.log(`Queued give for user ${userId}: +${points} points, +${playPoints} playPoints`);

  res.json({ status: "queued", giveId: newGive.id });
});

// Retrieve pending gives for a user
app.get('/pendingGives', (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: "Missing userId" });

  const gives = pendingGives[userId] || [];
  res.json(gives);
});

// Acknowledge and remove a processed give
app.post('/ackGive', (req, res) => {
  const { userId, giveId } = req.body;

  if (!userId || !giveId) return res.status(400).json({ error: "Missing userId or giveId" });

  if (!pendingGives[userId]) return res.status(404).json({ error: "User not found" });

  pendingGives[userId] = pendingGives[userId].filter(give => give.id !== giveId);

  res.json({ status: "acknowledged" });
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
});
