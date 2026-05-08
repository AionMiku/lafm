import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dua_models.dart';
import '/../../../core/settings/global_settings_controller.dart';
import '/../../../core/settings/settings_bottom_sheet.dart';
import '../../widgets/reader_card.dart';

class DuaListScreen extends StatelessWidget {
  final DuaCategory category;

  const DuaListScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GlobalSettingsController>();

    // Safety: wait for persisted settings
    if (!settings.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.titleEnglish,
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
                  hasTransliteration: false, // ✅ Duas have no transliteration
                ),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.duas.length,
        itemBuilder: (context, index) {
          final dua = category.duas[index];

          return ReaderCard(
            header: 'Dua ${index + 1}',
            arabic: dua.arabic,
            translation: dua.translationEnglish,
            settings: settings,
          );
        },
      ),
    );
  }
}
