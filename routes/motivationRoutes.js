const express = require('express');
const router = express.Router();
const Motivation = require('../models/motivation');
const jwt = require('jsonwebtoken');

// ✅ Kimlik doğrulama middleware
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

// ✅ Günlük motivasyon mesajı getir ve kaydet
router.get('/daily', verifyToken, async (req, res) => {
  try {
    const existing = await Motivation.findOne({
      userId: req.userId,
      type: 'daily',
      createdAt: {
        $gte: new Date(new Date().setHours(0, 0, 0, 0)),
        $lte: new Date(new Date().setHours(23, 59, 59, 999))
      }
    });

    if (existing) return res.json(existing);

    const pool = await Motivation.find({ type: 'daily', userId: null });
    if (pool.length === 0) {
      return res.status(404).json({ message: "Genel motivasyon mesajı bulunamadı." });
    }

    const random = pool[Math.floor(Math.random() * pool.length)];

    const newMsg = new Motivation({
      text: random.text,
      author: random.author,
      type: 'daily',
      userId: req.userId
    });

    await newMsg.save();
    res.json(newMsg);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ Ruh haline göre motivasyon mesajı getir
router.get('/mood', verifyToken, async (req, res) => {
  const { level } = req.query;
  const validMoods = ['sad', 'neutral', 'happy'];

  if (!validMoods.includes(level)) {
    return res.status(400).json({ error: 'Geçersiz ruh hali seviyesi.' });
  }

  try {
    const messages = await Motivation.find({ mood: level, userId: null });
    if (messages.length === 0) {
      return res.status(404).json({ error: 'Bu ruh hali için mesaj bulunamadı.' });
    }

    const random = messages[Math.floor(Math.random() * messages.length)];
    res.json(random);
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatası.' });
  }
});

// ✅ Kullanıcının geçmiş motivasyon mesajlarını getir
router.get('/history', verifyToken, async (req, res) => {
  try {
    const history = await Motivation.find({
      userId: req.userId,
      type: 'daily'
    }).sort({ createdAt: -1 }).limit(30); // son 30 gün

    res.json(history);
  } catch (err) {
    res.status(500).json({ error: 'Geçmiş verileri alınamadı.' });
  }
});

module.exports = router;
