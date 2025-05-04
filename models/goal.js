const mongoose = require('mongoose');

const goalSchema = new mongoose.Schema({
  title: String,
  desc: String,
  date: String,
  percent: Number,
  completed: Boolean
}, { timestamps: true });

module.exports = mongoose.model('Goal', goalSchema);
