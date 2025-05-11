const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const User = require('../models/User');

// ✅ Kayıt Ol
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Bu e-posta zaten kullanılıyor.' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ name, email, password: hashedPassword });
    await newUser.save();

    res.status(201).json({ message: 'Kayıt başarılı' });
  } catch (err) {
    console.error("Kayıt Hatası:", err);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// ✅ Giriş Yap
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    console.log("Gelen kullanıcı:", user);

    if (!user) {
      return res.status(401).json({ error: 'Kullanıcı bulunamadı' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    console.log("Şifre eşleşti mi?", isMatch);

    if (!isMatch) {
      return res.status(401).json({ error: 'Şifre hatalı' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1d' });

    res.status(200).json({ message: 'Giriş başarılı', token, userId: user._id, email: user.email });
  } catch (err) {
    console.error("Login Hatası:", err);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// ✅ Şifre Güncelleme (token ile kimlik doğrulama)
router.post('/update-password', async (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const { oldPassword, newPassword } = req.body;
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);
    if (!user) return res.status(404).json({ error: 'Kullanıcı bulunamadı' });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) return res.status(401).json({ error: 'Eski şifre yanlış' });

    const hashed = await bcrypt.hash(newPassword, 10);
    user.password = hashed;
    await user.save();

    res.json({ message: 'Şifre güncellendi' });
  } catch (err) {
    console.error("Şifre güncelleme hatası:", err);
    res.status(401).json({ error: 'Token geçersiz veya süresi dolmuş' });
  }
});

// ✅ Şifremi Unuttum
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: 'E-posta bulunamadı.' });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '15m' });
    const resetLink = `http://localhost:5500/reset-password.html?token=${token}`;

    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS
      }
    });

    await transporter.sendMail({
      to: user.email,
      subject: "🔐 RutinApp Şifre Sıfırlama",
      html: `<p>Şifrenizi sıfırlamak için <a href="${resetLink}">buraya tıklayın</a>.</p>`
    });

    res.json({ message: 'Sıfırlama bağlantısı e-posta adresinize gönderildi.' });

  } catch (err) {
    console.error("Şifre sıfırlama hatası:", err);
    res.status(500).json({ error: 'Sunucu hatası' });
  }
});

// ✅ Yeni Şifre Belirleme
router.post('/reset-password', async (req, res) => {
  const { token, newPassword } = req.body;
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const hashed = await bcrypt.hash(newPassword, 10);
    await User.findByIdAndUpdate(decoded.id, { password: hashed });

    res.json({ message: "Şifre başarıyla güncellendi." });
  } catch (err) {
    console.error("Şifre belirleme hatası:", err);
    res.status(400).json({ error: "Geçersiz veya süresi dolmuş bağlantı." });
  }
});

module.exports = router;
