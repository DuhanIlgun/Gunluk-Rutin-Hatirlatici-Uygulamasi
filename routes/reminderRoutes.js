const express = require("express");
const router = express.Router();
const Reminder = require("../models/Reminder");

// GET - Tüm hatırlatıcıları getir
router.get("/", async (req, res) => {
    const reminders = await Reminder.find().sort({ time: 1 });
    res.json(reminders);
});

// POST - Yeni hatırlatıcı ekle
router.post("/", async (req, res) => {
    const { text, time } = req.body;
    try {
        const newReminder = new Reminder({ text, time });
        await newReminder.save();
        res.status(201).json(newReminder);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE - Hatırlatıcı sil
router.delete("/:id", async (req, res) => {
    try {
        await Reminder.findByIdAndDelete(req.params.id);
        res.status(204).end();
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
