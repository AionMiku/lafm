import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings/global_settings_controller.dart';
import '../../navigation/bottom_nav.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = 'Ready to sync';

  void _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Connecting to library servers...';
      _progress = 0.05;
    });

    // Simulate Network/Download delays for asset compilation
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _statusText = 'Downloading Holy Quran (Audio & Text)...';
      _progress = 0.25;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _statusText = 'Unpacking Hadith Collections...';
      _progress = 0.60;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _statusText = 'Syncing Duas and Adhkar...';
      _progress = 0.85;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _statusText = 'Finalizing offline database...';
      _progress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    
    // Complete the flow and skip forever
    Provider.of<GlobalSettingsController>(context, listen: false).completeOnboarding();
  }

  void _skip() {
    Provider.of<GlobalSettingsController>(context, listen: false).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // App Branding / Welcome
              const Icon(Icons.mosque, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Welcome to LAFM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To provide you with a seamless, lightning-fast experience without relying on constant internet access, we need to download the core library assets (Quran, Hadith, Duas) directly to your device storage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(height: 48),

              // The Download UI State
              if (_isDownloading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black, // Dark text on bright mint
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _startDownload,
                      child: const Text(
                        'Download Offline Library (Recommended)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                  ],
                ),
                
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
