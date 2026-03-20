# Yomi (読み) 📖
A clean, ad-free web novel reader with a Tachiyomi-inspired UI, built using Flutter and a local XAMPP (MySQL/PHP) backend.

---

## 📸 Screenshots

<div align="center">
  <img src="screenshots/media.png" width="200" alt="Browse"/>
  <img src="screenshots/media1.png" width="200" alt="Reader"/>
  <img src="screenshots/media2.png" width="200" alt="Library"/>
  <img src="screenshots/media3.png" width="200" alt="Login"/>
</div>

---

## ✨ Features
- **Tachiyomi-Inspired UI**: Beautiful dark theme with grid layouts for easy browsing.
- **Local Database Sync**: Your reading progress and library are stored in a local MySQL database.
- **Distraction-Free Reader**: Adjustable font sizes and a seamless vertical scrolling experience.
- **Secure Authentication**: Local Login/Signup system powered by PHP and password hashing.

---

## 🛠️ Tech Stack
* **Frontend**: Flutter (Dart) — Supports Web, Windows, and Mobile.
* **Backend**: PHP REST API (served via Apache/XAMPP).
* **Database**: MySQL.
* **Storage**: Local filesystem for novel cover images.

---

## 🚀 Getting Started Locally

### 1. Prerequisites
- **XAMPP** installed (Apache and MySQL must be running).
- **Flutter SDK** installed.

### 2. Backend Setup
1. Create a folder: `C:\xampp\htdocs\yomi_api\`.
2. Copy the API files (`api.php`, `covers/`, etc.) into that folder.
3. Open **phpMyAdmin**, create a database named `yomi_db`, and import the `yomi_db.sql` file.

### 3. Frontend Setup
1. Clone the repository and navigate to the app folder:
   ```bash
   cd yomi/yomi_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the App:
   ```bash
   flutter run -d chrome
   ```

*(Note: The app is configured to communicate with `http://localhost/yomi_api/api.php`.)*
