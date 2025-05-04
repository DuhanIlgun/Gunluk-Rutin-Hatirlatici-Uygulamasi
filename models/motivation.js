const mongoose = require('mongoose');

const motivationSchema = new mongoose.Schema({
  text: { type: String, required: true },
  author: { type: String, default: "RutinApp" },
  type: { type: String, default: "daily" },
  mood: { type: String, enum: ['sad', 'neutral', 'happy'] },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true }); // createdAt kullanılacak

module.exports = mongoose.model("Motivation", motivationSchema);
