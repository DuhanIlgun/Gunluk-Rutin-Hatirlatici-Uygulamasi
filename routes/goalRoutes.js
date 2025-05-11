const express = require('express');
const router = express.Router();
const Goal = require('../models/goal');
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

// GET - sadece giriş yapan kullanıcının hedefleri
router.get('/', verifyToken, async (req, res) => {
  try {
    const goals = await Goal.find({ userId: req.userId }); // ✅ filtreleme eklendi
    res.json(goals);
  } catch (err) {
    res.status(500).json({ error: 'Hedefler alınamadı' });
  }
});

// POST - yeni hedef ekle
router.post('/', verifyToken, async (req, res) => {
  try {
    const goal = new Goal({ ...req.body, userId: req.userId }); // ✅ kullanıcıya ait kayıt
    await goal.save();
    res.json(goal);
  } catch (err) {
    res.status(500).json({ error: 'Hedef kaydedilemedi' });
  }
});

// PATCH - hedef güncelle
router.patch('/:id', verifyToken, async (req, res) => {
  const { id } = req.params;
  const updatedData = req.body;

  try {
    const result = await Goal.findOneAndUpdate(
      { _id: id, userId: req.userId }, // ✅ sadece kendi hedefini güncelleyebilir
      updatedData,
      { new: true }
    );
    if (!result) return res.status(404).json({ error: 'Hedef bulunamadı' });
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// DELETE - hedef sil
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const deleted = await Goal.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId // ✅ sadece kendi hedefini silebilir
    });
    if (!deleted) return res.status(404).json({ error: 'Hedef bulunamadı' });
    res.json({ message: 'Silindi' });
  } catch (err) {
    res.status(500).json({ error: 'Silme işlemi başarısız' });
  }
});

module.exports = router;
