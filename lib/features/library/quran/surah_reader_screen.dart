import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/quran_service.dart';
import '../../../core/settings/global_settings_controller.dart';
import '../../../core/settings/settings_bottom_sheet.dart';
import '../widgets/reader_card.dart';

class SurahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahMeaning;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surahMeaning,
  });

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  final QuranService service = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> ayahs = [];
  bool loading = true;
  bool _isPlaying = false;
  int? _currentlyPlayingAyahIndex;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadAyahs() async {
    final data = await service.getSurahAyahs(widget.surahNumber);

    if (!mounted) return;
    setState(() {
      ayahs = data;
      loading = false;
    });
  }

  Future<void> _playSurah() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
      return;
    }

    try {
      setState(() => _isPlaying = true);
      
      final prefs = await SharedPreferences.getInstance();
      int startIndex = _currentlyPlayingAyahIndex ?? prefs.getInt('last_ayah_${widget.surahNumber}') ?? 0;
      if (startIndex >= ayahs.length) startIndex = 0;

      for (int i = startIndex; i < ayahs.length; i++) {
        if (!mounted || !_isPlaying) break;

        setState(() => _currentlyPlayingAyahIndex = i);
        await prefs.setInt('last_ayah_${widget.surahNumber}', i);

        String url = ayahs[i]['audio'] as String;

        await _audioPlayer.setUrl(url);
        await _audioPlayer.play();
        
        await _audioPlayer.playerStateStream.firstWhere(
            (state) => state.processingState == ProcessingState.completed
        );
      }
      
      if (mounted && _isPlaying) {
        setState(() {
          _isPlaying = false;
          _currentlyPlayingAyahIndex = null;
        });
        await prefs.setInt('last_ayah_${widget.surahNumber}', 0);
      }

    } catch (e) {
      debugPrint("Error playing audio: $e");
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _playSingleAyah(int index) async {
    if (_isPlaying && _currentlyPlayingAyahIndex == index) {
      // Tap again to stop
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
        // Keep the index so if they hit Play Surah, it resumes from here
      });
      return;
    }

    // Stop existing full loop by flipping _isPlaying briefly
    setState(() {
      _isPlaying = false;
      _currentlyPlayingAyahIndex = index;
    });

    try {
      // Write history so the Play Button resumes here
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_ayah_${widget.surahNumber}', index);

      String url = ayahs[index]['audio'] as String;
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      
      // Wait for it to finish, then clear UI state (but dont flip _isPlaying back true as it's not looping)
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted && !_isPlaying) {
           setState(() => _currentlyPlayingAyahIndex = null);
        }
      });
    } catch (e) {
      debugPrint("Error single audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GlobalSettingsController>();

    if (!settings.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surahName),
            Text(
              widget.surahMeaning,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
             icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
             iconSize: 32,
             color: Theme.of(context).colorScheme.primary,
             onPressed: _playSurah,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SettingsBottomSheet(
                  hasArabic: true,
                  hasTranslation: true,
                  hasTransliteration: true,
                ),
              );
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ayahs.length,
              itemBuilder: (context, index) {
                final ayah = ayahs[index];
                final ayahNo = ayah['ayah_number'];
                final isHighlight = index == _currentlyPlayingAyahIndex;

                return GestureDetector(
                  onTap: () => _playSingleAyah(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: isHighlight 
                      ? BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        )
                      : null,
                    child: ReaderCard(
                      header: '${widget.surahNumber}:$ayahNo',
                      arabic: ayah['arabic'],
                      transliteration: ayah['translit'],
                      translation: ayah['english'],
                      settings: settings,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
