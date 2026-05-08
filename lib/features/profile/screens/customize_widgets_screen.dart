import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/settings/global_settings_controller.dart';

class CustomizeWidgetsScreen extends StatelessWidget {
  const CustomizeWidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Widgets')),
      body: Consumer<GlobalSettingsController>(
        builder: (context, globalSettings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'HOME SCREEN WIDGETS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Prayer Timer Style Toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('Prayer Timer Style'),
                      subtitle: const Text('Choose between a circular ring or a rectangular path tracker.'),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StyleCard(
                              title: 'Classic Ring',
                              icon: Icons.data_usage,
                              isSelected: globalSettings.prayerTimerStyle == 'ring',
                              onTap: () => globalSettings.setPrayerTimerStyle('ring'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StyleCard(
                              title: 'Square Path',
                              icon: Icons.crop_square,
                              isSelected: globalSettings.prayerTimerStyle == 'square',
                              onTap: () => globalSettings.setPrayerTimerStyle('square'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'More widget customizations coming soon.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StyleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.white54;
    final bgColor = isSelected ? color.withOpacity(0.15) : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
