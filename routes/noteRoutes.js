// routes/noteRoutes.js
const express = require('express');
const router = express.Router();
const Note = require('../models/Note');

// Tüm notları getir
router.get('/', async (req, res) => {
  try {
    const notes = await Note.find().sort({ createdAt: -1 });
    res.json(notes);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Yeni not ekle
router.post('/', async (req, res) => {
  try {
    const { title, text, date } = req.body;
    const newNote = new Note({ title, text, date });
    const savedNote = await newNote.save();
    res.status(201).json(savedNote);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// Not sil
router.delete('/:id', async (req, res) => {
  try {
    await Note.findByIdAndDelete(req.params.id);
    res.json({ message: 'Not başarıyla silindi' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;