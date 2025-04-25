const apiURL = "http://localhost:5000/api/reminders";

// Hatırlatıcıları çek
async function loadReminders() {
    const response = await fetch(apiURL);
    const reminders = await response.json();

    const reminderList = document.getElementById("reminderList");
    reminderList.innerHTML = "";

    reminders.forEach(item => {
        const li = document.createElement("li");
        li.textContent = `${item.text} - ${new Date(item.time).toLocaleString()}`;

        // 🔴 Sil butonu
        const deleteBtn = document.createElement("button");
        deleteBtn.textContent = "Sil";
        deleteBtn.style.marginLeft = "10px";
        deleteBtn.onclick = async () => {
            await fetch(`${apiURL}/${item._id}`, { method: "DELETE" });
            loadReminders();
        };

        li.appendChild(deleteBtn);
        reminderList.appendChild(li);
    });
}
// Hatırlatıcı ekle
async function saveReminder(reminder, time) {
    await fetch(apiURL, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({ text: reminder, time }),
    });
}

// Form gönderimi
document.getElementById("reminderForm").addEventListener("submit", async function(e) {
    e.preventDefault();
    const reminderText = document.getElementById("reminderInput").value;
    const reminderTime = document.getElementById("reminderTime").value;

    if (reminderText === "" || reminderTime === "") {
        alert("Lütfen tüm alanları doldurun.");
    } else {
        await saveReminder(reminderText, reminderTime);
        await loadReminders();

        document.getElementById("reminderInput").value = "";
        document.getElementById("reminderTime").value = "";
    }
});

// Zamanı kontrol et
setInterval(checkReminders, 60000);

async function checkReminders() {
    const response = await fetch(apiURL);
    const reminders = await response.json();
    const currentTime = new Date().getTime();

    for (let item of reminders) {
        const reminderTime = new Date(item.time).getTime();
        if (reminderTime <= currentTime) {
            alert(`Hatırlatıcı: ${item.text}`);
            // İsteğe bağlı: otomatik silme ekleyebiliriz
        }
    }
}

// Sayfa açıldığında yükle
loadReminders();
