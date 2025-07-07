import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';
import 'package:kontak_app_m/helpers/slide_right_route.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/contact_detail_page.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as FC;

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  // Variabel untuk menyimpan semua kontak asli dari BLoC
  List<Contact> _allContacts = [];
  // Variabel untuk menampilkan kontak yang sudah difilter
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal, bisa juga langsung diisi dari state BLoC jika sudah ada
    final currentState = context.read<ContactBloc>().state;
    if (currentState is ContactLoaded) {
      _allContacts = currentState.contacts;
      _filteredContacts = _allContacts;
    }
  }

  // Fungsi untuk logika pencarian
  void _runFilter(String enteredKeyword) {
    List<Contact> results = [];
    if (enteredKeyword.isEmpty) {
      // Jika kolom pencarian kosong, tampilkan semua kontak
      results = _allContacts;
    } else {
      // Jika ada teks, filter berdasarkan nama
      results = _allContacts
          .where((contact) =>
              contact.nama.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    // Update UI dengan daftar yang sudah difilter
    setState(() {
      _filteredContacts = results;
    });
  }

  // Fungsi untuk sinkronisasi kontak
  Future<void> _syncContacts() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Memulai sinkronisasi...'),
          backgroundColor: Colors.blue),
    );
    if (await Permission.contacts.request().isGranted) {
      List<FC.Contact> deviceContacts =
          await FC.FlutterContacts.getContacts(withProperties: true);
      List<Map<String, dynamic>> contactsToSync = [];
      for (var contact in deviceContacts) {
        if (contact.phones.isNotEmpty && contact.displayName.isNotEmpty) {
          contactsToSync.add({
            'nama': contact.displayName,
            'no_hp':
                contact.phones.first.number.replaceAll(RegExp(r'[-\s]'), ''),
            'email':
                contact.emails.isNotEmpty ? contact.emails.first.address : ''
          });
        }
      }
      try {
        await ContactService.syncContacts(contactsToSync);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Sinkronisasi berhasil!'),
                backgroundColor: Colors.green),
          );
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
    // Gunakan BlocListener untuk update data tanpa mengganggu UI builder
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactLoaded) {
          setState(() {
            _allContacts = state.contacts;
            _filteredContacts = _allContacts;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KuyKontak'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sinkronisasi Kontak',
              onPressed: _syncContacts,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              TextField(
                onChanged: (value) => _runFilter(value),
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
                      if (_allContacts.isEmpty) {
                        return const Center(child: Text('Tidak ada kontak.'));
                      }
                      if (_filteredContacts.isEmpty) {
                        return const Center(
                            child: Text('Kontak tidak ditemukan.'));
                      }
                      SuspensionUtil.sortListBySuspensionTag(_filteredContacts);
                      SuspensionUtil.setShowSuspensionStatus(_filteredContacts);

                      return AzListView(
                        data: _filteredContacts,
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
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
                        indexBarData:
                            SuspensionUtil.getTagIndexList(_filteredContacts),
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
            Navigator.push(
                context, SlideRightRoute(page: const AddEditContactPage()));
          },
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            SlideRightRoute(page: ContactDetailPage(contact: contact)));
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
