// seedMotivations.js
require('dotenv').config();
const mongoose = require('mongoose');
const Motivation = require('./models/motivation');

const messages = [
  { text: "✨ Bugün bir adım at, yarın gururla hatırla.", mood: "neutral" },
  { text: "🔥 Zorluklar seni durdurmasın, seni büyütsün.", mood: "happy" },
  { text: "💪 Rutinlerin gücüyle hedeflerine ulaş!", mood: "happy" },
  { text: "🚀 Küçük adımlar büyük zaferler getirir.", mood: "neutral" },
  { text: "🎯 Hedefsiz gemiye hiçbir rüzgar yardım edemez.", mood: "neutral" },
  { text: "🌟 Güne enerjik başla, verimli bitir.", mood: "happy" },
  { text: "🏃‍♂️ Harekete geçmek başarının yarısıdır.", mood: "happy" },
  { text: "📅 Bugünü iyi planla, yarını kucakla.", mood: "neutral" },
  { text: "🧠 Düşün, planla, uygula, tekrar et.", mood: "neutral" },
  { text: "🌈 Rutinler alışkanlık olur, alışkanlıklar hayatını kurar.", mood: "neutral" },
  { text: "⚡ Şimdi başla, mükemmel olmak zorunda değil.", mood: "sad" },
  { text: "🕒 Her gün sadece 1% ilerlemek bile büyük fark yaratır.", mood: "neutral" },
  { text: "💼 Disiplin seni özgürleştirir.", mood: "happy" },
  { text: "🌄 Yeni bir gün, yeni bir başlangıç.", mood: "sad" },
  { text: "📖 Bilgi birikimi alışkanlıkla büyür.", mood: "neutral" },
  { text: "🚶‍♀️ Hedefe giden yol adımlarla döşenir.", mood: "neutral" },
  { text: "📌 Erteleme, başla.", mood: "sad" },
  { text: "🔑 Anahtar tekrar ve sabırdır.", mood: "neutral" },
  { text: "🛠️ Eylem olmadan vizyon sadece hayaldir.", mood: "happy" },
  { text: "🍀 Şans, hazırlıkla fırsatın kesişmesidir.", mood: "neutral" },
  { text: "🧭 Rutinler yönünü belirler.", mood: "neutral" },
  { text: "📝 Planlayan kazanır.", mood: "neutral" },
  { text: "🥇 Her sabah yeni bir yarış.", mood: "happy" },
  { text: "💡 Işık kendin ol.", mood: "sad" },
  { text: "🌱 Bugün ektiğin yarın yeşerir.", mood: "sad" },
  { text: "🎵 Ritmini kendin belirle.", mood: "neutral" },
  { text: "💬 Kendinle sözleşme yap, her gün yenile.", mood: "neutral" },
  { text: "🧘‍♂️ Sessizlik içinde üretkenlik büyür.", mood: "sad" },
  { text: "🌊 Durgun suya taş at, hareket başlar.", mood: "sad" },
  { text: "🛤️ Küçük raylar büyük trenleri taşır.", mood: "neutral" },
  { text: "🏆 Her gün bir tuğla koy, duvar senin olur.", mood: "neutral" },
  { text: "🦁 Güç rutinde gizlidir.", mood: "happy" },
  { text: "🎮 Her görev bir level.", mood: "happy" },
  { text: "🎙️ Kendi sesini duymak için düzenli çalış.", mood: "sad" },
  { text: "📚 Rutin bilgiyle beslenir.", mood: "neutral" },
  { text: "🔄 Her gün bir alışkanlık, 30 günde değişim.", mood: "neutral" },
  { text: "🚧 Bugün inşa et, yarın içinde yaşa.", mood: "neutral" },
  { text: "🌌 Geceni planla, sabahını kazan.", mood: "neutral" },
  { text: "🎨 Rutinini sanat gibi işle.", mood: "happy" },
  { text: "💎 Zaman senin en değerli yatırımındır.", mood: "neutral" },
  { text: "🧩 Küçük parça büyük resmi tamamlar.", mood: "neutral" },
  { text: "🚲 Dengede kalmak için ilerle.", mood: "sad" },
  { text: "⏳ Zaman akıyor, sen yön ver.", mood: "neutral" },
  { text: "🧱 Bugün attığın temel yarınki bina.", mood: "neutral" },
  { text: "🛎️ Her alarm bir fırsattır.", mood: "happy" },
  { text: "📶 Disiplin başarıyı çeker.", mood: "happy" },
  { text: "📍 Yolda kalmak için tekrar gerekir.", mood: "sad" },
  { text: "🌞 Güne rutinle başla, başarıyla bitir.", mood: "happy" },
  { text: "🔋 Enerjini doğru yere harca.", mood: "neutral" },
  { text: "🗓️ Rutinler günü anlamlı kılar.", mood: "neutral" },
  { text: "🌠 Her gün bir yıldız yakala.", mood: "happy" },
  { text: "🔭 Büyük resme odaklan.", mood: "happy" },
  { text: "💬 İç sesin sana yol gösterir.", mood: "sad" },
  { text: "🛫 Kalkışın sağlam olsun, iniş kolaylaşır.", mood: "happy" },
  { text: "🛡️ Rutin zırhındır.", mood: "sad" },
  { text: "📌 Net hedef net adım getirir.", mood: "neutral" },
  { text: "💤 Erken kalk, erken kazan.", mood: "happy" },
  { text: "🎯 Odak, süper güçtür.", mood: "neutral" },
  { text: "📂 Gününü düzenle, beynin ferahlar.", mood: "neutral" },
  { text: "🕯️ Küçük ışık büyük yolu aydınlatır.", mood: "sad" },
  { text: "🚪 Her sabah yeni bir kapı aç.", mood: "happy" },
  { text: "📦 Karmaşayı düzenle, zihnin rahatlasın.", mood: "neutral" },
  { text: "🎽 Her sabah bir antrenman.", mood: "happy" },
  { text: "🌬️ Rutin nefes gibidir, fark etmeden yaşatır.", mood: "sad" },
  { text: "🖌️ Gününü sen çiz.", mood: "happy" },
  { text: "🎻 Her nota bir görev, her görev bir senfoni.", mood: "neutral" },
  { text: "🏹 Rutin okudur, hedefi vurur.", mood: "happy" },
  { text: "📣 Bugünlük hedefin: Sadece başla.", mood: "sad" },
  { text: "🎥 Her gün bir sahne, sen yönetmensin.", mood: "happy" },
  { text: "🎼 Günlük tekrarlar başarı senfonisidir.", mood: "neutral" },
  { text: "🧱 Duvar değil köprü ör.", mood: "sad" },
  { text: "📔 Günlük rutin, başarı günlüğüdür.", mood: "neutral" },
  { text: "🎡 Dön, ama hep bir adım yukarı.", mood: "happy" },
  { text: "🖇️ Rutin bağ kurar, seninle hedefin arasında.", mood: "neutral" },
];

mongoose.connect(process.env.MONGODB_URI)
  .then(async () => {
    console.log("📦 MongoDB bağlantısı kuruldu, koleksiyon temizleniyor...");
    await Motivation.deleteMany({});
    console.log("🧹 Eski kayıtlar silindi.");
    const inserted = await Motivation.insertMany(messages);
    console.log(`✅ ${inserted.length} motivasyon mesajı başarıyla eklendi.`);
    process.exit();
  })
  .catch(err => {
    console.error("❌ MongoDB bağlantı hatası:", err);
    process.exit(1);
  });