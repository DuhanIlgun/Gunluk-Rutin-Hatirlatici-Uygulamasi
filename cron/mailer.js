const cron = require('node-cron');
const nodemailer = require('nodemailer');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');

dotenv.config();

// 🔌 MongoDB bağlantısı
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log("✅ MongoDB bağlantısı başarılı (Mailer)"))
  .catch((err) => console.error("❌ MongoDB bağlantı hatası:", err));

// 📬 Mail ayarı
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS
  }
});

// 🕘 Her gün sabah 9'da çalış
cron.schedule('0 9 * * *', async () => {
  try {
    const users = await User.find(); // tüm kullanıcılar

    for (const user of users) {
      await transporter.sendMail({
        from: `"RutinApp" <${process.env.MAIL_USER}>`,
        to: user.email,
        subject: "🕒 Günlük Hatırlatma",
        html: `
          <div style="font-family: Arial; padding: 16px;">
            <h3>Merhaba ${user.name},</h3>
            <p>Bugün görevlerini yapmayı unutma!</p>
            <p>
              <a href="https://rutinapp.com/reminders">🌐 Görevleri Görüntüle</a>
            </p>
            <hr />
            <small style="color:gray;">Bu mesaj otomatik olarak gönderilmiştir.</small>
          </div>
        `
      });

      console.log(`📤 Mail gönderildi: ${user.email}`);
    }
  } catch (err) {
    console.error("❌ Mail gönderme hatası:", err.message);
  }
});
