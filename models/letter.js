const mongoose = require('mongoose');

const letterSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  text: { type: String, required: true },
  date: { type: String, required: true } // örnek: "16.06.2025"
}, { timestamps: true });

module.exports = mongoose.model('Letter', letterSchema);
