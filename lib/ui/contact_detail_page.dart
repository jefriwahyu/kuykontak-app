import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:kontak_app_m/helpers/slide_right_route.dart';

class ContactDetailPage extends StatefulWidget {
  final Contact contact;
  const ContactDetailPage({super.key, required this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late bool _isFavorite;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.contact.isFavorite;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFavoriteCount();
    });
  }

  void _updateFavoriteCount() {
    final bloc = context.read<ContactBloc>();
    final state = bloc.state;
    if (state is ContactLoaded) {
      setState(() {
        _favoriteCount = state.contacts.where((c) => c.isFavorite).length;
      });
    }
  }

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
                      image: widget.contact.avatar.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.contact.avatar),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: widget.contact.avatar.isEmpty
                        ? Center(
                            child: Text(
                              widget.contact.nama.isNotEmpty
                                  ? widget.contact.nama[0].toUpperCase()
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
                        _buildDetailItem('Nama', widget.contact.nama),
                        const SizedBox(height: 20),
                        _buildDetailItem('No. Hp', widget.contact.noHp),
                        const SizedBox(height: 20),
                        _buildDetailItem(
                            'Email',
                            widget.contact.email.isNotEmpty
                                ? widget.contact.email
                                : '-'),
                        if (widget.contact.alamat.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailItem('Alamat', widget.contact.alamat),
                        ],
                        if (widget.contact.grup.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildDetailItem('Grup', widget.contact.grup),
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
                      icon: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color: _isFavorite ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      tooltip: _isFavorite
                          ? 'Hapus dari Favorit'
                          : 'Jadikan Favorit',
                      onPressed: (_favoriteCount >= 5 && !_isFavorite)
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Maaf, jumlah kontak favorite sudah mencapai batas maksimal (5 kontak).'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          : () {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                              context.read<ContactBloc>().add(
                                ToggleFavorite(widget.contact.id, _isFavorite),
                              );
                              // Tidak perlu pop/LoadContacts di sini, biarkan BlocListener yang pop
                            },
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: primaryColor,
                      iconSize: 32,
                      tooltip: 'Ubah Kontak',
                      onPressed: () {
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: AddEditContactPage(
                                    contact: widget.contact)));
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
                              'Apakah Anda yakin ingin menghapus kontak "${widget.contact.nama}"?',
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
                                      .add(DeleteContact(widget.contact.id));
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
