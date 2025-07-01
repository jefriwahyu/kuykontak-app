import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/theme.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  const ContactDetailPage({super.key, required this.contact});

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kontak')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // --- PERBAIKAN AVATAR DI SINI ---
            Center(
              child: Container(
                width: 100, // diameter 100
                height: 100, // diameter 100
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.2),
                  // Tampilkan gambar sebagai background dari container
                  image: contact.avatar.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(contact.avatar),
                          fit: BoxFit
                              .cover, // Atur cara gambar mengisi lingkaran
                        )
                      : null,
                ),
                // Tampilkan inisial HANYA jika tidak ada gambar
                child: contact.avatar.isEmpty
                    ? Center(
                        child: Text(
                          contact.nama.isNotEmpty
                              ? contact.nama[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('Nama', contact.nama),
                    const SizedBox(height: 20),
                    _buildDetailItem('No. Hp', contact.noHp),
                    const SizedBox(height: 20),
                    _buildDetailItem('Email', contact.email),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Ubah'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditContactPage(contact: contact),
                        ));
                  },
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(backgroundColor: deleteColor),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('Konfirmasi Hapus'),
                          content: Text(
                              'Apakah Anda yakin ingin menghapus kontak "${contact.nama}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                context
                                    .read<ContactBloc>()
                                    .add(DeleteContact(contact.id));
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Hapus',
                                  style: TextStyle(color: deleteColor)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
