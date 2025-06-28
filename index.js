const express = require('express')
const app = express()
app.use(express.json())

const validKeys = {}

function checkKey(req, res, next) {
  const key = req.headers['x-api-key']
  if (!key || !validKeys[key]) {
    return res.status(403).json({ error: 'Invalid or missing API key' })
  }
  req.userId = validKeys[key].userId
  req.keyType = validKeys[key].keyType
  next()
}

app.post('/generateKeys', (req, res) => {
  const { userId } = req.body
  if (!userId) return res.status(400).json({ error: 'Missing userId' })

  const key1 = Math.random().toString(36).substr(2, 8).toUpperCase()
  const key2 = Math.random().toString(36).substr(2, 8).toUpperCase()

  validKeys[key1] = { userId: userId.toString(), keyType: 'key1' }
  validKeys[key2] = { userId: userId.toString(), keyType: 'key2' }

  res.json({ key1, key2 })
})

app.get('/validate', checkKey, (req, res) => {
  res.json({ userId: req.userId, keyType: req.keyType })
})

const PORT = process.env.PORT || 10000
app.listen(PORT, () => console.log(`API listening on port ${PORT}`))
