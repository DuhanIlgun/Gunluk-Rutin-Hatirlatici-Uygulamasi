const express = require('express');
const router = express.Router();
const Goal = require('../models/goal');

// GET - tüm hedefleri getir
router.get('/', async (req, res) => {
  try {
    const goals = await Goal.find();
    res.json(goals);
  } catch (err) {
    res.status(500).json({ error: 'Hedefler alınamadı' });
  }
});

// POST - yeni hedef ekle
router.post('/', async (req, res) => {
  try {
    const goal = new Goal(req.body);
    await goal.save();
    res.json(goal);
  } catch (err) {
    res.status(500).json({ error: 'Hedef kaydedilemedi' });
  }
});

// PATCH - hedef güncelle
router.patch('/:id', async (req, res) => {
  const { id } = req.params;
  const updatedData = req.body;

  try {
    const result = await Goal.findByIdAndUpdate(id, updatedData, { new: true });
    if (!result) return res.status(404).json({ error: 'Hedef bulunamadı' });
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// DELETE - hedef sil
router.delete('/:id', async (req, res) => {
  try {
    await Goal.findByIdAndDelete(req.params.id);
    res.json({ message: 'Silindi' });
  } catch (err) {
    res.status(500).json({ error: 'Silme işlemi başarısız' });
  }
});

module.exports = router;
