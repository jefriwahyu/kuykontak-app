import 'package:azlistview/azlistview.dart';

class Contact extends ISuspensionBean {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String avatar;
  final String grup;
  final String createdAt;
  final String updatedAt;

  String? tag;

  Contact({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.avatar,
    required this.grup,
    required this.createdAt,
    required this.updatedAt,
  }) {
    if (nama.isEmpty) {
      // Jika nama kosong, masuk ke grup #
      tag = '#';
    } else {
      String firstChar = nama[0].toUpperCase();
      // Cek apakah karakter pertama adalah huruf A-Z
      if (RegExp(r'[A-Z]').hasMatch(firstChar)) {
        // Jika ya, gunakan huruf tersebut sebagai tag
        tag = firstChar;
      } else {
        // Jika tidak (angka, simbol, dll), masuk ke grup #
        tag = '#';
      }
    }
  }

  @override
  String getSuspensionTag() => tag!;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      noHp: json['no_hp'] as String,
      alamat: json['alamat'] as String,
      avatar: json['avatar'] as String,
      grup: json['grup'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
