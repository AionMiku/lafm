import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dua_models.dart';
import '../../../../core/settings/global_settings_controller.dart';
import '../../../../core/settings/settings_bottom_sheet.dart';
import '../../widgets/reader_card.dart';

class SingleDuaScreen extends StatelessWidget {
  final DuaItem dua;
  final String categoryTitle;

  const SingleDuaScreen({
    super.key,
    required this.dua,
    required this.categoryTitle,
  });

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
        title: Text(
          categoryTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                  hasTransliteration: true, // Specific Dua detail has translit
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReaderCard(
            header: 'Dua of the Day',
            arabic: dua.arabic,
            transliteration: dua.transliteration,
            translation: dua.translationEnglish,
            settings: settings,
          ),
        ],
      ),
    );
  }
}
