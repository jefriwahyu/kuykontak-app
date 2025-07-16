// lib/helpers/api_url.dart

// Enum untuk memilih jenis API
enum ApiType { express, codeigniter }

// Ganti ke ApiType.codeigniter jika ingin menguji backend CI4
const ApiType currentApi =
    ApiType.codeigniter; // <-- GANTI KE CODEIGNITER UNTUK MENGUJI
// -----------------------------------------

class ApiUrl {
  // Definisikan base URL murni (tanpa path)
  static const String _expressBase = 'https://manu.my.id';

  // PENTING: Ganti localhost ke 10.0.2.2 untuk emulator Android
  static const String _ci4Base = 'https://kontak-api.tinagers.com';

  // Definisikan path lengkap untuk setiap endpoint
  static const String _expressContactsPath = '/api/kontak';
  static const String _expressUploadPath = '/api/kontak/upload';
  static const String _expressToggleFavoritePath =
      '/api/kontak/favorite'; // Path favorit Express

  static const String _ci4ContactsPath = '/api/kontak';
  static const String _ci4UploadPath = '/api/upload';
  static const String _ci4ToggleFavoritePath =
      '/api/kontak/favorite'; // Path favorit CI4

  // Getter dinamis untuk URL kontak (sudah ada)
  static String get contactsUrl {
    if (currentApi == ApiType.express) {
      return _expressBase + _expressContactsPath;
    } else {
      return _ci4Base + _ci4ContactsPath;
    }
  }

  // Getter dinamis untuk URL upload (sudah ada)
  static String get uploadUrl {
    if (currentApi == ApiType.express) {
      return _expressBase + _expressUploadPath;
    } else {
      return _ci4Base + _ci4UploadPath;
    }
  }

  // === TAMBAHKAN FUNGSI BARU INI ===
  // Fungsi untuk membuat URL toggle favorite dengan ID
  static String toggleFavoriteUrl(String id) {
    if (currentApi == ApiType.express) {
      // URL untuk Express: .../api/kontak/favorite/:id
      return _expressBase + _expressToggleFavoritePath + '/$id';
    } else {
      // URL untuk CI4: .../api/contacts/favorite/:id
      return _ci4Base + _ci4ToggleFavoritePath + '/$id';
    }
  }
}
