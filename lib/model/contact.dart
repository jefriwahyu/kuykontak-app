import 'package:azlistview/azlistview.dart';

// Model data kontak dengan dukungan AZListView (index sidebar A-Z)
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

  String? tag; // Tag untuk pengelompokan AZListView (A-Z, #)

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
    this.isFavorite = false, // Default false jika tidak diisi
  }) {
    // Logika menentukan tag untuk pengelompokan
    if (nama.isEmpty) {
      tag = '#'; // Grup khusus untuk nama kosong
    } else {
      String firstChar = nama[0].toUpperCase();
      if (RegExp(r'[A-Z]').hasMatch(firstChar)) {
        tag = firstChar; // Grup berdasarkan huruf pertama
      } else {
        tag = '#'; // Grup khusus untuk karakter non-alfabet
      }
    }
  }

  @override
  String getSuspensionTag() => tag!; // Required oleh ISuspensionBean

  // Factory constructor untuk parsing dari JSON
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] ?? json['id'], // Handle alternatif field '_id'
      nama: json['nama'] ?? '', // Default empty string jika null
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
      alamat: json['alamat'] ?? '',
      avatar: json['avatar'] ?? '',
      grup: json['grup'] ?? '',
      createdAt: json['createdAt']?.toString() ?? '', // Konversi ke string
      updatedAt: json['updatedAt']?.toString() ?? '',
      isFavorite: json['isFavorite'] == true ||
          json['isFavorite'] == 1, // Handle bool/int
    );
  }

  // Konversi ke format JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'no_hp': noHp,
      'email': email,
      'avatar': avatar,
      'alamat': alamat,
      'grup': grup,
      'isFavorite': isFavorite, // Hanya field yang diperlukan untuk update
    };
  }

  // Method untuk membuat salinan dengan beberapa field yang diupdate
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
      id: id ?? this.id, // Gunakan nilai baru jika ada, else gunakan yang lama
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
