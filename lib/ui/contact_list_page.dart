import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
import 'package:kontak_app_m/helpers/avatar_helper.dart';
import 'package:kontak_app_m/helpers/contact_service.dart';
import 'package:kontak_app_m/helpers/slide_right_route.dart';
import 'package:kontak_app_m/model/contact.dart';
import 'package:kontak_app_m/ui/add_edit_contact_page.dart';
import 'package:kontak_app_m/ui/contact_detail_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as FC;
import 'package:kontak_app_m/ui/app_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

/// Halaman utama aplikasi untuk menampilkan dan mengelola daftar kontak.
class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with TickerProviderStateMixin {
  // --- State Lokal untuk data dan UI ---
  List<Contact> _allContacts = []; // Master list dari BLoC.
  List<Contact> _filteredContacts =
      []; // List yang ditampilkan setelah difilter.
  AnimationController? _listAnimationController; // Animasi daftar kontak.
  late AnimationController
      _syncAnimationController; // Animasi ikon sinkronisasi.

  final List<String> _kategori = ['Semua', 'Keluarga', 'Teman', 'Kerja'];
  String _selectedKategori = 'Semua';
  String _searchKeyword = '';
  bool _showingFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSyncing = false; // Mencegah sinkronisasi ganda.

  // --- Palet warna aplikasi ---
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);

  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _syncAnimationController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    // Memuat kontak saat halaman pertama kali dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<ContactBloc>().state;
      if (currentState is! ContactLoaded) {
        context.read<ContactBloc>().add(LoadContacts());
      } else {
        // Gunakan data yang sudah ada di BLoC jika tersedia.
        setState(() {
          _allContacts = currentState.contacts;
          _runFilter();
        });
      }
    });
  }

  @override
  void dispose() {
    // Membersihkan semua controller untuk mencegah memory leak.
    _listAnimationController?.dispose();
    _syncAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Menjalankan logika filter pada daftar kontak.
  void _runFilter() {
    List<Contact> results;
    if (_showingFavoritesOnly) {
      results = _allContacts.where((c) => c.isFavorite).toList();
    } else {
      results = _selectedKategori == 'Semua'
          ? _allContacts
          : _allContacts.where((c) => c.grup == _selectedKategori).toList();
      if (_searchKeyword.isNotEmpty) {
        results = results
            .where((c) =>
                c.nama.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
                c.noHp.contains(_searchKeyword))
            .toList();
      }
    }
    // Menyiapkan data untuk ditampilkan di AzListView (diurutkan dan diberi tag).
    SuspensionUtil.sortListBySuspensionTag(results);
    SuspensionUtil.setShowSuspensionStatus(results);
    setState(() => _filteredContacts = results);
    _listAnimationController?.forward(from: 0.0);
  }

  /// Memulai proses sinkronisasi kontak dari perangkat ke server.
  Future<void> _syncContacts() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    // Menampilkan dialog loading saat proses berjalan.
    _showSyncLoadingDialog();
    _syncAnimationController.repeat();

    try {
      // Meminta izin, mengambil kontak, mengirim ke server, lalu refresh UI.
      if (await Permission.contacts.request().isGranted) {
        List<FC.Contact> deviceContacts =
            await FC.FlutterContacts.getContacts(withProperties: true);
        List<Map<String, dynamic>> contactsToSync = [];
        for (var contact in deviceContacts) {
          if (contact.phones.isNotEmpty && contact.displayName.isNotEmpty) {
            contactsToSync.add({
              'nama': contact.displayName,
              'no_hp':
                  contact.phones.first.number.replaceAll(RegExp(r'[\s-]'), ''),
              'email':
                  contact.emails.isNotEmpty ? contact.emails.first.address : '',
            });
          }
        }
        final message = await ContactService.syncContacts(contactsToSync);

        // Memberi feedback ke pengguna setelah selesai.
        if (mounted) {
          Navigator.of(context).pop(); // Tutup dialog.
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message), backgroundColor: Colors.green.shade600));
          context.read<ContactBloc>().add(LoadContacts());
        }
      } else {
        // Menangani jika izin ditolak.
        if (mounted) {
          Navigator.of(context).pop(); // Tutup dialog.
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Izin akses kontak ditolak.'),
              backgroundColor: Colors.orange));
        }
      }
    } catch (e) {
      // Menangani jika terjadi error.
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal sinkronisasi: ${e.toString()}'),
            backgroundColor: Colors.red));
      }
    } finally {
      // Blok ini selalu dijalankan untuk mereset state sinkronisasi.
      if (mounted) {
        _syncAnimationController.stop(canceled: false);
        _syncAnimationController.reset();
        setState(() => _isSyncing = false);
      }
    }
  }

  /// Menampilkan dialog pengaturan tema dan ukuran font.
  void _showSettingsDialog() {
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeController>(
          builder: (context, theme, _) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor:
                  theme.isDarkTheme ? Color(0xFF1E1E1E) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings,
                              color:
                                  theme.isDarkTheme ? accentBlue : primaryBlue,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Pengaturan',
                              style: TextStyle(
                                  fontSize: theme.fontSize * 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: theme.isDarkTheme
                                      ? darkTextPrimary
                                      : Colors.black87),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Material(
                            color: theme.isDarkTheme
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade200,
                            shape: const CircleBorder(),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () => Navigator.of(context).pop(),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: theme.isDarkTheme
                                      ? accentBlue
                                      : primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: Icon(
                        theme.isDarkTheme
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        color: theme.isDarkTheme
                            ? Colors.yellow.shade700
                            : Colors.orange.shade700,
                      ),
                      title: Text(
                        theme.isDarkTheme ? 'Tema Gelap' : 'Tema Terang',
                        style: TextStyle(
                            fontSize: theme.fontSize,
                            color: theme.isDarkTheme
                                ? darkTextPrimary
                                : Colors.black87),
                      ),
                      trailing: SwitchTheme(
                        data: SwitchThemeData(
                          trackOutlineColor:
                              MaterialStateProperty.resolveWith((states) {
                            final activeColor = theme.isDarkTheme
                                ? accentBlue.withOpacity(0.5)
                                : primaryBlue.withOpacity(0.5);
                            final inactiveColor = Colors.grey.shade200;

                            if (states.contains(MaterialState.selected)) {
                              return activeColor;
                            }
                            return inactiveColor;
                          }),
                        ),
                        child: Switch(
                          value: theme.isDarkTheme,
                          onChanged: (val) => themeController.toggleTheme(val),
                          activeColor:
                              theme.isDarkTheme ? accentBlue : primaryBlue,
                          activeTrackColor: theme.isDarkTheme
                              ? accentBlue.withOpacity(0.5)
                              : primaryBlue.withOpacity(0.5),
                          inactiveThumbColor: Colors.grey.shade400,
                          inactiveTrackColor: Colors.grey.shade200,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_size,
                                    color: theme.isDarkTheme
                                        ? darkTextSecondary
                                        : Colors.grey.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ukuran Font',
                                    style: TextStyle(
                                        fontSize: theme.fontSize * 0.9,
                                        color: theme.isDarkTheme
                                            ? darkTextSecondary
                                            : Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              Text(theme.fontSize.toStringAsFixed(0),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: theme.fontSize * 0.9,
                                      color: theme.isDarkTheme
                                          ? darkTextPrimary
                                          : Colors.black87)),
                            ],
                          ),
                          Slider(
                            min: 12,
                            max: 22,
                            divisions: 10,
                            value: theme.fontSize,
                            label: theme.fontSize.toStringAsFixed(0),
                            activeColor:
                                theme.isDarkTheme ? accentBlue : primaryBlue,
                            onChanged: (val) =>
                                themeController.setFontSize(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Menampilkan dialog loading saat proses sinkronisasi.
  void _showSyncLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Dialog tidak bisa ditutup dengan tap di luar.
      builder: (context) {
        return Consumer<ThemeController>(
          builder: (context, theme, _) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.isDarkTheme ? darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ikon sync yang berputar.
                    RotationTransition(
                      turns: _syncAnimationController,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.isDarkTheme
                              ? accentBlue.withOpacity(0.2)
                              : primaryBlue.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.sync,
                          size: 40,
                          color: theme.isDarkTheme ? accentBlue : primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Menyinkronkan Kontak',
                      style: TextStyle(
                        fontSize: theme.fontSize * 1.1,
                        fontWeight: FontWeight.w600,
                        color: theme.isDarkTheme
                            ? darkTextPrimary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mohon tunggu sebentar...',
                      style: TextStyle(
                        fontSize: theme.fontSize * 0.9,
                        color: theme.isDarkTheme
                            ? darkTextSecondary
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Indikator progress linear.
                    LinearProgressIndicator(
                      backgroundColor: theme.isDarkTheme
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.isDarkTheme ? accentBlue : primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Consumer untuk mendapatkan state tema saat ini.
    return Consumer<ThemeController>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.isDarkTheme ? darkBg : const Color(0xFFF0F2F5),
          body: Column(
            children: [
              _buildModernAppBar(theme),
              _buildSearchBar(theme),

              // Menampilkan header favorit atau chip kategori.
              if (_showingFavoritesOnly)
                _buildFavoriteHeader(theme)
              else
                _buildCategoryChips(theme),

              const SizedBox(height: 8),
              Expanded(
                // BlocListener untuk Aksi (contoh: update state lokal).
                child: BlocListener<ContactBloc, ContactState>(
                  listener: (context, state) {
                    if (state is ContactLoaded) {
                      setState(() {
                        _allContacts = state.contacts;
                        _runFilter(); // Jalankan filter setelah data baru diterima.
                      });
                    }
                  },
                  // BlocBuilder untuk membangun UI berdasarkan state.
                  child: BlocBuilder<ContactBloc, ContactState>(
                    builder: (context, state) {
                      // Tampilkan loading indicator.
                      if (state is ContactLoading || state is ContactInitial) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.isDarkTheme ? accentBlue : primaryBlue,
                            ),
                            strokeWidth: 3.0,
                          ),
                        );
                      }
                      // Tampilkan daftar kontak jika data sudah dimuat.
                      if (state is ContactLoaded) {
                        // Tampilkan pesan jika tidak ada kontak.
                        if (_filteredContacts.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.contact_mail_outlined,
                                size: 60,
                                color: theme.isDarkTheme
                                    ? darkTextSecondary
                                    : Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Kontak tidak ditemukan',
                                style: TextStyle(
                                  fontSize: theme.fontSize * 1.1,
                                  fontWeight: FontWeight.w500,
                                  color: theme.isDarkTheme
                                      ? darkTextPrimary
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coba kata kunci lain atau tambah kontak baru',
                                style: TextStyle(
                                  fontSize: theme.fontSize * 0.85,
                                  color: theme.isDarkTheme
                                      ? darkTextSecondary
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }
                        // Tampilkan AzListView jika ada kontak.
                        return AzListView(
                          data: _filteredContacts,
                          itemCount: _filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = _filteredContacts[index];
                            final tag = contact.getSuspensionTag();
                            final initials =
                                AvatarHelper.getInitials(contact.nama);
                            final avatarColor =
                                AvatarHelper.getAvatarColor(contact.id);

                            // Logika untuk menampilkan header alfabet.
                            final bool offstage = !contact.isShowSuspension;

                            return FadeTransition(
                              opacity: _listAnimationController!,
                              child: Column(
                                children: [
                                  // Header alfabet ('A', 'B', 'C', ...).
                                  Offstage(
                                    offstage: offstage,
                                    child: _buildSuspensionWidget(tag, theme),
                                  ),
                                  // Widget untuk setiap item kontak.
                                  _buildContactItem(
                                      contact, theme, initials, avatarColor),
                                ],
                              ),
                            );
                          },
                          indexBarOptions: IndexBarOptions(
                              textStyle: TextStyle(
                                  color: theme.isDarkTheme
                                      ? darkTextSecondary
                                      : darkBlue,
                                  fontSize: 11),
                              selectTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              selectItemDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.isDarkTheme
                                      ? accentBlue
                                      : primaryBlue)),
                          indexHintBuilder: (context, hint) => Container(
                              alignment: Alignment.center,
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                  color: theme.isDarkTheme
                                      ? accentBlue
                                      : primaryBlue,
                                  shape: BoxShape.circle),
                              child: Text(hint,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24.0))),
                        );
                      }
                      // Tampilan fallback jika terjadi error.
                      return Center(
                          child: Text('Kontak tidak ditemukan.',
                              style: TextStyle(
                                  fontSize: theme.fontSize * 0.9,
                                  color: theme.isDarkTheme
                                      ? darkTextSecondary
                                      : Colors.grey.shade600)));
                    },
                  ),
                ),
              ),
            ],
          ),
          drawer: AppSidebar(
            totalContacts: _allContacts.length,
            onShowFavorites: () {
              setState(() {
                _showingFavoritesOnly = true;
                _selectedKategori = 'Semua';
                _searchController.clear();
                _searchKeyword = '';
              });
              _runFilter();
              Navigator.pop(context);
            },
            onShowSettings: _showSettingsDialog,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
                context, SlideRightRoute(page: const AddEditContactPage())),
            backgroundColor: theme.isDarkTheme ? accentBlue : primaryBlue,
            shape: const CircleBorder(),
            tooltip: 'Tambah Kontak',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  /// Membangun AppBar kustom dengan gradient.
  Widget _buildModernAppBar(ThemeController theme) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: theme.isDarkTheme
                    ? [const Color(0xFF1E3A8A), const Color(0xFF1C2B5D)]
                    : [primaryBlue, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: SafeArea(
            bottom: false,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                          builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer())),
                      Image.asset('assets/KuyKontak.png', height: 45),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: RotationTransition(
                          turns: _syncAnimationController,
                          child: IconButton(
                            icon: const Icon(Icons.sync, color: Colors.white),
                            onPressed: _isSyncing ? null : _syncContacts,
                            tooltip: 'Sinkronisasi Kontak',
                          ),
                        ),
                      )
                    ]))));
  }

  /// Membangun search bar untuk mencari kontak.
  Widget _buildSearchBar(ThemeController theme) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchKeyword = value;
                if (_showingFavoritesOnly) _showingFavoritesOnly = false;
              });
              _runFilter();
            },
            style: TextStyle(
                color: theme.isDarkTheme ? darkTextPrimary : Colors.black87,
                fontSize: theme.fontSize * 0.9),
            cursorColor: theme.isDarkTheme ? accentBlue : primaryBlue,
            decoration: InputDecoration(
                hintText: 'Cari kontak...',
                hintStyle: TextStyle(
                    color: theme.isDarkTheme
                        ? darkTextSecondary
                        : Colors.grey.shade600),
                prefixIcon: Icon(Icons.search,
                    color: theme.isDarkTheme
                        ? darkTextSecondary
                        : Colors.grey.shade600),
                suffixIcon: _searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: theme.isDarkTheme
                                ? darkTextSecondary
                                : Colors.grey.shade600),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchKeyword = '');
                          _runFilter();
                        })
                    : null,
                filled: true,
                fillColor: theme.isDarkTheme ? darkSurface : Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none))));
  }

  /// Membangun daftar chip untuk filter kategori.
  Widget _buildCategoryChips(ThemeController theme) {
    return SizedBox(
        height: 40,
        child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _kategori.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final kategori = _kategori[index];
              final isSelected = _selectedKategori == kategori;
              return FilterChip(
                  selected: isSelected,
                  label: Text(kategori),
                  labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (theme.isDarkTheme ? darkTextPrimary : primaryBlue),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: theme.fontSize * 0.8),
                  checkmarkColor: Colors.white,
                  backgroundColor: theme.isDarkTheme
                      ? darkSurface
                      : lightBlue.withOpacity(0.5),
                  selectedColor: theme.isDarkTheme ? accentBlue : primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : (theme.isDarkTheme
                                  ? Colors.grey.shade700
                                  : primaryBlue.withOpacity(0.5)))),
                  onSelected: (selected) {
                    setState(() {
                      _selectedKategori = kategori;
                      if (_showingFavoritesOnly) _showingFavoritesOnly = false;
                    });
                    _runFilter();
                  });
            }));
  }

  /// Membangun header yang ditampilkan saat mode favorit aktif.
  Widget _buildFavoriteHeader(ThemeController theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: theme.isDarkTheme
              ? [
                  Colors.amber.withOpacity(0.15),
                  Colors.amber.withOpacity(0.08),
                ]
              : [
                  Colors.amber.shade50,
                  Colors.amber.shade100.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.isDarkTheme
              ? Colors.amber.withOpacity(0.3)
              : Colors.amber.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (value * 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.star,
                        color: Colors.amber.shade600,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Favorit',
                    style: TextStyle(
                      color: theme.isDarkTheme
                          ? Colors.amber.shade200
                          : Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: theme.fontSize * 0.9,
                    ),
                  ),
                  Text(
                    '${_filteredContacts.length} kontak',
                    style: TextStyle(
                      color: theme.isDarkTheme
                          ? Colors.amber.shade300.withOpacity(0.8)
                          : Colors.amber.shade700.withOpacity(0.8),
                      fontSize: theme.fontSize * 0.75,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() => _showingFavoritesOnly = false);
                _runFilter();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.isDarkTheme ? accentBlue : primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun widget untuk satu item kontak dalam daftar.
  Widget _buildContactItem(Contact contact, ThemeController theme,
      String initials, Color avatarColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) {},
        onExit: (_) {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(context,
                    SlideRightRoute(page: ContactDetailPage(contact: contact)));
              },
              hoverColor: theme.isDarkTheme
                  ? primaryBlue.withOpacity(0.15)
                  : primaryBlue.withOpacity(0.08),
              splashColor: theme.isDarkTheme
                  ? primaryBlue.withOpacity(0.25)
                  : primaryBlue.withOpacity(0.15),
              highlightColor: theme.isDarkTheme
                  ? primaryBlue.withOpacity(0.2)
                  : primaryBlue.withOpacity(0.1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.isDarkTheme ? darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.isDarkTheme
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar dengan Hero animation untuk transisi.
                    Hero(
                      tag: 'avatar_${contact.id}',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: contact.avatar.isNotEmpty
                              ? NetworkImage(contact.avatar)
                              : null,
                          backgroundColor: contact.avatar.isEmpty
                              ? avatarColor
                                  .withOpacity(theme.isDarkTheme ? 0.6 : 1.0)
                              : Colors.transparent,
                          child: contact.avatar.isEmpty
                              ? Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: initials.length > 1 ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  contact.nama,
                                  style: TextStyle(
                                    fontSize: theme.fontSize,
                                    fontWeight: FontWeight.w600,
                                    color: theme.isDarkTheme
                                        ? darkTextPrimary
                                        : Colors.grey.shade800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Menampilkan ikon bintang jika favorit.
                              if (contact.isFavorite)
                                Container(
                                  padding: const EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.amber.withOpacity(0.5),
                                        Colors.amber.withOpacity(0.0),
                                      ],
                                      stops: const [0.4, 1.0],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.star,
                                    color: Colors.amber.shade700,
                                    size: 15,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contact.noHp,
                            style: TextStyle(
                              fontSize: theme.fontSize * 0.85,
                              color: theme.isDarkTheme
                                  ? darkTextSecondary
                                  : Colors.grey.shade600,
                            ),
                          ),
                          // Menampilkan label grup jika ada.
                          if (contact.grup.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.isDarkTheme
                                      ? accentBlue.withOpacity(0.2)
                                      : primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  contact.grup,
                                  style: TextStyle(
                                    color: theme.isDarkTheme
                                        ? accentBlue
                                        : darkBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: theme.fontSize * 0.7,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun header alfabet ('A', 'B', 'C', ...) untuk AzListView.
  Widget _buildSuspensionWidget(String tag, ThemeController theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: theme.isDarkTheme ? darkBg : const Color(0xFFF0F2F5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.isDarkTheme
                  ? accentBlue.withOpacity(0.2)
                  : primaryBlue.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                tag,
                style: TextStyle(
                    fontSize: theme.fontSize * 0.9,
                    fontWeight: FontWeight.bold,
                    color: theme.isDarkTheme ? accentBlue : darkBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
