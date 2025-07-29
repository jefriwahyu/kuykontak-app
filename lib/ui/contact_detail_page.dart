import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/avatar_helper.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/helpers/slide_right_route.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';
import 'package:flutter/services.dart';

// Halaman detail kontak dengan animasi scroll dan opsi edit/hapus
class ContactDetailPage extends StatefulWidget {
  final Contact contact; // Data kontak yang akan ditampilkan
  const ContactDetailPage({super.key, required this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late bool _isFavorite; // Status favorit kontak
  final ScrollController _scrollController =
      ScrollController(); // Controller untuk scroll effect

  // Variabel animasi untuk efek parallax
  double _avatarSize = 100.0;
  double _nameOpacity = 1.0;
  double _nameFontSize = 24.0;
  bool _showNameInAppBar = false;
  double _avatarTopPosition = 120.0;

  // Konstanta untuk perhitungan animasi scroll
  static const double _maxAvatarSize = 100.0;
  static const double _minAvatarSize = 40.0;
  static const double _maxNameSize = 24.0;
  static const double _minNameSize = 18.0;
  static const double _scrollThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.contact.isFavorite;
    _scrollController.addListener(_handleScroll); // Setup listener untuk scroll
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Handler untuk efek animasi saat scroll
  void _handleScroll() {
    final offset = _scrollController.offset;
    double progress = (offset / _scrollThreshold).clamp(0.0, 1.0);

    setState(() {
      // Interpolasi nilai untuk animasi smooth
      _avatarSize = lerpDouble(_maxAvatarSize, _minAvatarSize, progress)!;
      _nameFontSize = lerpDouble(_maxNameSize, _minNameSize, progress)!;
      _nameOpacity = lerpDouble(1.0, 0.0, progress)!;
      _avatarTopPosition = 120.0 - (offset * 0.4); // Efek parallax
      _showNameInAppBar = progress >= 0.9; // Toggle visibility nama di appbar
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate avatar dari helper
    final initials = AvatarHelper.getInitials(widget.contact.nama);
    final avatarColor = AvatarHelper.getAvatarColor(widget.contact.id);

    return Consumer<ThemeController>(
      builder: (context, theme, _) {
        final isDark = theme.isDarkTheme;
        final fontSize = theme.fontSize;

        return BlocListener<ContactBloc, ContactState>(
          listener: (context, state) {
            // Handle state changes dari BLoC
            if (state is ContactActionSuccess) {
              Navigator.of(context).pop();
            }
            if (state is ContactDeleteSuccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('${state.contactName} berhasil dihapus'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: Duration(seconds: 2),
              ));
            }
            if (state is ContactError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Gagal: ${state.message}'),
                backgroundColor: Colors.red,
              ));
            }
          },
          child: Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // AppBar dengan efek collapse
                SliverAppBar(
                  expandedHeight: 280.0,
                  pinned: true,
                  stretch: true,
                  elevation: 2.0,
                  backgroundColor: isDark
                      ? const Color(0xFF1C2B5D)
                      : const Color(0xFF1E88E5),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: AnimatedOpacity(
                    opacity: _showNameInAppBar ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      widget.contact.nama,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF1E3A8A),
                                      const Color(0xFF1C2B5D)
                                    ]
                                  : [
                                      const Color(0xFF1E88E5),
                                      const Color(0xFF42A5F5)
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Avatar dan nama dengan animasi
                        Positioned(
                          top: _avatarTopPosition,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Hero(
                                tag: 'avatar_${widget.contact.id}',
                                child: CircleAvatar(
                                  radius: _avatarSize / 2,
                                  backgroundImage:
                                      widget.contact.avatar.isNotEmpty
                                          ? NetworkImage(widget.contact.avatar)
                                          : null,
                                  backgroundColor: widget.contact.avatar.isEmpty
                                      ? avatarColor.withOpacity(0.9)
                                      : Colors.transparent,
                                  child: widget.contact.avatar.isEmpty
                                      ? Text(
                                          initials,
                                          style: TextStyle(
                                              fontSize: _avatarSize *
                                                  (initials.length > 1
                                                      ? 0.4
                                                      : 0.45),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                opacity: _nameOpacity,
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  widget.contact.nama,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _nameFontSize,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      const Shadow(
                                          blurRadius: 2, color: Colors.black26)
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Tombol favorit
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.star : Icons.star_border,
                        color:
                            _isFavorite ? Colors.amber.shade300 : Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        context.read<ContactBloc>().add(
                            ToggleFavorite(widget.contact.id, _isFavorite));
                      },
                    ),
                  ],
                ),
                // Konten detail kontak
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Column(
                      children: [
                        // Badge grup kontak
                        if (widget.contact.grup.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: isDark
                                  ? Border.all(color: Colors.grey.shade800)
                                  : null,
                            ),
                            child: Text(
                              widget.contact.grup,
                              style: TextStyle(
                                color: isDark
                                    ? Color(0xFF64B5F6)
                                    : Color(0xFF1E88E5),
                                fontSize: fontSize * 0.9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        // Card detail kontak
                        Card(
                          elevation: isDark ? 4 : 2,
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildDetailItem(Icons.phone, 'Nomor HP',
                                    widget.contact.noHp, theme, true),
                                _buildDetailItem(Icons.email_outlined, 'Email',
                                    widget.contact.email, theme, true),
                                _buildDetailItem(
                                    Icons.location_on_outlined,
                                    'Alamat',
                                    widget.contact.alamat,
                                    theme,
                                    true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Tombol aksi
                        Row(
                          children: [
                            // Tombol edit
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: Text('Edit',
                                    style: TextStyle(fontSize: fontSize)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? const Color(0xFF64B5F6)
                                      : const Color(0xFF1E88E5),
                                  side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF64B5F6)
                                          : const Color(0xFF1E88E5)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: AddEditContactPage(
                                              contact: widget.contact)));
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Tombol hapus
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.delete),
                                label: Text('Hapus',
                                    style: TextStyle(fontSize: fontSize)),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red.shade600,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  _showDeleteConfirmation(context, theme);
                                },
                              ),
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
        );
      },
    );
  }

  // Widget builder untuk item detail kontak
  Widget _buildDetailItem(IconData icon, String label, String value,
      ThemeController theme, bool isClickable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // Efek visual berdasarkan tema
          hoverColor: theme.isDarkTheme
              ? const Color(0xFF64B5F6).withOpacity(0.08)
              : const Color(0xFF1E88E5).withOpacity(0.04),
          splashColor: theme.isDarkTheme
              ? const Color(0xFF64B5F6).withOpacity(0.12)
              : const Color(0xFF1E88E5).withOpacity(0.08),
          highlightColor: theme.isDarkTheme
              ? const Color(0xFF64B5F6).withOpacity(0.06)
              : const Color(0xFF1E88E5).withOpacity(0.03),
          // Fungsi copy ke clipboard
          onTap: (isClickable && value.isNotEmpty)
              ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label berhasil disalin'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.isDarkTheme
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.isDarkTheme
                        ? const Color(0xFF64B5F6).withOpacity(0.12)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.isDarkTheme
                            ? const Color(0xFF64B5F6).withOpacity(0.1)
                            : const Color(0xFF1E88E5).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: theme.isDarkTheme
                        ? const Color(0xFF64B5F6)
                        : const Color(0xFF1E88E5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Konten teks
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: theme.isDarkTheme
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: theme.fontSize * 0.85,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value.isNotEmpty ? value : '-',
                        style: TextStyle(
                          fontSize: theme.fontSize * 1.0,
                          fontWeight: FontWeight.w600,
                          color: theme.isDarkTheme
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon copy jika bisa diklik
                if (isClickable && value.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: theme.isDarkTheme
                          ? Colors.grey.shade500
                          : Colors.grey.shade400,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog konfirmasi hapus kontak
  void _showDeleteConfirmation(BuildContext context, ThemeController theme) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (ctx, anim1, anim2) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
            child: AlertDialog(
              backgroundColor:
                  theme.isDarkTheme ? const Color(0xFF2D2D2D) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: theme.isDarkTheme
                        ? Colors.red.shade800
                        : Colors.red.shade300,
                    width: 1.5),
              ),
              elevation: 8,
              shadowColor: Colors.red.withOpacity(0.3),
              title: Column(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hapus Kontak?',
                    style: TextStyle(
                      fontSize: theme.fontSize * 1.2,
                      fontWeight: FontWeight.bold,
                      color: theme.isDarkTheme ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Anda akan menghapus kontak ',
                      style: TextStyle(
                        fontSize: theme.fontSize,
                        color: theme.isDarkTheme
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    TextSpan(
                      text: widget.contact.nama,
                      style: TextStyle(
                        fontSize: theme.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: ' secara permanen.',
                      style: TextStyle(
                        fontSize: theme.fontSize,
                        color: theme.isDarkTheme
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                // Tombol batal
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.isDarkTheme
                        ? Colors.white70
                        : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: theme.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Tombol konfirmasi hapus
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context
                        .read<ContactBloc>()
                        .add(DeleteContact(widget.contact.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.red.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        'Ya, Hapus',
                        style: TextStyle(
                          fontSize: theme.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        transitionBuilder: (ctx, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: child,
          );
        });
  }
}
