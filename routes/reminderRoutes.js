const express = require("express");
const router = express.Router();
const Reminder = require("../models/Reminder");
const jwt = require("jsonwebtoken");

// ✅ Token kontrol middleware
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Yetkilendirme gerekli." });
  }

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    return res.status(403).json({ error: "Geçersiz token." });
  }
}

// ✅ Kullanıcının hatırlatıcılarını getir
router.get("/", verifyToken, async (req, res) => {
  try {
    const reminders = await Reminder.find({ userId: req.userId }).sort({ time: 1 });
    res.json(reminders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Yeni hatırlatıcı ekle
router.post("/", verifyToken, async (req, res) => {
  const { text, time } = req.body;
  try {
    const newReminder = new Reminder({ text, time, userId: req.userId });
    await newReminder.save();
    res.status(201).json(newReminder);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ Kullanıcıya ait hatırlatıcıyı sil
router.delete("/:id", verifyToken, async (req, res) => {
  try {
    const deleted = await Reminder.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId
    });

    if (!deleted) return res.status(404).json({ error: "Hatırlatıcı bulunamadı" });
    res.status(204).end();
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

module.exports = router;
