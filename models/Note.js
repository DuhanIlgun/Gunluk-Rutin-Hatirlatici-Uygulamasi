// models/Note.js
const mongoose = require('mongoose');

const noteSchema = new mongoose.Schema({
  title: { type: String, required: true },
  text: { type: String, required: true },
  date: { type: Date, required: true },
  color: { type: String, default: "#fff0f5" },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true } // ✅ kullanıcıya ait
}, { timestamps: true });

module.exports = mongoose.model('Note', noteSchema);
