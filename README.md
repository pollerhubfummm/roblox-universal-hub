# 🎮 Roblox Universal Hub – Komplettes Executor GUI

> Ein modernes, leistungsstarkes Script-Hub für Roblox mit umfangreichen Features für PC und Mobile.

![Version](https://img.shields.io/badge/Version-1.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Stable-brightgreen)

---

## 🚀 Features

### GUI & Interface
- ✅ **Draggbar & Resizebar** – Fenster frei positionieren und anpassen
- ✅ **Minimierbar** – GUI zusammenklappen für bessere Sicht
- ✅ **5 Farbthemen** – Dark, Red, Purple, Blue, AMOLED
- ✅ **Animationen & Effekte** – Smooth Transitions und Blur-Effekte
- ✅ **Mobil & PC optimiert** – Responsive Design für alle Geräte
- ✅ **Hotkey System** – Standardmäßig: `RightShift` zum Anzeigen/Verbergen
- ✅ **Panic Button** – `Ctrl + Shift + X` zum sofortigen Schließen

### 📍 Teleport System
- 📌 **Unendlich viele Save-Slots** – Positionen speichern & laden
- 🎯 **Click-to-Teleport** – Klick auf Boden zum Teleportieren
- 🔄 **Undo-Teleport** – Letzte Teleportation rückgängig machen
- 📜 **Teleport History** – Alle bisherigen Positionen speichern
- 🛡️ **Safe Teleport** – Mit einstellbarer Höhe (Standard: +3 Studs)
- ✏️ **Rename/Delete Slots** – Positionen verwalten

### 🚀 Movement System
- 🪁 **Fly Mode** – Mit einstellbarer Geschwindigkeit (0-100)
- 👻 **Noclip** – Durch Wände gehen
- ♾️ **Infinite Jump** – Unbegrenzt hoch springen
- 🏃 **Walk Speed Slider** – Geschwindigkeit anpassen (0-100)
- 📈 **Jump Power Slider** – Sprunghöhe kontrollieren (0-100)
- ⬇️ **Gravity Slider** – Schwerkraft anpassen (0-100)

### ☠️ Death Return
- 💾 **Auto Teleport on Respawn** – Nach Tod automatisch zur gespeicherten Position
- ⏱️ **Cooldown einstellbar** – Verhinderung von Spam
- 📍 **Position auswählbar** – Jeder beliebige Ort möglich

### 🔄 Teleport Loop
- 📍 **Unendlich viele Punkte** – Loop-Route erstellen
- ▶️ **Run Once** – Route einmalig abfahren
- 🔁 **Loop** – Kontinuierliche Wiederholung
- ⚡ **Geschwindigkeit anpassbar** – Zwischen Punkten
- ⏹️ **Stop jederzeit** – Loop unterbrechen

### ⚙️ Utility Features
- 👁️ **ESP (Player)** – Spieler-Namen anzeigen
- 🔍 **Tracer** – Linien zu Spielern zeichnen
- 🎯 **FOV-Kreis** – Sichtfeldanzeige
- 📊 **FPS/Ping Anzeige** – Live Performance Monitor
- 📋 **Koordinaten kopieren** – Position in Clipboard
- 💾 **Settings speichern** – JSON-Export wenn unterstützt

---

## 🛠️ Installation

### Anforderungen
- Ein funktionierender **Roblox Executor** (z.B. Synapse, Script-Ware, etc.)
- **Roblox Game** offen mit aktivem Spiel

### Schritt-für-Schritt

1. **Script kopieren:**
   - `RobloxUniversalHub.lua` Inhalt kopieren

2. **In Executor einfügen:**
   - Script in dein Executor-Fenster einfügen

3. **Ausführen:**
   - Execute-Button klicken

```lua
-- Schnellstart
loadstring(game:HttpGet("https://raw.githubusercontent.com/pollerhubfummm/roblox-universal-hub/main/RobloxUniversalHub.lua"))()
```

---

## 🎮 Steuerung

### Tastatur
| Taste | Funktion |
|-------|----------|
| **RightShift** | GUI An/Aus |
| **W** | Vorwärts (Fly) |
| **A** | Links (Fly) |
| **S** | Rückwärts (Fly) |
| **D** | Rechts (Fly) |
| **Space** | Hoch (Fly) / Jump |
| **Ctrl** | Runter (Fly) |
| **Ctrl+Shift+X** | ⛔ Panic Button |

### Maus
| Aktion | Funktion |
|--------|----------|
| **Linksklick auf Button** | Aktion ausführen |
| **Ziehen am Top Bar** | GUI verschieben |
| **Slider ziehen** | Wert ändern |

---

## 📊 GUI Struktur

```
🎮 Roblox Universal Hub v1.0      [−] [×]
├── 📍 Teleport
│   ├── Save Current Position
│   ├── Click to Teleport
│   ├── Undo Teleport
│   └── Safe Teleport
├── 🚀 Movement
│   ├── Fly [ON/OFF]
│   ├── Noclip [ON/OFF]
│   ├── Infinite Jump [ON/OFF]
│   ├── Walk Speed Slider
│   ├── Jump Power Slider
│   └── Gravity Slider
├── ⚙️ Utility
│   ├── Enable ESP
│   ├── Copy Coordinates
│   └── Show FPS/Ping
├── ☠️ Death Return
│   ├── Set Death Position
│   └── Enable Auto Return
└── 🔧 Settings
    ├── Theme: Dark
    ├── Theme: Red
    ├── Theme: Purple
    ├── Theme: Blue
    └── Theme: AMOLED
```

---

## 🎨 Farbthemen

### Dark (Default)
```
Primär: #191919
Sekundär: #282828
Accent: #64C8FF
```

### Red
```
Primär: #281919
Sekundär: #3C2323
Accent: #FF5050
```

### Purple
```
Primär: #231D2D
Sekundär: #323341
Accent: #C864FF
```

### Blue
```
Primär: #192332
Sekundär: #233247
Accent: #6496FF
```

### AMOLED
```
Primär: #000000
Sekundär: #0F0F0F
Accent: #64C8FF
```

---

## 💾 Daten speichern

Das Script speichert automatisch:
- 📌 Teleport-Positionen
- 🎨 Gewählte Einstellungen
- 📍 Zuletzt genutzte Positionen

**JSON Export (wenn Executor unterstützt):**
```json
{
  "teleportSlots": {
    "Spawn": [0, 10, 0],
    "Shop": [100, 5, 50]
  },
  "currentTheme": "Dark",
  "walkSpeed": 50,
  "gravity": 196.2
}
```

---

## 🔧 Anpassung & Development

### Custom Theme erstellen
```lua
local myTheme = {
    primary = Color3.fromRGB(30, 30, 30),
    secondary = Color3.fromRGB(50, 50, 50),
    accent = Color3.fromRGB(255, 150, 0),
    text = Color3.fromRGB(255, 255, 255),
}
```

### Neuen Button hinzufügen
```lua
hub:addButton(tabContent, "Mein Button", function()
    print("Button geklickt!")
end, 175)
```

### Neuen Slider hinzufügen
```lua
hub:addSlider(tabContent, "Mein Slider", 0, 100, 50, function(value)
    print("Wert: " .. value)
end, 235)
```

---

## 📝 Code-Qualität

- ✅ **Keine Memory Leaks** – Alle Connections werden korrekt gelöst
- ✅ **Single-File** – Alles in einer Datei (1.000+ Zeilen)
- ✅ **Executor-kompatibel** – Funktioniert mit allen gängigen Exploits
- ✅ **Optimiert** – Minimale Performance-Auswirkung
- ✅ **Modular** – Einfach erweiterbar

---

## 🐛 Fehlerbehandlung

### Häufige Probleme

**Problem:** GUI wird nicht angezeigt
- **Lösung:** Script mit Doppelklick ausführen, nicht kopieren

**Problem:** Fly funktioniert nicht
- **Lösung:** Sicherstellen, dass Character existiert (Character:WaitForChild)

**Problem:** Teleport funktioniert nicht
- **Lösung:** Position muss auf dem Boden sein, nicht in der Luft

---

## 📚 Weitere Hinweise

- 🔐 **Nicht für Exploiting verwenden** – Nur zum Testen gedacht
- ⚠️ **Bans möglich** – Nutze auf eigenes Risiko
- 💬 **Feedback erwünscht** – Issues und Pull Requests welcome
- 🎯 **Continuous Updates** – Script wird regelmäßig aktualisiert

---

## 📄 Lizenz

Dieses Projekt steht unter der **MIT Lizenz**. Siehe [LICENSE](LICENSE) für Details.

---

## 👤 Autor

**GitHub:** [@pollerhubfummm](https://github.com/pollerhubfummm)

---

## 🙏 Credits

- Inspiriert von: Synapse, Script-Ware, Executor-Hubs
- GUI-Framework: Roblox GUI Services
- Community-Input: Danke an alle Tester!

---

<div align="center">
  <p>⭐ Wenn dir das Projekt gefällt, gib einen Star! ⭐</p>
  <p><strong>Made with ❤️ für die Roblox Community</strong></p>
</div>