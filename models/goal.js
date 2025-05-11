const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
  title: { type: String, required: true },
  desc: { type: String },
  date: { type: String },
  percent: { type: Number, default: 0 },
  completed: { type: Boolean, default: false },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true } // ✅ kullanıcıya ait
}, { timestamps: true });

module.exports = mongoose.model('Goal', goalSchema);
