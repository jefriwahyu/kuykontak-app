import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:kontak_app_m/helpers/api_url.dart';
import 'package:kontak_app_m/model/contact.dart';

// Menangani semua komunikasi dengan API untuk data kontak.
class ContactService {
  // Instance Dio yang digunakan untuk semua permintaan jaringan.
  static final Dio _dio = Dio();

  // Mengambil semua data kontak dari API.
  static Future<List<Contact>> getContacts() async {
    final response = await _dio.get(ApiUrl.contactsUrl);
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Contact.fromJson(json)).toList();
  }

  // Menambahkan kontak baru ke server.
  static Future<void> addContact(Map<String, String> data) async {
    await _dio.post(ApiUrl.contactsUrl, data: data);
  }

  // Memperbarui data kontak berdasarkan ID.
  static Future<void> updateContact(String id, Map<String, String> data) async {
    await _dio.put('${ApiUrl.contactsUrl}/$id', data: data);
  }

  // Menghapus kontak dari server berdasarkan ID.
  static Future<void> deleteContact(String id) async {
    await _dio.delete('${ApiUrl.contactsUrl}/$id');
  }

  // Mengunggah file gambar avatar dan mengembalikan URL-nya.
  static Future<String?> uploadAvatar(
      Uint8List imageBytes, String fileName) async {
    try {
      // Siapkan data gambar dalam format multipart/form-data.
      FormData formData = FormData.fromMap({
        "avatar": MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      final response = await _dio.post(ApiUrl.uploadUrl, data: formData);

      // Jika sukses, kembalikan URL gambar yang diunggah.
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Mengirim daftar kontak untuk sinkronisasi massal.
  static Future<String> syncContacts(
      List<Map<String, dynamic>> contacts) async {
    try {
      final response = await _dio
          .post('${ApiUrl.contactsUrl}/sync', data: {'contacts': contacts});
      return response.data['message'] ?? 'Sinkronisasi selesai.';
    } on DioException catch (e) {
      // Tangani error spesifik dari Dio untuk pesan yang lebih jelas.
      final errorMessage =
          e.response?.data['message'] ?? 'Gagal melakukan sinkronisasi.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga.');
    }
  }

  // Mengubah status favorit kontak (true/false) dengan metode PATCH.
  static Future<Map<String, dynamic>> toggleFavorite(String id) async {
    try {
      print('Toggling favorite for contact ID: $id');

      // Coba dengan URL yang sudah ada
      final url = ApiUrl.toggleFavoriteUrl(id);
      print('Toggle URL: $url');

      final response = await _dio.patch(url);
      print('Toggle response: ${response.data}');

      // Kembalikan data yang diperbarui dari server
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      print('Dio error saat toggle favorite: ${e.message}');
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');

      // Jika error, return nilai default untuk testing UI
      return {
        'id': id,
        'is_favorite': 1, // Asumsi jadi favorite
      };
    } catch (e) {
      print('Error lain: $e');
      // Return nilai default untuk testing UI
      return {
        'id': id,
        'is_favorite': 1,
      };
    }
  }
}
