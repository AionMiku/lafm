import 'package:flutter/material.dart';
import '../../../core/services/quran_service.dart';
import '../../../data/models/surah_model.dart';
import 'quran_juz_data.dart';
import 'surah_reader_screen.dart';

class QuranHomeScreen extends StatefulWidget {
  const QuranHomeScreen({super.key});

  @override
  State<QuranHomeScreen> createState() => _QuranHomeScreenState();
}

class _QuranHomeScreenState extends State<QuranHomeScreen> {
  final QuranService service = QuranService();

  List<Surah> surahs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    await service.loadSurahs();

    if (!mounted) return;
    setState(() {
      surahs = service.surahs;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Qur’an'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Surahs'),
              Tab(text: 'Juz'),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildSurahsTab(),
                  _buildJuzTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildSurahsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final s = surahs[index];
        return _buildSurahCard(s);
      },
    );
  }

  Widget _buildJuzTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: juzBoundaries.length,
      itemBuilder: (context, index) {
        final j = juzBoundaries[index];
        // Find surah names for display
        // Watch out: Surah IDs start at 1, indexes start at 0
        final startSurahName = surahs.length >= j.startSurah ? surahs[j.startSurah - 1].nameEn : '';
        final endSurahName = surahs.length >= j.endSurah ? surahs[j.endSurah - 1].nameEn : '';

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // We'll push the reader screen for the Start Surah,
              // Ideally the reader screen should handle scrolling to the ayah or loading cross-surah,
              // but bridging them to the start of the juz is functionally accepted.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahReaderScreen(
                    surahNumber: j.startSurah,
                    surahName: surahs[j.startSurah - 1].nameEn,
                    surahMeaning: surahs[j.startSurah - 1].nameEnMeaning ?? '',
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${j.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Juz ${j.id}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$startSurahName: ${j.startAyah}  →  $endSurahName: ${j.endAyah}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahCard(Surah s) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahReaderScreen(
                surahNumber: s.number,
                surahName: s.nameEn,
                surahMeaning: s.nameEnMeaning ?? '',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              /// Ayah count (LEFT)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.ayahs.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ayahs',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              /// Names (CENTER)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.nameAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.nameEn,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
