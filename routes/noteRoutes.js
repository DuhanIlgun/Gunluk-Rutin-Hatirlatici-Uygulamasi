const express = require('express');
const router = express.Router();
const Note = require('../models/Note');
const jwt = require('jsonwebtoken');

// ✅ Token doğrulama middleware
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

// ✅ Kullanıcının notlarını getir
router.get('/', verifyToken, async (req, res) => {
  try {
    const notes = await Note.find({ userId: req.userId }).sort({ createdAt: -1 });
    res.json(notes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ Yeni not ekle
router.post('/', verifyToken, async (req, res) => {
  try {
    const { title, text, date } = req.body;
    const newNote = new Note({
      title,
      text,
      date,
      userId: req.userId // 🔐 sadece giriş yapan kullanıcıya ait
    });
    const savedNote = await newNote.save();
    res.status(201).json(savedNote);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// ✅ Not sil (sadece kendi notunu silebilir)
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const deleted = await Note.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId
    });
    if (!deleted) return res.status(404).json({ error: 'Not bulunamadı veya silme yetkiniz yok.' });
    res.json({ message: 'Not başarıyla silindi' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
