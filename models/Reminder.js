const mongoose = require("mongoose");

const reminderSchema = new mongoose.Schema({
  text: { type: String, required: true },
  time: { type: Date, required: true }, // ⏰ Görev zamanı
  completed: { type: Boolean, default: false }, // ✔ Tamamlandı mı
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true } // 🔗 Kullanıcı bağlantısı
}, { timestamps: true });

module.exports = mongoose.model("Reminder", reminderSchema);
