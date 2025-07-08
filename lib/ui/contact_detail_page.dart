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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
        // --- PERBAIKAN DI SINI ---
        body: SingleChildScrollView(
          child: Padding(
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
                              fit: BoxFit.cover)
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
                        _buildDetailItem('Email',
                            contact.email.isNotEmpty ? contact.email : '-'),
                        if (contact.alamat.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailItem('Alamat', contact.alamat),
                        ],
                        if (contact.grup.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailItem('Grup', contact.grup),
                        ]
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: primaryColor,
                      iconSize: 32,
                      tooltip: 'Ubah Kontak',
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: AddEditContactPage(contact: contact)));
                      },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: deleteColor,
                      iconSize: 32,
                      tooltip: 'Hapus Kontak',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            icon: Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 48,
                            ),
                            title: const Text('Konfirmasi Hapus'),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus kontak "${contact.nama}"?',
                              textAlign: TextAlign.center,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: <Widget>[
                              OutlinedButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(
                                    const BorderSide(color: deleteColor),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                            .contains(MaterialState.pressed) ||
                                        states
                                            .contains(MaterialState.hovered)) {
                                      return Colors.white;
                                    }
                                    return deleteColor;
                                  }),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                            .contains(MaterialState.pressed) ||
                                        states
                                            .contains(MaterialState.hovered)) {
                                      return deleteColor;
                                    }
                                    return Colors.transparent;
                                  }),
                                ),
                                child: const Text('Batal'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  context
                                      .read<ContactBloc>()
                                      .add(DeleteContact(contact.id));
                                },
                                style: ButtonStyle(
                                  side: MaterialStateProperty.all(
                                    BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                            .contains(MaterialState.pressed) ||
                                        states
                                            .contains(MaterialState.hovered)) {
                                      return Colors.white;
                                    }
                                    return Theme.of(context).primaryColor;
                                  }),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (states
                                            .contains(MaterialState.pressed) ||
                                        states
                                            .contains(MaterialState.hovered)) {
                                      return Theme.of(context).primaryColor;
                                    }
                                    return Colors.transparent;
                                  }),
                                ),
                                child: const Text('Ya, Hapus'),
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
      ),
    );
  }
}
