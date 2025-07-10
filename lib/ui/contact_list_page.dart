import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kontak_app_m/bloc/contact_bloc.dart';
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

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage>
    with TickerProviderStateMixin {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final List<String> _kategori = ['Semua', 'Keluarga', 'Teman', 'Kerja'];
  String _selectedKategori = 'Semua';
  String _searchKeyword = '';
  bool _showingFavoritesOnly = false;
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Warna tema
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.easeOutCubic));

    // Mulai animasi
    _animationController!.forward();

    // Gunakan post frame callback untuk mengakses context dengan aman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<ContactBloc>().state;
      if (currentState is ContactLoaded) {
        setState(() {
          _allContacts = currentState.contacts;
          _runFilter();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    List<Contact> results;

    if (_selectedKategori == 'Semua') {
      results = _allContacts;
    } else {
      results = _allContacts.where((c) => c.grup == _selectedKategori).toList();
    }

    if (_searchKeyword.isNotEmpty) {
      results = results
          .where((contact) =>
              contact.nama
                  .toLowerCase()
                  .contains(_searchKeyword.toLowerCase()) ||
              contact.noHp.contains(_searchKeyword))
          .toList();
    }

    List<Contact> favoriteContacts =
        results.where((c) => c.isFavorite).toList();
    List<Contact> nonFavoriteContacts =
        results.where((c) => !c.isFavorite).toList();

    SuspensionUtil.sortListBySuspensionTag(nonFavoriteContacts);
    SuspensionUtil.setShowSuspensionStatus(nonFavoriteContacts);

    List<Contact> finalResults = [...favoriteContacts, ...nonFavoriteContacts];

    setState(() {
      _filteredContacts = finalResults;
    });
  }

  Future<void> _syncContacts() async {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sinkronisasi Kontak...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    try {
      if (await Permission.contacts.request().isGranted) {
        List<FC.Contact> deviceContacts = await FC.FlutterContacts.getContacts(
          withProperties: true,
        );

        List<Map<String, dynamic>> contactsToSync = [];
        for (var contact in deviceContacts) {
          if (contact.phones.isNotEmpty && contact.displayName.isNotEmpty) {
            contactsToSync.add({
              'nama': contact.displayName,
              'no_hp':
                  contact.phones.first.number.replaceAll(RegExp(r'[\\s-]'), ''),
              'email':
                  contact.emails.isNotEmpty ? contact.emails.first.address : ''
            });
          }
        }

        final message = await ContactService.syncContacts(contactsToSync);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          context.read<ContactBloc>().add(LoadContacts());
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin akses kontak ditolak'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      overlayEntry?.remove();
    }
  }

  void _showSettingsDialog() {
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeController>(
          builder: (context, theme, _) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.settings, color: primaryBlue),
                const SizedBox(width: 12),
                const Text('Pengaturan'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode, color: Colors.grey.shade600),
                          const SizedBox(width: 12),
                          const Text('Tema Gelap'),
                        ],
                      ),
                      Switch(
                        value: theme.isDarkTheme,
                        onChanged: (val) => themeController.toggleTheme(val),
                        activeColor: primaryBlue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.text_fields,
                                  color: Colors.grey.shade600),
                              const SizedBox(width: 12),
                              const Text('Ukuran Font'),
                            ],
                          ),
                          Text(
                            theme.fontSize.toStringAsFixed(0),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primaryBlue,
                          thumbColor: primaryBlue,
                          overlayColor: primaryBlue.withAlpha(32),
                        ),
                        child: Slider(
                          min: 12,
                          max: 28,
                          divisions: 16,
                          value: theme.fontSize,
                          label: theme.fontSize.toStringAsFixed(0),
                          onChanged: (val) => themeController.setFontSize(val),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/KuyKontak.png',
                    height: 60,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white),
                  tooltip: 'Sinkronisasi Kontak',
                  onPressed: _syncContacts,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchKeyword = value;
            _showingFavoritesOnly = false;
          });
          _runFilter();
        },
        decoration: InputDecoration(
          hintText: 'Cari kontak...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchKeyword.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey.shade600),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchKeyword = '';
                      _showingFavoritesOnly = false;
                    });
                    _runFilter();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _kategori.length,
        itemBuilder: (context, index) {
          final kategori = _kategori[index];
          final isSelected = _selectedKategori == kategori;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                kategori,
                style: TextStyle(
                  color: isSelected ? Colors.white : primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
              selectedColor: primaryBlue,
              checkmarkColor: Colors.white,
              side: BorderSide(color: primaryBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedKategori = kategori;
                  _showingFavoritesOnly = false;
                });
                _runFilter();
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.isDarkTheme
              ? const Color(0xFF121212)
              : const Color(0xFFF8F9FA),
          body: Column(
            children: [
              _buildModernAppBar(),
              if (_showingFavoritesOnly)
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Daftar Kontak Favorit',
                                style: TextStyle(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBlue,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showingFavoritesOnly = false;
                          });
                          _runFilter();
                        },
                      ),
                    ],
                  ),
                ),
              _buildSearchBar(),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              Expanded(
                child: BlocListener<ContactBloc, ContactState>(
                  listener: (context, state) {
                    if (state is ContactLoaded) {
                      setState(() {
                        _allContacts = state.contacts;
                        _runFilter();
                      });
                    }
                  },
                  child: BlocBuilder<ContactBloc, ContactState>(
                    builder: (context, state) {
                      if (state is ContactLoading || state is ContactInitial) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primaryBlue),
                          ),
                        );
                      }
                      if (state is ContactLoaded) {
                        if (_allContacts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.contacts,
                                    size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada kontak',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (_filteredContacts.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Kontak tidak ditemukan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return FadeTransition(
                          opacity: _fadeAnimation!,
                          child: SlideTransition(
                            position: _slideAnimation!,
                            child: AzListView(
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
                                    _buildContactItem(contact, index),
                                  ],
                                );
                              },
                              indexBarOptions: IndexBarOptions(
                                needRebuild: true,
                                hapticFeedback: true,
                                textStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                selectTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                selectItemDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryBlue,
                                ),
                              ),
                              indexHintBuilder: (context, hint) {
                                return Container(
                                  alignment: Alignment.center,
                                  width: 70.0,
                                  height: 70.0,
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryBlue.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    hint,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      if (state is ContactError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 80, color: Colors.red.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Terjadi Kesalahan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(state.message),
                            ],
                          ),
                        );
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add,
                                size: 80, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Mulai dengan menambahkan kontak baru',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
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
                _selectedKategori = 'Semua';
                _searchKeyword = '';
                _searchController.clear();
                _filteredContacts =
                    _allContacts.where((c) => c.isFavorite).toList();
                _showingFavoritesOnly = true;
              });
              Navigator.of(context).pop();
            },
            onShowSettings: _showSettingsDialog,
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              shape:
                  BoxShape.circle, // Pastikan bentuk container juga lingkaran
              gradient: LinearGradient(
                colors: [primaryBlue, secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideRightRoute(page: const AddEditContactPage()),
                );
              },
              backgroundColor: Colors
                  .transparent, // Warna transparan untuk menunjukkan gradient container
              elevation: 0, // Nonaktifkan elevation default FAB
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactItem(Contact contact, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              SlideRightRoute(page: ContactDetailPage(contact: contact)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_${contact.nama}',
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primaryBlue.withOpacity(0.8),
                          secondaryBlue.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: contact.avatar.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              contact.avatar,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarText(contact.nama),
                            ),
                          )
                        : _buildAvatarText(contact.nama),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isFavorite)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.star,
                                color: Colors.amber.shade600,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.noHp,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (contact.grup.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contact.grup,
                            style: TextStyle(
                              fontSize: 12,
                              color: darkBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarText(String nama) {
    return Center(
      child: Text(
        nama.isNotEmpty ? nama[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSuspensionWidget(String tag) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: lightBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: darkBlue,
        ),
      ),
    );
  }
}
