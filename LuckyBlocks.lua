// ================================
// ROBLOX KEY SYSTEM API (1 FILE)
// ================================

const express = require("express");
const fs = require("fs");
const crypto = require("crypto");
const app = express();

app.use(express.json());

const PORT = 3000;
const DB_FILE = "./database.json";

// ================================
// CONFIG
// ================================

const KEY_LIFETIME = 24 * 60 * 60 * 1000; // 24 hours
const HEARTBEAT_TIMEOUT = 90 * 1000; // 90 seconds

// 🔑 YOUR KEYS (YOU CONTROL THESE)
const KEYS = {
  "PREMIUM-ALPHA-001": {
    link: "https://linkvertise.com/yourlink1"
  },
  "PREMIUM-ALPHA-002": {
    link: "https://linkvertise.com/yourlink2"
  },
  "PREMIUM-BETA-003": {
    link: "https://linkvertise.com/yourlink3"
  }
};

// ================================
// DATABASE
// ================================

function loadDB() {
  if (!fs.existsSync(DB_FILE)) return {};
  return JSON.parse(fs.readFileSync(DB_FILE));
}

function saveDB(db) {
  fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
}

function now() {
  return Date.now();
}

// ================================
// GET KEY (LINKVERTISE BUTTON)
// ================================

app.post("/key/get", (req, res) => {
  const { key } = req.body;

  if (!KEYS[key]) {
    return res.status(400).json({ error: "Invalid key" });
  }

  res.json({
    key,
    link: KEYS[key].link
  });
});

// ================================
// VERIFY / AUTO LOGIN
// ================================

app.post("/key/verify", (req, res) => {
  const { userId, key } = req.body;
  if (!userId || !key) return res.json({ valid: false });

  if (!KEYS[key]) return res.json({ valid: false });

  const db = loadDB();
  const user = db[userId];

  // First-time use
  if (!user) {
    db[userId] = {
      key,
      activatedAt: now(),
      expiresAt: now() + KEY_LIFETIME,
      lastSeen: now()
    };
    saveDB(db);
    return res.json({ valid: true, expiresAt: db[userId].expiresAt });
  }

  // Same key reuse
  if (user.key === key && user.expiresAt > now()) {
    user.lastSeen = now();
    saveDB(db);
    return res.json({ valid: true, expiresAt: user.expiresAt });
  }

  // Key expired → renew timer
  if (user.key === key && user.expiresAt <= now()) {
    user.activatedAt = now();
    user.expiresAt = now() + KEY_LIFETIME;
    user.lastSeen = now();
    saveDB(db);
    return res.json({ valid: true, expiresAt: user.expiresAt });
  }

  // Different key (blocked)
  return res.json({ valid: false });
});

// ================================
// KEY STATUS (AUTO LOGIN CHECK)
// ================================

app.get("/key/status", (req, res) => {
  const { userId } = req.query;
  const db = loadDB();
  const user = db[userId];

  if (!user || user.expiresAt <= now()) {
    return res.json({ valid: false });
  }

  res.json({
    valid: true,
    expiresAt: user.expiresAt
  });
});

// ================================
// HEARTBEAT (ONLINE TRACKING)
// ================================

app.post("/heartbeat", (req, res) => {
  const { userId } = req.body;
  const db = loadDB();

  if (!db[userId]) return res.sendStatus(200);

  db[userId].lastSeen = now();
  saveDB(db);
  res.sendStatus(200);
});

// ================================
// ONLINE COUNT
// ================================

app.get("/stats/online", (req, res) => {
  const db = loadDB();
  const cutoff = now() - HEARTBEAT_TIMEOUT;

  let count = 0;
  for (const uid in db) {
    if (db[uid].lastSeen > cutoff) count++;
  }

  res.json({ count });
});

// ================================
// START SERVER
// ================================

app.listen(PORT, () => {
  console.log(`Key API running on port ${PORT}`);
});
