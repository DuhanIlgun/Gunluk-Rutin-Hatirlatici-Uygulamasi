// Hatırlatıcıları almak ve eklemek için fonksiyon
function loadReminders() {
    const reminders = JSON.parse(localStorage.getItem("reminders")) || [];
    const reminderList = document.getElementById("reminderList");
    reminderList.innerHTML = ""; // Önceden eklenmiş hatırlatıcıları temizle

    reminders.forEach(item => {
        const li = document.createElement("li");
        li.textContent = `${item.reminder} - ${new Date(item.time).toLocaleString()}`;
        reminderList.appendChild(li);
    });
}

// Hatırlatıcıyı kaydetme fonksiyonu
function saveReminder(reminder, time) {
    const reminders = JSON.parse(localStorage.getItem("reminders")) || [];
    reminders.push({ reminder, time });
    localStorage.setItem("reminders", JSON.stringify(reminders));
}

// Hatalı giriş kontrolü
document.getElementById("reminderForm").addEventListener("submit", function(e) {
    e.preventDefault();
    const reminderText = document.getElementById("reminderInput").value;
    const reminderTime = document.getElementById("reminderTime").value;

    if (reminderText === "" || reminderTime === "") {
        alert("Lütfen tüm alanları doldurun.");
    } else {
        saveReminder(reminderText, reminderTime);
        loadReminders();
        document.getElementById("reminderInput").value = ""; // Input'u sıfırla
        document.getElementById("reminderTime").value = ""; // Saat seçiciyi sıfırla
    }
});

// Zamanı kontrol et
setInterval(checkReminders, 60000); // Her dakika kontrol et

// Hatırlatıcıları kontrol et ve bildirim gönder
function checkReminders() {
    const reminders = JSON.parse(localStorage.getItem("reminders")) || [];
    const currentTime = new Date().getTime();

    reminders.forEach((item, index) => {
        const reminderTime = new Date(item.time).getTime();
        if (reminderTime <= currentTime) {
            alert(`Hatırlatıcı: ${item.reminder}`);
            reminders.splice(index, 1); // Hatırlatıcıyı sil
            localStorage.setItem("reminders", JSON.stringify(reminders));
        }
    });
}

// Sayfa yüklendiğinde hatırlatıcıları yükle
loadReminders();
