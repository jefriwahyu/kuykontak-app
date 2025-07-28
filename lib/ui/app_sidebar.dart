import 'package:flutter/material.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

// Sidebar aplikasi dengan menu navigasi dan info kontak
class AppSidebar extends StatelessWidget {
  final int totalContacts; // Jumlah total kontak
  final VoidCallback onShowFavorites; // Callback untuk tampilkan favorit
  final VoidCallback onShowSettings; // Callback untuk tampilkan pengaturan

  const AppSidebar({
    super.key,
    required this.totalContacts,
    required this.onShowFavorites,
    required this.onShowSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        // Ambil preferensi tema dari controller
        final isDark = themeController.isDarkTheme;
        final fontSize = themeController.fontSize;

        return Drawer(
          width: MediaQuery.of(context).size.width *
              0.75, // Lebar sidebar 75% layar
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1E1E1E).withOpacity(0.95),
                        const Color(0xFF2D2D2D).withOpacity(0.95),
                      ]
                    : [
                        primaryColor.withOpacity(0.05),
                        secondaryColor.withOpacity(0.05),
                      ],
              ),
            ),
            child: Column(
              children: [
                // Header dengan logo aplikasi
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF1565C0),
                              const Color(0xFF0D47A1),
                            ]
                          : [primaryColor, secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/KuyKontak.png',
                          height: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Menu Aplikasi',
                          style: TextStyle(
                            fontSize: fontSize * 0.9, // Ukuran font responsif
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card informasi jumlah kontak
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: isDark ? 4 : 2,
                    color: isDark ? const Color(0xFF3D3D3D) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Icon kontak
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1565C0).withOpacity(0.3)
                                  : lightBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people,
                              color:
                                  isDark ? const Color(0xFF64B5F6) : darkBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Kontak',
                                style: TextStyle(
                                  fontSize: fontSize * 0.7,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '$totalContacts',
                                style: TextStyle(
                                  fontSize: fontSize * 1.0,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF64B5F6)
                                      : primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Daftar menu navigasi
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Menu kontak favorit
                      _buildMenuTile(
                        context,
                        icon: Icons.star,
                        title: 'Kontak Favorit',
                        color: Colors.amber.shade600,
                        onTap: () {
                          onShowFavorites();
                        },
                        isDark: isDark,
                        fontSize: fontSize,
                      ),
                      // Menu pengaturan
                      _buildMenuTile(
                        context,
                        icon: Icons.settings,
                        title: 'Pengaturan',
                        color: isDark ? const Color(0xFF64B5F6) : primaryColor,
                        onTap: () {
                          Navigator.pop(context);
                          onShowSettings();
                        },
                        isDark: isDark,
                        fontSize: fontSize,
                      ),
                    ],
                  ),
                ),

                // Footer dengan versi aplikasi
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Divider(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      ),
                      Text(
                        'KuyKontak v1.0',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontSize: fontSize * 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2025 KuyKontak Team',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                          fontSize: fontSize * 0.5,
                        ),
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
  }

  // Widget untuk membuat item menu
  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required double fontSize,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.transparent : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDark ? color.withOpacity(0.9) : color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize * 0.8,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hoverColor: isDark
            ? Colors.grey.shade700.withOpacity(0.3)
            : Colors.grey.shade100,
      ),
    );
  }
}
