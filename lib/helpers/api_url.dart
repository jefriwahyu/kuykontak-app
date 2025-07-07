// Enum untuk memilih jenis API
enum ApiType { express, codeigniter }

// --- GANTI DI SINI UNTUK MEMILIH BACKEND ---
// Ganti ke ApiType.codeigniter jika ingin menguji backend CI4
const ApiType currentApi = ApiType.express;
// -----------------------------------------

class ApiUrl {
  // 1. Definisikan base URL murni (tanpa path)
  static const String _expressBase = 'http://localhost:3000'; // Sesuaikan port
  static const String _ci4Base = 'https://localhost:8080'; // Sesuaikan port

  // 2. Definisikan path lengkap untuk setiap endpoint
  static const String _expressContactsPath = '/api/kontak';
  static const String _expressUploadPath = '/api/kontak/upload';

  static const String _ci4ContactsPath = '/api/kontak';
  static const String _ci4UploadPath = '/api/upload';

  // 3. Buat getter dinamis untuk mendapatkan URL yang benar
  static String get contactsUrl {
    if (currentApi == ApiType.express) {
      return _expressBase + _expressContactsPath;
    } else {
      return _ci4Base + _ci4ContactsPath;
    }
  }

  static String get uploadUrl {
    if (currentApi == ApiType.express) {
      return _expressBase + _expressUploadPath;
    } else {
      return _ci4Base + _ci4UploadPath;
    }
  }
}
