// routes/motivationRoutes.js
const express = require('express');
const router = express.Router();
const Motivation = require('../models/motivation');

// Günlük random motivasyon mesajı getir
router.get('/daily', async (req, res) => {
  try {
    const motivations = await Motivation.find();
    if (motivations.length === 0) {
      return res.status(404).json({ message: "Motivasyon mesajı bulunamadı." });
    }
    const randomIndex = Math.floor(Math.random() * motivations.length);
    res.json(motivations[randomIndex]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
