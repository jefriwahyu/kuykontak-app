import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/contact_detail_page.dart';
import 'package:kontak_app_m/ui/theme.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KuyKontak'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          children: [
            // Kolom Pencarian
            TextField(
              onChanged: (value) {
                // TODO: Implement search logic using BLoC event
              },
              decoration: const InputDecoration(
                labelText: 'Pencarian',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            // Gunakan BlocBuilder untuk membangun UI berdasarkan state BLoC
            Expanded(
              child: BlocBuilder<ContactBloc, ContactState>(
                builder: (context, state) {
                  // Saat data sedang dimuat, tampilkan loading spinner
                  if (state is ContactLoading || state is ContactInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Jika data berhasil dimuat
                  if (state is ContactLoaded) {
                    final contacts = state.contacts;
                    if (contacts.isEmpty) {
                      return const Center(child: Text('Tidak ada kontak.'));
                    }
                    // Proses data untuk AzListView
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
                  // Jika terjadi error
                  if (state is ContactError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  // State default
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
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditContactPage(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailPage(contact: contact),
            ));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.2),
            foregroundColor: primaryColor,
            // --- PERUBAHAN DI SINI ---
            // Jika URL avatar ada, tampilkan gambar dari internet.
            // Jika tidak, tampilkan inisial nama.
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
