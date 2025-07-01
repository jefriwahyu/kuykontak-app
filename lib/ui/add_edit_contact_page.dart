import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact;

  const AddEditContactPage({super.key, this.contact});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSaving = false;

  bool get isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _noHpController = TextEditingController();
    _emailController = TextEditingController();

    if (isEditMode) {
      _namaController.text = widget.contact!.nama;
      _noHpController.text = widget.contact!.noHp;
      _emailController.text = widget.contact!.email;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = pickedFile.name;
      });
    }
  }

  void _onSave() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      setState(() {
        _isSaving = true;
      });

      String? avatarUrl;

      if (_imageBytes != null && _imageName != null) {
        avatarUrl =
            await ContactService.uploadAvatar(_imageBytes!, _imageName!);
        if (avatarUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Gagal mengupload gambar.'),
                  backgroundColor: Colors.red),
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }
      } else if (isEditMode) {
        avatarUrl = widget.contact!.avatar;
      }

      final contactData = {
        'nama': _namaController.text,
        'no_hp': _noHpController.text,
        'email': _emailController.text,
        'avatar': avatarUrl ?? '',
      };

      if (mounted) {
        context.read<ContactBloc>().add(isEditMode
            ? UpdateContact(widget.contact!.id, contactData)
            : AddContact(contactData));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Kontak berhasil diperbarui!'
                : 'Kontak baru berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );

        int popCount = isEditMode ? 2 : 1;
        for (int i = 0; i < popCount; i++) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Kontak' : 'Tambah Kontak'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageBytes != null
                      ? MemoryImage(_imageBytes!)
                      : (isEditMode && widget.contact!.avatar.isNotEmpty
                          ? NetworkImage(widget.contact!.avatar)
                          : null) as ImageProvider?,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : (_imageBytes == null &&
                              !(isEditMode && widget.contact!.avatar.isNotEmpty)
                          ? const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.white60)
                          : null),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: 'Nama'),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noHpController,
                        decoration: const InputDecoration(labelText: 'No. Hp'),
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'No. Hp tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            (value == null || !value.contains('@'))
                                ? 'Email tidak valid'
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  child: _isSaving
                      ? const Text('Menyimpan...')
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
