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
  final bool isFavorite;

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
    this.isFavorite = false,
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
        // Jika tidak (angka, simbol, dll), masuk ke grup
        tag = '#';
      }
    }
  }

  @override
  String getSuspensionTag() => tag!;

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] ?? json['id'],
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      avatar: json['avatar'] ?? '',
      grup: json['grup'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'no_hp': noHp,
      'email': email,
      'avatar': avatar,
      'alamat': alamat,
      'grup': grup,
      'isFavorite': isFavorite,
    };
  }

  Contact copyWith({
    String? id,
    String? nama,
    String? email,
    String? noHp,
    String? alamat,
    String? avatar,
    String? grup,
    String? createdAt,
    String? updatedAt,
    bool? isFavorite,
  }) {
    return Contact(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      alamat: alamat ?? this.alamat,
      avatar: avatar ?? this.avatar,
      grup: grup ?? this.grup,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
