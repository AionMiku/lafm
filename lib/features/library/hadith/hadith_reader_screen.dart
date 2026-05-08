import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/hadith_repository.dart';
import 'hadith_models.dart';
import '../../../core/settings/global_settings_controller.dart';
import '../../../core/settings/settings_bottom_sheet.dart';
import '../widgets/reader_card.dart';

class HadithReaderScreen extends StatefulWidget {
  final HadithBook book;

  const HadithReaderScreen({
    super.key,
    required this.book,
  });

  @override
  State<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends State<HadithReaderScreen> {
  late Future<List<Hadith>> hadithFuture;

  @override
  void initState() {
    super.initState();
    hadithFuture = HadithRepository.loadHadiths(widget.book.id);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GlobalSettingsController>();

    // Safety: wait until SharedPreferences are loaded
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
            Text(
              widget.book.titleEnglish,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.book.totalHadith} hadiths',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).appBarTheme.foregroundColor?.withValues(alpha: 0.7) ?? Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
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
                  hasTransliteration: false, // ✅ Hadith has NO transliteration
                ),
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Hadith>>(
        future: hadithFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hadiths found'));
          }

          final hadiths = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final h = hadiths[index];

              return ReaderCard(
                header: 'Hadith ${h.numberInBook}',
                arabic: h.arabic,
                translation: h.englishText,
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }
}
