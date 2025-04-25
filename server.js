require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const reminderRoutes = require("./routes/reminderRoutes");
const motivationRoutes = require("./routes/motivationRoutes");
const noteRoutes = require("./routes/noteRoutes");

const app = express();
app.use(cors());
app.use(express.json());

// ROUTES
app.use("/api/reminders", reminderRoutes);
app.use("/api/motivation", motivationRoutes);
app.use("/api/notes", noteRoutes);

// MONGODB BAĞLANTISI
mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log("✅ MongoDB bağlantısı başarılı"))
.catch((err) => console.error("❌ MongoDB bağlantı hatası:", err));

// SUNUCUYU BAŞLAT
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Sunucu ${PORT} portunda çalışıyor`);
});
