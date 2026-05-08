import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/settings/theme_controller.dart';
import '../../home/screens/prayer_notifications_screen.dart';
import 'customize_widgets_screen.dart';
import 'theme_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Section
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                SizedBox(height: 16),
                Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sign in to sync your data across devices',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          
          ElevatedButton(
            onPressed: () {
              // TODO: Implement Login Logic
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.0),
              ),
            ),
            child: const Text('Login / Sign Up'),
          ),

          const SizedBox(height: 32),

          // Settings Section
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.widgets),
                  title: const Text('Customize Widgets'),
                  subtitle: const Text('Edit in-app components and shapes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomizeWidgetsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Theme Settings'),
                  subtitle: const Text('Colors, aesthetics & glass opacity'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ThemeSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Prayer Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrayerNotificationsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text('Saved Bookmarks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                     // TODO: Open bookmarks
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
