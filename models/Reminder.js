const mongoose = require("mongoose");

const reminderSchema = new mongoose.Schema({
  text: { type: String, required: true },
  time: { type: Date, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

module.exports = mongoose.model("Reminder", reminderSchema);
