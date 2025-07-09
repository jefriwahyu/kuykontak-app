import 'package:flutter/material.dart';

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
    return Drawer(
      child: Container(
        color: Theme.of(context).drawerTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Logo di atas
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 32, bottom: 8),
              child: Center(
                child: Image.asset(
                  'assets/KuyKontak.png',
                  height: 70,
                ),
              ),
            ),
            // Tulisan Menu di bawah logo
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 18, bottom: 6),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            // Jumlah kontak
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.people,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(
                  'Jumlah Kontak: $totalContacts',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            // Menu: Kontak Favorit
            ListTile(
              leading: Icon(Icons.star, color: Colors.amber.shade700),
              title: const Text('Kontak Favorit'),
              onTap: onShowFavorites,
              textColor: Theme.of(context).textTheme.bodyLarge?.color,
              iconColor: Colors.amber.shade700,
            ),
            // Menu: Pengaturan
            ListTile(
              leading: Icon(Icons.settings,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('Pengaturan'),
              onTap: onShowSettings,
              textColor: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            const Divider(height: 24, thickness: 1),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 8),
              child: Text(
                'KuyKontak v1.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
