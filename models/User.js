const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  emailNotifications: { type: Boolean, default: true } // 🔔 Yeni alan
});

module.exports = mongoose.model('User', userSchema);
