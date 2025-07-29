# 📱 KuyKontak App

<div align="center">

**Aplikasi Manajemen Kontak Modern dengan Flutter & CodeIgniter 4**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![CodeIgniter](https://img.shields.io/badge/CodeIgniter-EF4223?style=for-the-badge&logo=codeigniter&logoColor=white)](https://codeigniter.com)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://mysql.com)

</div>

---

## 📋 Deskripsi

**KuyKontak** adalah aplikasi mobile manajemen kontak yang dikembangkan menggunakan **Flutter** dan **CodeIgniter 4** sebagai backend API. Aplikasi ini memungkinkan pengguna untuk menyimpan, mengelola, dan mengatur informasi kontak dengan mudah dan efisien melalui interface mobile yang intuitif.

### ✨ Fitur Utama

🎯 **Tambah Kontak** - Menambahkan kontak baru dengan informasi lengkap  
✏️ **Edit Kontak** - Mengubah informasi kontak yang sudah ada  
🗑️ **Hapus Kontak** - Menghapus kontak yang tidak diperlukan  
🔍 **Pencarian Kontak** - Mencari kontak berdasarkan nama atau nomor telepon  
📂 **Kategorisasi** - Mengorganisir kontak dalam kategori tertentu  
🔄 **Sinkronisasi Real-time** - Data tersinkronisasi dengan server  
📱 **Interface Mobile** - Tampilan yang responsif dan user-friendly untuk perangkat mobile

### 🛠️ Teknologi yang Digunakan

- **Mobile App**: Flutter (Dart)
- **Backend API**: CodeIgniter 4 (PHP)
- **Database**: MySQL
- **Server**: Apache/Nginx
- **API**: RESTful API

---

## 📦 Langkah-langkah Penginstalan

### 🔧 Prasyarat

Pastikan tools berikut sudah terinstall di sistem Anda:

**📱 Untuk Flutter Development**
- [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/docs/get-started/install) (versi 3.0+)
- [![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white)](https://git-scm.com/)
- [![Android Studio](https://img.shields.io/badge/Android%20Studio-3DDC84?style=flat&logo=android-studio&logoColor=white)](https://developer.android.com/studio) atau [![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=flat&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)

**🚀 Untuk Backend Development (Opsional)**
- [![PHP](https://img.shields.io/badge/PHP-777BB4?style=flat&logo=php&logoColor=white)](https://www.php.net/downloads.php) (versi 8.0+)
- [![Composer](https://img.shields.io/badge/Composer-885630?style=flat&logo=composer&logoColor=white)](https://getcomposer.org/)
- [![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat&logo=mysql&logoColor=white)](https://dev.mysql.com/downloads/)
- [![XAMPP](https://img.shields.io/badge/XAMPP-FB7A24?style=flat&logo=xampp&logoColor=white)](https://www.apachefriends.org/) atau [![Laragon](https://img.shields.io/badge/Laragon-0E83CD?style=flat&logoColor=white)](https://laragon.org/)

---

### 📱 A. Setup Aplikasi Flutter

#### 1️⃣ Clone Repository
```bash
git clone https://github.com/jefriwahyu/kuykontak-app.git
cd kuykontak-app
```

#### 2️⃣ Install Dependencies
```bash
flutter pub get
```

#### 3️⃣ Konfigurasi API Endpoint
Edit file `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // 🌐 Production API (Recommended)
  static const String baseUrl = 'https://kontak-api.tinagers.com/';
  
  // 🏠 Local Development (Uncomment jika testing di localhost)
  // static const String baseUrl = 'http://localhost/kontak-api-ci4/public/';
}
```

#### 4️⃣ Jalankan Aplikasi
```bash
# 📱 Cek device yang tersedia
flutter devices

# 🚀 Run di emulator/device
flutter run

# 📦 Build APK untuk production
flutter build apk --release
```

---

### 🚀 B. Setup Backend API (Untuk Development Lokal)

> 💡 **Note**: Bagian ini opsional jika Anda hanya ingin menggunakan production API: `https://kontak-api.tinagers.com/`

#### 1️⃣ Clone Backend Repository
```bash
git clone https://github.com/jefriwahyu/kontak-api-ci4.git
cd kontak-api-ci4
```

#### 2️⃣ Install Dependencies
```bash
composer install
```

#### 3️⃣ Konfigurasi Environment
```bash
cp env .env
```

Edit file `.env`:
```bash
#--------------------------------------------------------------------
# DATABASE
#--------------------------------------------------------------------
database.default.hostname = localhost
database.default.database = kuykontak_db
database.default.username = root
database.default.password = 
database.default.DBDriver = MySQLi
database.default.port = 3306

#--------------------------------------------------------------------
# ENVIRONMENT
#--------------------------------------------------------------------
CI_ENVIRONMENT = development

#--------------------------------------------------------------------
# APP
#--------------------------------------------------------------------
app.baseURL = 'http://localhost/kontak-api-ci4/public/'
```

#### 4️⃣ Setup Database
```bash
# Buat database
mysql -u root -p
CREATE DATABASE kuykontak_db;
exit
```

#### 5️⃣ Migrasi Database
```bash
php spark migrate
```

#### 6️⃣ Jalankan Server
```bash
# Built-in PHP server
php spark serve

# Atau akses via XAMPP/Laragon
# http://localhost/kontak-api-ci4/public/
```

#### 7️⃣ Test API
```bash
curl http://localhost:8080/api/contacts
```

---

## 📸 Screenshot Tampilan

<div align="center">

### 🏠 Halaman Utama
<img src="screenshots/homepage.png" width="250" alt="Halaman Utama KuyKontak"/>

*Tampilan halaman utama dengan daftar kontak yang elegan*

---

### ➕ Tambah Kontak
<img src="screenshots/add-contact.png" width="250" alt="Tambah Kontak"/>

*Form intuitif untuk menambahkan kontak baru*

---

### 👤 Detail Kontak
<img src="screenshots/contact-detail.png" width="250" alt="Detail Kontak"/>

*Halaman detail dengan informasi kontak lengkap*

---

### 🔍 Pencarian Kontak
<img src="screenshots/search-contact.png" width="250" alt="Pencarian Kontak"/>

*Fitur pencarian cerdas dan responsif*

---

### ✏️ Edit Kontak
<img src="screenshots/edit-contact.png" width="250" alt="Edit Kontak"/>

*Interface untuk mengubah informasi kontak*

</div>

---

## 🎥 Link Video Demo

<div align="center">

[![Demo Video KuyKontak App](https://img.shields.io/badge/▶️%20TONTON%20VIDEO%20DEMO-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/your-video-link)

**[🎬 Klik di sini untuk menonton demo video lengkap](https://youtu.be/your-video-link)**

</div>

### 📹 Yang Ditampilkan di Video:
- ⚡ **Instalasi & Setup** - Cara install dan menjalankan aplikasi
- 🎯 **Demo Fitur** - Walkthrough semua fitur utama aplikasi
- 📱 **Penggunaan** - Tutorial lengkap cara menggunakan aplikasi
- 🔧 **Tips Development** - Panduan untuk developer

---

<div align="center">

**Made with ❤️ by [Jefri Wahyu](https://github.com/jefriwahyu)**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/jefriwahyu)

</div>
