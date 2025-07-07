import 'package:flutter/material.dart';
import '../model/contact.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;
  final VoidCallback onDeleted;
  final VoidCallback onEdit;

  const ContactDetailPage({
    super.key,
    required this.contact,
    required this.onDeleted,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Detail Kontak'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'hapus') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus kontak ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onDeleted();
                          Navigator.of(context).pop('deleted');
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'hapus',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Avatar besar di atas card
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 8),
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: contact.avatar.isNotEmpty
                      ? NetworkImage(contact.avatar)
                      : null,
                  child: contact.avatar.isEmpty
                      ? Text(
                          contact.nama.isNotEmpty
                              ? contact.nama[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 48,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
              Card(
                elevation: 10,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          contact.nama,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 22, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Text(
                            contact.noHp,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      if (contact.email.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.email,
                                size: 22, color: Colors.deepPurple),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                contact.email,
                                style: const TextStyle(fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Jika ada field tambahan seperti tanggal dibuat, bisa tampilkan di sini
                      // const SizedBox(height: 16),
                      // Row(
                      //   children: [
                      //     Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
                      //     SizedBox(width: 10),
                      //     Text('Dibuat: 2023-07-07', style: TextStyle(fontSize: 16)),
                      //   ],
                      // ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 32),
                            tooltip: 'Edit Kontak',
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 32),
                            tooltip: 'Hapus Kontak',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus kontak ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Batal'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        onDeleted();
                                        Navigator.of(context).pop('deleted');
                                      },
                                      child: const Text('Hapus'),
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
            ],
          ),
        ),
      ),
    );
  }
}

// Penggunaan ContactDetailPage yang baru
// builder: (context) => ContactDetailPage(
//   contact: contact,
//   onDeleted: () {
//     // aksi setelah kontak dihapus, misal refresh list
//   },
//   onEdit: () {
//     // aksi untuk edit kontak, misal buka halaman edit
//   },
// ),
