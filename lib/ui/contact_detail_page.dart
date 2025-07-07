import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:kontak_app_m/helpers/slide_right_route.dart';

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
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactActionSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
        if (state is ContactError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail Kontak')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.2),
                    image: contact.avatar.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(contact.avatar),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
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

              // --- PERUBAHAN KEDUA TOMBOL DI SINI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tombol Ubah (Icon)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: primaryColor, // Menggunakan warna tema utama
                    iconSize: 32,
                    tooltip: 'Ubah Kontak',
                    onPressed: () {
                      Navigator.push(
                          context,
                          SlideRightRoute(
                            page: AddEditContactPage(contact: contact),
                          ));
                    },
                  ),
                  const SizedBox(width: 24), // Beri jarak sedikit lebih lebar
                  // Tombol Hapus (Icon)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: deleteColor,
                    iconSize: 32,
                    tooltip: 'Hapus Kontak',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
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
                                Navigator.of(ctx).pop();
                                context
                                    .read<ContactBloc>()
                                    .add(DeleteContact(contact.id));
                              },
                              child: const Text('Hapus',
                                  style: TextStyle(color: deleteColor)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
