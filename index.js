const express = require("express");
const fs = require("fs");
const app = express();
const port = process.env.PORT || 3000;

const KEYS_FILE = "./keys.json";

// Load or initialize keys
function loadKeys() {
    if (!fs.existsSync(KEYS_FILE)) fs.writeFileSync(KEYS_FILE, JSON.stringify({}));
    return JSON.parse(fs.readFileSync(KEYS_FILE));
}

function saveKeys(keys) {
    fs.writeFileSync(KEYS_FILE, JSON.stringify(keys, null, 2));
}

function generateKey() {
    return Math.random().toString(36).substring(2, 10).toUpperCase();
}

// Endpoint to verify by UserId
app.get("/verify", (req, res) => {
    const userId = req.query.id;
    if (!userId) return res.json({ success: false, msg: "No UserId provided" });

    const keys = loadKeys();

    if (!keys[userId]) {
        const newKey = generateKey();
        keys[userId] = newKey;
        saveKeys(keys);
        return res.json({ success: true, msg: "New key created", key: newKey });
    }

    return res.json({ success: true, msg: "Existing key found", key: keys[userId] });
});

app.listen(port, () => {
    console.log(`✅ Key API running on port ${port}`);
});
