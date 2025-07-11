import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';
import 'package:kontak_app_m/ui/theme.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact;
  const AddEditContactPage({super.key, this.contact});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  String? _selectedGrup;
  final List<String> _grupOptions = ['Keluarga', 'Teman', 'Kerja', ''];

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSaving = false;
  bool _isAvatarRemoved = false;

  bool get isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _noHpController = TextEditingController();
    _emailController = TextEditingController();
    _alamatController = TextEditingController();

    if (isEditMode) {
      _namaController.text = widget.contact!.nama;
      _noHpController.text = widget.contact!.noHp;
      _emailController.text = widget.contact!.email;
      _alamatController.text = widget.contact!.alamat;
      _selectedGrup =
          widget.contact!.grup.isNotEmpty ? widget.contact!.grup : null;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
          _isAvatarRemoved = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memilih gambar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      String? avatarUrl;
      if (_isAvatarRemoved) {
        avatarUrl = '';
      } else if (_imageBytes != null) {
        avatarUrl =
            await ContactService.uploadAvatar(_imageBytes!, _imageName!);
        if (avatarUrl == null) throw Exception('Gagal upload avatar');
      } else if (isEditMode) {
        avatarUrl = widget.contact!.avatar;
      }

      final contactData = {
        'nama': _namaController.text.trim(),
        'no_hp': _noHpController.text.trim(),
        'email': _emailController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'grup': _selectedGrup ?? '',
        'avatar': avatarUrl ?? '',
      };

      if (mounted) {
        context.read<ContactBloc>().add(
              isEditMode
                  ? UpdateContact(widget.contact!.id, contactData)
                  : AddContact(contactData),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Kontak berhasil diperbarui!'
                : 'Kontak baru berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        if (isEditMode) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasExistingImage =
        isEditMode && widget.contact!.avatar.isNotEmpty && !_isAvatarRemoved;
    final bool hasNewImage = _imageBytes != null;
    final bool showImage = hasExistingImage || hasNewImage;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Kontak' : 'Tambah Kontak'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(0.2),
                          secondaryColor.withOpacity(0.2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child: showImage
                          ? Image(
                              image: hasNewImage
                                  ? MemoryImage(_imageBytes!)
                                  : NetworkImage(widget.contact!.avatar)
                                      as ImageProvider,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : const CircularProgressIndicator();
                              },
                              errorBuilder: (_, __, ___) =>
                                  _buildDefaultAvatar(),
                            )
                          : _buildDefaultAvatar(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      backgroundColor: primaryColor,
                      onPressed: _pickImage,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                  if (showImage && !_isSaving)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imageBytes = null;
                            _imageName = null;
                            _isAvatarRemoved = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInputCard(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEditMode ? 'UPDATE KONTAK' : 'SIMPAN KONTAK',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: 50,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _namaController,
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wajib diisi';
                }
                if (value.length < 3) {
                  return 'Nama harus minimal 3 karakter';
                }
                if (value.length > 50) {
                  return 'Nama terlalu panjang (maks 50 karakter)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _noHpController,
              label: 'Nomor HP',
              hint: 'Masukkan nomor handphone',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor HP wajib diisi';
                }
                final phoneRegex = RegExp(r'^[0-9]{10,13}$');
                if (!phoneRegex.hasMatch(value)) {
                  return 'Nomor HP harus 10-13 digit angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email',
              hint: 'Masukkan alamat email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    caseSensitive: false,
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  if (value.length > 100) {
                    return 'Email terlalu panjang (maks 100 karakter)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _alamatController,
              label: 'Alamat',
              hint: 'Masukkan alamat lengkap',
              maxLines: 2,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (value.length < 10) {
                    return 'Alamat terlalu pendek (min 10 karakter)';
                  }
                  if (value.length > 200) {
                    return 'Alamat terlalu panjang (maks 200 karakter)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGrup,
              decoration: InputDecoration(
                labelText: 'Grup',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _grupOptions
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.isEmpty ? 'Tidak ada grup' : e),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedGrup = value),
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}
