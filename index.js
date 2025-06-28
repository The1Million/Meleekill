// index.js (run on your Render.com or any node host)

const express = require('express');
const app = express();
app.use(express.json());

const users = {}; // store data in-memory (replace with DB in production)

app.get('/user/:id', (req, res) => {
  const userId = req.params.id;
  if (!users[userId]) {
    users[userId] = { points: 0, playPoints: 0 };
  }
  res.json(users[userId]);
});

app.post('/user/:id/give', (req, res) => {
  const userId = req.params.id;
  const { points = 0, playPoints = 0 } = req.body;
  
  if (!users[userId]) users[userId] = { points: 0, playPoints: 0 };
  
  users[userId].points += points;
  users[userId].playPoints += playPoints;
  
  console.log(`User ${userId} given points: ${points}, playPoints: ${playPoints}`);
  
  res.json(users[userId]);
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
