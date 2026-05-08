import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/prayer_settings_provider.dart';

class PrayerNotificationsScreen extends StatelessWidget {
  const PrayerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerSettingsProvider>(
      builder: (context, provider, child) {
        if (!provider.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final _cardColor = Theme.of(context).cardColor;
        final _scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
        final _textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
        final _subTextColor = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade400;

        // Extract prayers that we display (the same keys from provider)
        final prayersToDisplay = [
          {'name': 'Fajr', 'time': '5:07 AM'},
          {'name': 'Dhuhr', 'time': '12:23 PM'},
          {'name': 'Asr', 'time': '3:45 PM'},
          {'name': 'Maghrib', 'time': '6:28 PM'},
          {'name': 'Isha', 'time': '7:40 PM'},
        ];

        return Scaffold(
          backgroundColor: _scaffoldBg,
          appBar: AppBar(
            title: Text('Prayer Times', style: TextStyle(color: _textColor)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: _textColor),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // GLOBAL SETTINGS HEADER
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'GLOBAL SETTINGS',
                  style: TextStyle(color: _subTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              
              // MASTER SWITCH CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_active, color: Colors.greenAccent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enable All Notifications', style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('Master switch for all prayers', style: TextStyle(color: _subTextColor, fontSize: 13)),
                        ],
                      ),
                    ),
                    Switch(
                      value: provider.enableAll,
                      onChanged: provider.toggleMaster,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.greenAccent.shade700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // PRAYER TIMES HEADER
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRAYER TIMES',
                      style: TextStyle(color: _subTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // PRAYER CARDS
              ...prayersToDisplay.map((p) => _buildPrayerCard(
                context, 
                p['name']!, 
                p['time']!, 
                provider, 
                _cardColor, 
                _textColor, 
                _subTextColor
              )),
              
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerCard(
    BuildContext context, 
    String prayerName, 
    String time, 
    PrayerSettingsProvider provider,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    final data = provider.getPrayerSettings(prayerName);
    bool isEnabled = data['enabled'] ?? false;
    String soundOption = data['sound'] ?? 'Sound 1';

    Color iconBgColor = PrayerSettingsProvider.getPrayerIconBgColor(prayerName);
    Color iconColor = PrayerSettingsProvider.getPrayerIconColor(prayerName);
    IconData icon = PrayerSettingsProvider.getPrayerIcon(prayerName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(prayerName, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(time, style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w500)),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                // Sound Dropdown Trigger (UI ONLY)
                GestureDetector(
                  onTap: () {
                    provider.toggleSound(prayerName);
                  },
                  child: Text(soundOption, style: TextStyle(color: subTextColor, fontSize: 13)),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (val) => provider.togglePrayer(prayerName, val),
            activeColor: Colors.white,
            activeTrackColor: Colors.greenAccent.shade700,
          ),
          const SizedBox(width: 8),
          Icon(Icons.keyboard_arrow_down, color: subTextColor, size: 20),
        ],
      ),
    );
  }
}
