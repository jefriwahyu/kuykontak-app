import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';
import 'package:kontak_app_m/helpers/avatar_helper.dart';

class AddEditContactPage extends StatefulWidget {
  final Contact? contact;
  const AddEditContactPage({super.key, this.contact});

  @override
  State<AddEditContactPage> createState() => _AddEditContactPageState();
}

class _AddEditContactPageState extends State<AddEditContactPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _emailController;
  late TextEditingController _alamatController;
  String? _selectedGrup;
  final List<String> _grupOptions = ['Keluarga', 'Teman', 'Kerja', 'Lainnya'];

  Uint8List? _imageBytes;
  String? _imageName;
  bool _isSaving = false;
  bool _isAvatarRemoved = false;

  bool get isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Gagal memilih gambar'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
        'isFavorite':
            (isEditMode ? widget.contact!.isFavorite : false).toString(),
      };

      if (mounted) {
        context.read<ContactBloc>().add(
              isEditMode
                  ? UpdateContact(widget.contact!.id, contactData)
                  : AddContact(contactData),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(isEditMode
                    ? 'Kontak berhasil diperbarui!'
                    : 'Kontak baru berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.pop(context);
        if (isEditMode) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDarkTheme;
    final fontSize = themeController.fontSize;

    final bool hasExistingImage =
        isEditMode && widget.contact!.avatar.isNotEmpty && !_isAvatarRemoved;
    final bool hasNewImage = _imageBytes != null;
    final bool showImage = hasExistingImage || hasNewImage;

    final initials = isEditMode
        ? AvatarHelper.getInitials(widget.contact!.nama)
        : AvatarHelper.getInitials(_namaController.text);
    final avatarColor = isEditMode
        ? AvatarHelper.getAvatarColor(widget.contact!.id)
        : AvatarHelper.getAvatarColor(
            DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: BlocListener<ContactBloc, ContactState>(
        listener: (context, state) {
          if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Gagal: ${state.message}'),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60.0,
              pinned: true,
              stretch: true,
              elevation: 0,
              backgroundColor:
                  isDark ? const Color(0xFF1C2B5D) : const Color(0xFF1E88E5),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                isEditMode ? 'Edit Kontak' : 'Tambah Kontak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize * 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E3A8A), const Color(0xFF1C2B5D)]
                        : [const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Avatar Section without "Foto Profil" text
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      (isDark
                                              ? const Color(0xFF64B5F6)
                                              : const Color(0xFF1E88E5))
                                          .withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: showImage
                                      ? Image(
                                          image: _imageBytes != null
                                              ? MemoryImage(_imageBytes!)
                                              : NetworkImage(
                                                      widget.contact!.avatar)
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (context, child, progress) {
                                            return progress == null
                                                ? child
                                                : Container(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF2A2A2A)
                                                        : const Color(
                                                            0xFFF5F5F5),
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: progress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? progress
                                                                    .cumulativeBytesLoaded /
                                                                progress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF64B5F6)
                                                            : const Color(
                                                                0xFF1E88E5),
                                                      ),
                                                    ),
                                                  );
                                          },
                                          errorBuilder: (_, __, ___) =>
                                              _buildDefaultAvatar(
                                                  initials, avatarColor),
                                        )
                                      : _buildDefaultAvatar(
                                          initials, avatarColor),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Material(
                                  elevation: 8,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF64B5F6)
                                            : const Color(0xFF1E88E5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (showImage && !_isSaving)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Material(
                                    elevation: 8,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () {
                                        setState(() {
                                          _imageBytes = null;
                                          _imageName = null;
                                          _isAvatarRemoved = true;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk ikon kamera untuk mengubah foto',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Form Section with compact spacing
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.3 : 0.1),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF64B5F6)
                                                .withOpacity(0.15)
                                            : const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.person_outline,
                                        color: isDark
                                            ? const Color(0xFF64B5F6)
                                            : const Color(0xFF1E88E5),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Informasi Kontak',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: fontSize * 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                                  thickness: 1,
                                ),
                                const SizedBox(height: 12),

                                // Name Field
                                _buildEnhancedTextField(
                                  controller: _namaController,
                                  label: 'Nama Lengkap',
                                  hint: 'Masukkan nama lengkap',
                                  icon: Icons.person_outline,
                                  isDark: isDark,
                                  fontSize: fontSize,
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
                                const SizedBox(height: 12),

                                // Phone Field
                                _buildEnhancedTextField(
                                  controller: _noHpController,
                                  label: 'Nomor HP',
                                  hint: 'Masukkan nomor handphone',
                                  icon: Icons.phone_android_outlined,
                                  keyboardType: TextInputType.phone,
                                  isDark: isDark,
                                  fontSize: fontSize,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nomor HP wajib diisi';
                                    }
                                    final phoneRegex =
                                        RegExp(r'^[0-9]{10,13}$');
                                    if (!phoneRegex.hasMatch(value)) {
                                      return 'Nomor HP harus 10-13 digit angka';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Email Field
                                _buildEnhancedTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'Masukkan alamat email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  isDark: isDark,
                                  fontSize: fontSize,
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
                                const SizedBox(height: 12),

                                // Address Field
                                _buildEnhancedTextField(
                                  controller: _alamatController,
                                  label: 'Alamat',
                                  hint: 'Masukkan alamat lengkap',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 3,
                                  isDark: isDark,
                                  fontSize: fontSize,
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
                                const SizedBox(height: 12),

                                // Group Dropdown
                                _buildEnhancedGroupDropdown(isDark, fontSize),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Save Button with icon
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFF1E88E5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: (isDark
                                        ? const Color(0xFF64B5F6)
                                        : const Color(0xFF1E88E5))
                                    .withOpacity(0.3),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isEditMode
                                              ? Icons.save
                                              : Icons.save_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isEditMode
                                              ? 'Perbarui Kontak'
                                              : 'Simpan Kontak',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: fontSize * 1.1,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String initials, Color avatarColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            avatarColor.withOpacity(0.9),
            avatarColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedGroupDropdown(bool isDark, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grup',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGrup,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: InputBorder.none,
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
              prefixIcon: Icon(
                Icons.group_outlined,
                color:
                    isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
              ),
            ),
            items: _grupOptions
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedGrup = value),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: fontSize,
            ),
            dropdownColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
            ),
            elevation: 8,
            hint: Text(
              'Pilih Grup',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required double fontSize,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: fontSize * 0.9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: fontSize * 0.9,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF64B5F6).withOpacity(0.15)
                    : const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color:
                    isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF64B5F6) : const Color(0xFF1E88E5),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }
}
