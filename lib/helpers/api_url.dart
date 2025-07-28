// Lokasi: lib/helpers/api_url.dart

// Mengelola semua URL endpoint untuk API.
class ApiUrl {
  // Base URL utama untuk API.
  static const String _baseUrl = 'https://kontak-api.tinagers.com';

  // Path spesifik untuk setiap endpoint.
  static const String _contactsPath = '/api/kontak';
  static const String _uploadPath = '/api/upload';
  static const String _toggleFavoritePath = '/api/kontak/favorite';

  // URL untuk endpoint data kontak.
  static String get contactsUrl {
    return _baseUrl + _contactsPath;
  }

  // URL untuk endpoint upload gambar.
  static String get uploadUrl {
    return _baseUrl + _uploadPath;
  }

  // URL untuk mengubah status favorit kontak berdasarkan ID.
  static String toggleFavoriteUrl(String id) {
    return '$_baseUrl$_toggleFavoritePath/$id';
  }
}
