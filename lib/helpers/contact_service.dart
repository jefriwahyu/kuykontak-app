// lib/helpers/contact_service.dart

import 'dart:typed_data'; // Pastikan import ini ada
import 'package:dio/dio.dart';
import 'package:kontak_app_m/helpers/api_url.dart';
import 'package:kontak_app_m/model/contact.dart';

class ContactService {
  static final Dio _dio = Dio();

  static Future<List<Contact>> getContacts() async {
    final response =
        await _dio.get(ApiUrl.contactsUrl); // Menggunakan getter baru
    final List<dynamic> data = response.data['data'];
    return data.map((json) => Contact.fromJson(json)).toList();
  }

  static Future<void> addContact(Map<String, String> data) async {
    await _dio.post(ApiUrl.contactsUrl, data: data); // Menggunakan getter baru
  }

  static Future<void> updateContact(String id, Map<String, String> data) async {
    await _dio.put('${ApiUrl.contactsUrl}/$id',
        data: data); // Menggunakan getter baru
  }

  static Future<void> deleteContact(String id) async {
    await _dio.delete('${ApiUrl.contactsUrl}/$id'); // Menggunakan getter baru
  }

  static Future<String?> uploadAvatar(
      Uint8List imageBytes, String fileName) async {
    try {
      FormData formData = FormData.fromMap({
        "avatar": MultipartFile.fromBytes(imageBytes, filename: fileName),
      });

      // Menggunakan getter uploadUrl yang baru
      final response = await _dio.post(ApiUrl.uploadUrl, data: formData);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
