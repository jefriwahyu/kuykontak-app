// Enum untuk memilih jenis API
enum ApiType { express, codeigniter }

// Ganti ke ApiType.codeigniter jika ingin menguji backend CI4
const ApiType currentApi = ApiType.express;
// -----------------------------------------

class ApiUrl {
  //Definisikan base URL murni (tanpa path)
  static const String _expressBase = 'https://manu.my.id'; // Sesuaikan port
  static const String _ci4Base =
      'https://kontak-api.tinagers.com'; // Sesuaikan port

  //Definisikan path lengkap untuk setiap endpoint
  static const String _expressContactsPath = '/api/kontak';
  static const String _expressUploadPath = '/api/kontak/upload';

  static const String _ci4ContactsPath = '/api/kontak';
  static const String _ci4UploadPath = '/api/upload';

  //Buat getter dinamis untuk mendapatkan URL yang benar
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
