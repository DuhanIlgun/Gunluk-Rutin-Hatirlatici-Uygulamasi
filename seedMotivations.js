// seedMotivations.js
require('dotenv').config();
const mongoose = require('mongoose');
const Motivation = require('./models/motivation');

const messages = [
  "✨ Bugün bir adım at, yarın gururla hatırla.",
  "🔥 Zorluklar seni durdurmasın, seni büyütsün.",
  "💪 Rutinlerin gücüyle hedeflerine ulaş!",
  "🚀 Küçük adımlar büyük zaferler getirir.",
  "🎯 Hedefsiz gemiye hiçbir rüzgar yardım edemez.",
  "🌟 Güne enerjik başla, verimli bitir.",
  "🏃‍♂️ Harekete geçmek başarının yarısıdır.",
  "📅 Bugünü iyi planla, yarını kucakla.",
  "🧠 Düşün, planla, uygula, tekrar et.",
  "🌈 Rutinler alışkanlık olur, alışkanlıklar hayatını kurar.",
  "⚡ Şimdi başla, mükemmel olmak zorunda değil.",
  "🕒 Her gün sadece 1% ilerlemek bile büyük fark yaratır.",
  "💼 Disiplin seni özgürleştirir.",
  "🌄 Yeni bir gün, yeni bir başlangıç.",
  "📖 Bilgi birikimi alışkanlıkla büyür.",
  "🚶‍♀️ Hedefe giden yol adımlarla döşenir.",
  "📌 Erteleme, başla.",
  "🔑 Anahtar tekrar ve sabırdır.",
  "🛠️ Eylem olmadan vizyon sadece hayaldir.",
  "🍀 Şans, hazırlıkla fırsatın kesişmesidir.",
  "🧭 Rutinler yönünü belirler.",
  "📝 Planlayan kazanır.",
  "🥇 Her sabah yeni bir yarış.",
  "💡 Işık kendin ol.",
  "🌱 Bugün ektiğin yarın yeşerir.",
  "🎵 Ritmini kendin belirle.",
  "💬 Kendinle sözleşme yap, her gün yenile.",
  "🧘‍♂️ Sessizlik içinde üretkenlik büyür.",
  "🌊 Durgun suya taş at, hareket başlar.",
  "🛤️ Küçük raylar büyük trenleri taşır.",
  "🏆 Her gün bir tuğla koy, duvar senin olur.",
  "🦁 Güç rutinde gizlidir.",
  "🎮 Her görev bir level.",
  "🎙️ Kendi sesini duymak için düzenli çalış.",
  "📚 Rutin bilgiyle beslenir.",
  "🔄 Her gün bir alışkanlık, 30 günde değişim.",
  "🚧 Bugün inşa et, yarın içinde yaşa.",
  "🌌 Geceni planla, sabahını kazan.",
  "🎨 Rutinini sanat gibi işle.",
  "💎 Zaman senin en değerli yatırımındır.",
  "🧩 Küçük parça büyük resmi tamamlar.",
  "🚲 Dengede kalmak için ilerle.",
  "⏳ Zaman akıyor, sen yön ver.",
  "🧱 Bugün attığın temel yarınki bina.",
  "🛎️ Her alarm bir fırsattır.",
  "📶 Disiplin başarıyı çeker.",
  "📍 Yolda kalmak için tekrar gerekir.",
  "🌞 Güne rutinle başla, başarıyla bitir.",
  "🔋 Enerjini doğru yere harca.",
  "🗓️ Rutinler günü anlamlı kılar.",
  "🌠 Her gün bir yıldız yakala.",
  "🔭 Büyük resme odaklan.",
  "💬 İç sesin sana yol gösterir.",
  "🛫 Kalkışın sağlam olsun, iniş kolaylaşır.",
  "🛡️ Rutin zırhındır.",
  "📌 Net hedef net adım getirir.",
  "💤 Erken kalk, erken kazan.",
  "🎯 Odak, süper güçtür.",
  "📂 Gününü düzenle, beynin ferahlar.",
  "🕯️ Küçük ışık büyük yolu aydınlatır.",
  "🚪 Her sabah yeni bir kapı aç.",
  "📦 Karmaşayı düzenle, zihnin rahatlasın.",
  "🎽 Her sabah bir antrenman.",
  "🌬️ Rutin nefes gibidir, fark etmeden yaşatır.",
  "🖌️ Gününü sen çiz.",
  "🎻 Her nota bir görev, her görev bir senfoni.",
  "🏹 Rutin okudur, hedefi vurur.",
  "📣 Bugünlük hedefin: Sadece başla.",
  "🎥 Her gün bir sahne, sen yönetmensin.",
  "🎼 Günlük tekrarlar başarı senfonisidir.",
  "🧱 Duvar değil köprü ör.",
  "📔 Günlük rutin, başarı günlüğüdür.",
  "🎡 Dön, ama hep bir adım yukarı.",
  "🖇️ Rutin bağ kurar, seninle hedefin arasında."
];

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(async () => {
  console.log("📦 MongoDB bağlantısı kuruldu, seed işlemi başlıyor...");

  await Motivation.deleteMany();
  const inserted = await Motivation.insertMany(messages.map(text => ({ text })));

  console.log(`✅ ${inserted.length} motivasyon mesajı eklendi.`);
  process.exit();
}).catch(err => {
  console.error("❌ MongoDB bağlantı hatası:", err);
  process.exit(1);
});
