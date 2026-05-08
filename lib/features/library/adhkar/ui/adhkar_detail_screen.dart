import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/share_image_generator_dialog.dart';
import '/../../../core/settings/global_settings_controller.dart';
import '/../../../core/settings/settings_bottom_sheet.dart';
import '../models/adhkar_item.dart';

class AdhkarDetailScreen extends StatelessWidget {
  final AdhkarItem item;

  const AdhkarDetailScreen({
    super.key,
    required this.item,
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
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final cleanContent = item.content.isNotEmpty 
                  ? item.content 
                  : item.contentHtml.replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), ' ').trim();
              
              await Clipboard.setData(ClipboardData(text: cleanContent));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final cleanContent = item.content.isNotEmpty 
                  ? item.content 
                  : item.contentHtml.replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), ' ').trim();
              
              showDialog(
                context: context,
                builder: (_) => ShareImageGeneratorDialog(
                  arabicText: cleanContent,
                  reference: item.title,
                ),
              );
            },
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
                  hasTranslation: false,      // ✅ Correct
                  hasTransliteration: false,  // ✅ Correct
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: item.contentHtml.isNotEmpty
              ? item.contentHtml
              : item.content,
          style: {
            "*": Style(
              fontSize: FontSize(
                16 *
                    settings.baseScale *
                    settings.arabicScale,
              ),
              lineHeight: LineHeight.number(1.8),
            ),
          },
        ),
      ),
    );
  }
}
