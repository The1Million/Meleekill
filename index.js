const express = require('express');
const app = express();
app.use(express.json());

const users = {}; // Simple in-memory storage; replace with DB for persistence

// Get user points
app.get('/user/:id', (req, res) => {
  const userId = req.params.id;
  if (!users[userId]) {
    users[userId] = { points: 0, playPoints: 0 };
  }
  res.json(users[userId]);
});

// Give points to user
app.post('/user/:id/give', (req, res) => {
  const userId = req.params.id;
  const { points = 0, playPoints = 0 } = req.body;

  if (!users[userId]) {
    users[userId] = { points: 0, playPoints: 0 };
  }

  // Validate inputs
  const ptsToAdd = Number(points);
  const playPtsToAdd = Number(playPoints);

  if (isNaN(ptsToAdd) || isNaN(playPtsToAdd) || ptsToAdd < 0 || playPtsToAdd < 0) {
    return res.status(400).json({ error: "Invalid points values." });
  }

  users[userId].points += ptsToAdd;
  users[userId].playPoints += playPtsToAdd;

  console.log(`User ${userId} received Points: ${ptsToAdd}, PlayPoints: ${playPtsToAdd}`);

  res.json(users[userId]);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API server running on port ${PORT}`);
});
