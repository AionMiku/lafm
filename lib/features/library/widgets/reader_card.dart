import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/settings/global_settings_controller.dart';
import 'share_image_generator_dialog.dart';

class ReaderCard extends StatefulWidget {
  final String header;            // "Hadith 1", "1:1", "Dua 3"
  final String arabic;
  final String? transliteration;
  final String? translation;
  final GlobalSettingsController settings;
  final bool expandable;          // hadith = true, others = false

  const ReaderCard({
    super.key,
    required this.header,
    required this.arabic,
    required this.settings,
    this.transliteration,
    this.translation,
    this.expandable = false,
  });

  @override
  State<ReaderCard> createState() => _ReaderCardState();
}

class _ReaderCardState extends State<ReaderCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;

    final arabicSize = 20 * s.baseScale * s.arabicScale;
    final translitSize = 14 * s.baseScale * s.transliterationScale;
    final translationSize = 14 * s.baseScale * s.translationScale;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= HEADER & SHARE =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.header,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        final textToCopy = [
                          widget.header,
                          '',
                          widget.arabic,
                          if (widget.transliteration != null && widget.transliteration!.isNotEmpty) ...['', widget.transliteration!],
                          if (widget.translation != null && widget.translation!.isNotEmpty) ...['', widget.translation!],
                        ].join('\n');
                        
                        await Clipboard.setData(ClipboardData(text: textToCopy));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard!')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => ShareImageGeneratorDialog(
                            arabicText: widget.arabic,
                            englishText: widget.translation,
                            transliterationText: widget.transliteration,
                            reference: widget.header,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= ARABIC =================
            Text(
              widget.arabic,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: arabicSize,
                height: 1.9,
                fontWeight: FontWeight.w500,
              ),
            ),

            // ============ TRANSLITERATION ============
            if (widget.transliteration != null &&
                widget.transliteration!.isNotEmpty &&
                s.showTransliteration) ...[
              const SizedBox(height: 10),
              Text(
                widget.transliteration!,
                style: TextStyle(
                  fontSize: translitSize,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],

            // ============== TRANSLATION ===============
            if (widget.translation != null &&
                widget.translation!.isNotEmpty &&
                s.showTranslation) ...[
              const SizedBox(height: 10),
              Text(
                widget.translation!,
                maxLines: widget.expandable && !expanded ? 4 : null,
                overflow: widget.expandable && !expanded
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
                style: TextStyle(
                  fontSize: translationSize,
                  height: 1.6,
                ),
              ),

              if (widget.expandable)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        setState(() => expanded = !expanded),
                    child: Text(expanded ? 'Show less' : 'Show more'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
