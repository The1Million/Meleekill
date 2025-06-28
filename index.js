const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/notify', (req, res) => {
  const userId = req.query.userId;
  if (userId) {
    console.log(`User ${userId} ran the script.`);
    // Here you can also save it to a database or file
    res.send('Notification received');
  } else {
    res.status(400).send('Missing userId');
  }
});

app.listen(port, () => {
  console.log(`API running on port ${port}`);
});
