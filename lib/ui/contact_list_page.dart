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
import 'package:kontak_app_m/ui/app_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];

  final List<String> _kategori = ['Semua', 'Keluarga', 'Teman', 'Kerja'];
  String _selectedKategori = 'Semua';
  String _searchKeyword = '';
  bool _showingFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<ContactBloc>().state;
    if (currentState is ContactLoaded) {
      _allContacts = currentState.contacts;
      _runFilter(); // Jalankan filter awal
    }
  }

  // --- FUNGSI FILTER YANG DIPERBARUI DENGAN OPTIMASI ---
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
              contact.nama.toLowerCase().contains(_searchKeyword.toLowerCase()))
          .toList();
    }

    // Buat list dengan favorite di atas tanpa sorting alfabet untuk favorite
    List<Contact> favoriteContacts =
        results.where((c) => c.isFavorite).toList();
    List<Contact> nonFavoriteContacts =
        results.where((c) => !c.isFavorite).toList();

    // Sort hanya non-favorite secara alfabet
    SuspensionUtil.sortListBySuspensionTag(nonFavoriteContacts);
    SuspensionUtil.setShowSuspensionStatus(nonFavoriteContacts);

    // Gabungkan: favorite di atas, lalu non-favorite
    List<Contact> finalResults = [...favoriteContacts, ...nonFavoriteContacts];

    setState(() {
      _filteredContacts = finalResults;
    });
  }

  Future<void> _syncContacts() async {
    context.read<ContactBloc>().add(SyncContacts());
  }

  void _showSettingsDialog() {
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ThemeController>(
          builder: (context, theme, _) => AlertDialog(
            title: const Text('Pengaturan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tema Gelap'),
                    Switch(
                      value: theme.isDarkTheme,
                      onChanged: (val) => themeController.toggleTheme(val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ukuran Font'),
                    Text(theme.fontSize.toStringAsFixed(0)),
                  ],
                ),
                Slider(
                  min: 12,
                  max: 28,
                  divisions: 16,
                  value: theme.fontSize,
                  label: theme.fontSize.toStringAsFixed(0),
                  onChanged: (val) => themeController.setFontSize(val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, theme, _) {
        final darkBg = const Color(0xFF23272F);
        final darkCard = const Color(0xFF2D313A);
        final darkSidebar = const Color(0xFF23272F);
        final themeData = Theme.of(context).copyWith(
          brightness: theme.isDarkTheme ? Brightness.dark : Brightness.light,
          scaffoldBackgroundColor: theme.isDarkTheme ? darkBg : null,
          cardColor: theme.isDarkTheme ? darkCard : null,
          dialogBackgroundColor: theme.isDarkTheme ? darkCard : null,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: theme.isDarkTheme ? darkCard : Colors.white,
            labelStyle: TextStyle(
                color: theme.isDarkTheme ? Colors.white : Colors.black),
            hintStyle: TextStyle(
                color: theme.isDarkTheme ? Colors.white70 : Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: theme.isDarkTheme ? Colors.white24 : Colors.black26),
            ),
          ),
          iconTheme: IconThemeData(
              color: theme.isDarkTheme ? Colors.white : Colors.black),
          appBarTheme: AppBarTheme(
            backgroundColor: theme.isDarkTheme ? darkSidebar : Colors.white,
            iconTheme: IconThemeData(
                color: theme.isDarkTheme ? Colors.white : Colors.black),
            titleTextStyle: TextStyle(
              color: theme.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: Theme.of(context).textTheme.apply(
                fontSizeFactor: theme.fontSize / 16.0,
                bodyColor: theme.isDarkTheme ? Colors.white : Colors.black,
                displayColor: theme.isDarkTheme ? Colors.white : Colors.black,
              ),
          drawerTheme: DrawerThemeData(
            backgroundColor: theme.isDarkTheme ? darkSidebar : Colors.white,
          ),
        );
        return Theme(
          data: themeData,
          child: BlocListener<ContactBloc, ContactState>(
            listener: (context, state) {
              if (state is ContactLoaded) {
                setState(() {
                  _allContacts = state.contacts;
                  _runFilter();
                });
              }
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Center(
                  child: Image.asset(
                    'assets/KuyKontak.png',
                    height: 75,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'Sinkronisasi Kontak',
                    onPressed: _syncContacts,
                  )
                ],
              ),
              drawer: AppSidebar(
                totalContacts: _allContacts.length,
                onShowFavorites: () {
                  setState(() {
                    _selectedKategori = 'Semua';
                    _searchKeyword = '';
                    _filteredContacts =
                        _allContacts.where((c) => c.isFavorite).toList();
                    _showingFavoritesOnly = true;
                  });
                  Navigator.of(context).pop();
                },
                onShowSettings: _showSettingsDialog,
              ),
              body: Column(
                children: [
                  if (_showingFavoritesOnly)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Kembali ke Semua Kontak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.isDarkTheme
                                  ? Colors.blueGrey.shade700
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _showingFavoritesOnly = false;
                                _runFilter();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SegmentedButton<String>(
                            segments: _kategori
                                .map((k) => ButtonSegment<String>(
                                      value: k,
                                      label: Text(
                                        k,
                                        style: TextStyle(
                                          color: theme.isDarkTheme
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            selected: {_selectedKategori},
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _selectedKategori = newSelection.first;
                                _showingFavoritesOnly = false;
                                _runFilter();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (value) {
                            _searchKeyword = value;
                            _showingFavoritesOnly = false;
                            _runFilter();
                          },
                          decoration: const InputDecoration(
                              labelText: 'Pencarian',
                              prefixIcon: Icon(Icons.search)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<ContactBloc, ContactState>(
                      builder: (context, state) {
                        if (state is ContactLoading ||
                            state is ContactInitial) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is ContactLoaded) {
                          if (_allContacts.isEmpty) {
                            return const Center(
                                child: Text('Tidak ada kontak.'));
                          }
                          if (_filteredContacts.isEmpty) {
                            return const Center(
                                child: Text('Kontak tidak ditemukan.'));
                          }
                          // --- TIDAK ADA LAGI PROSES SORTING DI SINI ---
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
                            indexBarOptions: IndexBarOptions(
                              needRebuild: true,
                              hapticFeedback: true,
                              textStyle: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                              selectTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              selectItemDecoration: BoxDecoration(
                                  shape: BoxShape.circle, color: primaryColor),
                            ),
                            indexHintBuilder: (context, hint) {
                              return Container(
                                alignment: Alignment.center,
                                width: 60.0,
                                height: 60.0,
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
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
                            child:
                                Text('Mulai dengan menambahkan kontak baru.'));
                      },
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context,
                      SlideRightRoute(page: const AddEditContactPage()));
                },
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        );
      },
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
          title: Row(
            children: [
              Expanded(
                child: Text(contact.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (contact.isFavorite)
                const Icon(Icons.star, color: Colors.amber, size: 16),
            ],
          ),
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
