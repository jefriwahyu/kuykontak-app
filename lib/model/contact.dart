import 'package:azlistview/azlistview.dart';

// Implementasikan kembali ISuspensionBean
class Contact extends ISuspensionBean {
  final String id;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String avatar;
  final String createdAt;
  final String updatedAt;

  // Properti tag untuk pengelompokan
  String? tag;

  Contact({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.avatar,
    required this.createdAt,
    required this.updatedAt,
  }) {
    tag = nama.isNotEmpty ? nama[0].toUpperCase() : '#';
  }

  // Override method yang dibutuhkan azlistview
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
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
