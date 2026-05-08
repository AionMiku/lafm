import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/prayer_time_model.dart';
import '../../../core/providers/prayer_settings_provider.dart';

class PrayerList extends StatefulWidget {
  const PrayerList({super.key});

  @override
  State<PrayerList> createState() => _PrayerListState();
}

class _PrayerListState extends State<PrayerList> {
  PrayerTimes? prayerTimes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    final storage = StorageService();

    try {
      final cached = await storage.getCachedPrayerTimes();
      if (cached != null) {
        if (!mounted) return;
        setState(() {
          prayerTimes = cached;
          isLoading = false;
        });
        return;
      }

      final location = await LocationService().getCurrentLocation();

      final fresh = await PrayerService().fetchPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      await storage.savePrayerTimes(fresh);

      if (!mounted) return;
      setState(() {
        prayerTimes = fresh;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// Convert 24h → 12h format
  String _to12Hour(String time24) {
    if (time24.isEmpty || time24.contains('-')) return time24;
    final parts = time24.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].split(' ')[0]);

    if (hour == null || minute == null) return time24;

    final dt = DateTime(0, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(dt);
  }

  /// Detect next prayer
  String _getNextPrayer() {
    if (prayerTimes == null) return 'Fajr';
    
    final now = DateTime.now();

    final prayers = {
      'Fajr': prayerTimes!.fajr,
      'Dhuhr': prayerTimes!.dhuhr,
      'Asr': prayerTimes!.asr,
      'Maghrib': prayerTimes!.maghrib,
      'Isha': prayerTimes!.isha,
    };

    for (var entry in prayers.entries) {
      if (entry.value.isEmpty) continue;
      final parts = entry.value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);

      final prayerTime =
          DateTime(now.year, now.month, now.day, hour, minute);

      if (now.isBefore(prayerTime)) {
        return entry.key;
      }
    }

    return 'Fajr';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _getNextPrayer();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _prayerCard('Fajr', prayerTimes?.fajr ?? '--:--', nextPrayer),
          _prayerCard('Dhuhr', prayerTimes?.dhuhr ?? '--:--', nextPrayer),
          _prayerCard('Asr', prayerTimes?.asr ?? '--:--', nextPrayer),
          _prayerCard('Maghrib', prayerTimes?.maghrib ?? '--:--', nextPrayer),
          _prayerCard('Isha', prayerTimes?.isha ?? '--:--', nextPrayer),
        ],
      ),
    );
  }

  Widget _prayerCard(
    String name,
    String time,
    String nextPrayer,
  ) {
    final bool isNext = name == nextPrayer;

    // Use unified colors and icons from the provider
    Color iconColor = PrayerSettingsProvider.getPrayerIconColor(name);
    IconData icon = PrayerSettingsProvider.getPrayerIcon(name);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(

          /// Tap → prayer details
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrayerDetailsScreen(prayerName: name, time: _to12Hour(time)),
              ),
            );
          },

          /// Long press → quick settings
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Consumer<PrayerSettingsProvider>(
                  builder: (context, provider, child) {
                    final data = provider.getPrayerSettings(name);
                    bool isEnabled = data['enabled'] ?? false;
                    
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Text(
                            "$name Settings",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ListTile(
                            leading: Icon(isEnabled ? Icons.notifications_active : Icons.notifications_off),
                            title: Text(isEnabled ? "Disable Notification" : "Enable Notification"),
                            onTap: () {
                              provider.togglePrayer(name, !isEnabled);
                              Navigator.pop(context); // Close bottom sheet after toggle
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.volume_up),
                            title: const Text("Sound Settings"),
                            onTap: () {
                              provider.toggleSound(name);
                              Navigator.pop(context);
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.access_time),
                            title: const Text("Reminder 10 minutes before"),
                            onTap: () {},
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            );
          },

          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isNext
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// icon
                Icon(icon, size: 15, color: iconColor),
                
                const SizedBox(height: 4),

                /// name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                /// time
                Text(
                  _to12Hour(time),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A specific screen for prayer details & settings
class PrayerDetailsScreen extends StatelessWidget {
  final String prayerName;
  final String time;

  const PrayerDetailsScreen({super.key, required this.prayerName, required this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$prayerName Details"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<PrayerSettingsProvider>(
        builder: (context, provider, child) {
          final data = provider.getPrayerSettings(prayerName);
          final bool isEnabled = data['enabled'] ?? false;
          final String sound = data['sound'] ?? 'Default';
          
          Color iconBgColor = PrayerSettingsProvider.getPrayerIconBgColor(prayerName);
          Color iconColor = PrayerSettingsProvider.getPrayerIconColor(prayerName);
          IconData icon = PrayerSettingsProvider.getPrayerIcon(prayerName);
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Hero banner showing the prayer icon and time
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      prayerName,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Notification Settings Card
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'NOTIFICATIONS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEnabled ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isEnabled ? Icons.notifications_active : Icons.notifications_off, 
                          color: isEnabled ? Colors.greenAccent : Colors.grey
                        ),
                      ),
                      title: const Text("Prayer Notification", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(isEnabled ? "Enabled for $prayerName" : "Disabled"),
                      trailing: Switch(
                        value: isEnabled,
                        onChanged: (val) {
                          provider.togglePrayer(prayerName, val);
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.greenAccent.shade700,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.volume_up, 
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      title: const Text("Notification Sound", style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(sound),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        provider.toggleSound(prayerName);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}