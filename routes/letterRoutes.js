const express = require('express');
const router = express.Router();
const Letter = require('../models/letter');
const jwt = require('jsonwebtoken');

// Auth middleware
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Token gerekli." });
  }
  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(403).json({ error: "Geçersiz token." });
  }
}

// ✔ POST /api/letters — Mektup kaydet
router.post('/', verifyToken, async (req, res) => {
  try {
    const { text, date } = req.body;
    const letter = new Letter({ userId: req.userId, text, date });
    await letter.save();
    res.status(201).json(letter);
  } catch (err) {
    res.status(500).json({ error: 'Kayıt başarısız.' });
  }
});

// ✔ GET /api/letters — Geçmiş mektupları getir
router.get('/', verifyToken, async (req, res) => {
  try {
    const letters = await Letter.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json(letters);
  } catch (err) {
    res.status(500).json({ error: 'Listeleme hatası.' });
  }
});

// ✔ DELETE /api/letters/:id — Sil
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const result = await Letter.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId
    });
    if (!result) return res.status(404).json({ error: 'Bulunamadı.' });
    res.json({ message: 'Silindi.' });
  } catch {
    res.status(500).json({ error: 'Silme başarısız.' });
  }
});

module.exports = router;
