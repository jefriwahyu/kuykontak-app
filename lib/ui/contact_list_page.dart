import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/contact_detail_page.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as FC;
import 'package:kontak_app_m/helpers/slide_right_route.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  // Fungsi untuk memulai proses sinkronisasi kontak
  Future<void> _syncContacts() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Memulai sinkronisasi...'),
          backgroundColor: Colors.blue),
    );

    // 1. Minta Izin akses kontak
    if (await Permission.contacts.request().isGranted) {
      // 2. Baca kontak dari perangkat
      List<FC.Contact> deviceContacts = await FC.FlutterContacts.getContacts(
          withProperties: true // Ambil juga nomor telepon dan email
          );

      // 3. Ubah data ke format Map untuk dikirim ke API
      List<Map<String, dynamic>> contactsToSync = [];
      for (var contact in deviceContacts) {
        if (contact.phones.isNotEmpty && contact.displayName.isNotEmpty) {
          contactsToSync.add({
            'nama': contact.displayName,
            'no_hp': contact.phones.first.number
                .replaceAll(RegExp(r'[-\s]'), ''), // Bersihkan format nomor HP
            'email':
                contact.emails.isNotEmpty ? contact.emails.first.address : ''
          });
        }
      }

      // 4. Kirim data ke service untuk diproses oleh backend
      try {
        await ContactService.syncContacts(contactsToSync);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Sinkronisasi berhasil!'),
                backgroundColor: Colors.green),
          );
          // 5. Muat ulang daftar kontak di aplikasi untuk menampilkan data baru
          context.read<ContactBloc>().add(LoadContacts());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal melakukan sinkronisasi: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      }
    } else {
      // Jika pengguna menolak izin
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Izin akses kontak ditolak.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KuyKontak'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sinkronisasi Kontak',
            onPressed: _syncContacts, // Panggil fungsi sinkronisasi
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            TextField(
              onChanged: (value) {
                // TODO: Implement search logic
              },
              decoration: const InputDecoration(
                labelText: 'Pencarian',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  if (state is ContactLoading || state is ContactInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ContactLoaded) {
                    final contacts = state.contacts;
                    if (contacts.isEmpty) {
                      return const Center(child: Text('Tidak ada kontak.'));
                    }
                    SuspensionUtil.sortListBySuspensionTag(contacts);
                    SuspensionUtil.setShowSuspensionStatus(contacts);

                    return AzListView(
                      data: contacts,
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return Column(
                          children: [
                            Offstage(
                              offstage: !contact.isShowSuspension,
                              child: _buildSuspensionWidget(
                                  contact.getSuspensionTag()),
                            ),
                            _buildContactItem(contact),
                          ],
                        );
                      },
                      indexBarData: SuspensionUtil.getTagIndexList(contacts),
                      indexHintBuilder: (context, hint) {
                        return Container(
                          alignment: Alignment.center,
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                          child: Text(hint,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 30.0)),
                        );
                      },
                    );
                  }
                  if (state is ContactError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(
                      child: Text('Mulai dengan menambahkan kontak baru.'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Kode Baru
          Navigator.push(
              context,
              SlideRightRoute(
                page: const AddEditContactPage(),
              ));
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return GestureDetector(
      onTap: () {
        // Panggil ContactDetailPage dengan cara yang lebih sederhana
        Navigator.push(
            context,
            SlideRightRoute(
              page: ContactDetailPage(contact: contact),
            ));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.2),
            foregroundColor: primaryColor,
            backgroundImage:
                contact.avatar.isNotEmpty ? NetworkImage(contact.avatar) : null,
            child: contact.avatar.isEmpty
                ? Text(
                    contact.nama.isNotEmpty
                        ? contact.nama[0].toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(contact.nama,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(contact.noHp),
        ),
      ),
    );
  }

  Widget _buildSuspensionWidget(String tag) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: backgroundColor,
      child: Text(
        tag,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}
