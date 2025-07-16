import 'package:flutter/material.dart';
import 'package:kontak_app_m/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:kontak_app_m/ui/theme_controller.dart';

class AppSidebar extends StatelessWidget {
  final int totalContacts;
  final VoidCallback onShowFavorites;
  final VoidCallback onShowSettings;

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
        final isDark = themeController.isDarkTheme;
        final fontSize = themeController.fontSize;

        return Drawer(
          width: MediaQuery.of(context).size.width * 0.75,
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
                // Header dengan logo
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
                            fontSize: fontSize * 0.9, // Responsive font size
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Card informasi kontak
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
                                  fontSize:
                                      fontSize * 0.7, // Responsive font size
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '$totalContacts',
                                style: TextStyle(
                                  fontSize:
                                      fontSize * 1.0, // Responsive font size
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

                // Menu navigasi
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildMenuTile(
                        context,
                        icon: Icons.star,
                        title: 'Kontak Favorit',
                        color: Colors.amber.shade600,
                        onTap: () {
                          onShowFavorites();
                          // Navigator.pop(context);
                        },
                        isDark: isDark,
                        fontSize: fontSize,
                      ),
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

                // Footer
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
                          fontSize: fontSize * 0.6, // Responsive font size
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2025 KuyKontak Team',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                          fontSize: fontSize * 0.5, // Responsive font size
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
            fontSize: fontSize * 0.8, // Responsive font size
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
