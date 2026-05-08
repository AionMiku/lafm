import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'share_image_generator_dialog.dart';
import '../duas/data/dua_repository.dart';
import '../duas/models/dua_models.dart';
import '../duas/ui/single_dua_screen.dart';

class DuaOfDayCard extends StatelessWidget {
  const DuaOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DuaCategory>>(
      future: DuaRepository.loadDuaCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _baseCard(
            context,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _baseCard(
            context,
            child: const Text(
              'Dua of the Day unavailable',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final validCategories = snapshot.data!
            .where((c) => c.duas.any((d) => d.arabic.isNotEmpty))
            .toList();

        if (validCategories.isEmpty) {
          return _baseCard(context, child: const Text('Dua of the Day unavailable'));
        }

        // Random Category & Dua
        final category = validCategories[Random().nextInt(validCategories.length)];
        final duaList = category.duas.where((d) => d.arabic.isNotEmpty).toList();
        final dua = duaList[Random().nextInt(duaList.length)];

        return _baseCard(
          context,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SingleDuaScreen(
                    dua: dua,
                    categoryTitle: category.titleEnglish,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Minimal Tag and Heart Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dua of the Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Small Dua Category Title
                  Text(
                    category.titleEnglish,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Arabic Text Preview
                  Text(
                    dua.arabic,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 18, height: 1.6),


                  ),
                  const SizedBox(height: 8),

                  // English Translation Preview
                  if (dua.translationEnglish.isNotEmpty) ...[
                    Text(
                      dua.translationEnglish,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70),


                    ),
                  ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Bottom Row: Copy, Share, Play Audio Buttons
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(12),
                          color: Theme.of(context).colorScheme.primary,
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () async {
                            final textToCopy = [
                              category.titleEnglish,
                              '',
                              dua.arabic,
                              if (dua.translationEnglish.isNotEmpty) ...['', dua.translationEnglish],
                            ].join('\n');
                            
                            await Clipboard.setData(ClipboardData(text: textToCopy));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Dua copied to clipboard!')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => ShareImageGeneratorDialog(
                                arabicText: dua.arabic,
                                englishText: dua.translationEnglish,
                                reference: category.titleEnglish,
                              ),
                            );
                          },
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share Graphic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(12),
                          color: Theme.of(context).colorScheme.primary,
                          icon: const Icon(Icons.play_arrow, size: 20),
                          onPressed: () {
                            // Play audio logic if dua.audioUrl isn't empty
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _baseCard(BuildContext context, {required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      child: child,
    );
  }
}
