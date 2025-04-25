// models/Motivation.js
const mongoose = require('mongoose');

const motivationSchema = new mongoose.Schema({
  text: { type: String, required: true },
  author: { type: String, default: "RutinApp" },
  type: { type: String, default: "daily" },
});

module.exports = mongoose.model("Motivation", motivationSchema);
