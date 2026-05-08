import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global_settings_controller.dart';

/// Floating settings panel (Text + Audio)
class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({
    super.key,
    required this.hasArabic,
    required this.hasTranslation,
    required this.hasTransliteration,
  });

  final bool hasArabic;
  final bool hasTranslation;
  final bool hasTransliteration;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GlobalSettingsController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // HEADER
                // =====================
                const Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =====================
                // TEXT SECTION
                // =====================
                Row(
                  children: const [
                    Icon(Icons.text_fields),
                    SizedBox(width: 8),
                    Text(
                      'Text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Master scale
                _SliderRow(
                  label: 'Text Size',
                  value: settings.baseScale,
                  min: 0.8,
                  max: 1.6,
                  onChanged: settings.setBaseScale,
                ),

                if (hasArabic) ...[
                  const SizedBox(height: 12),
                  _SliderRow(
                    label: 'Arabic',
                    value: settings.arabicScale,
                    min: 0.8,
                    max: 1.6,
                    onChanged: settings.setArabicScale,
                  ),
                ],

                if (hasTranslation) ...[
                  const SizedBox(height: 12),
                  _SliderRow(
                    label: 'Translation',
                    value: settings.translationScale,
                    min: 0.8,
                    max: 1.6,
                    onChanged: settings.setTranslationScale,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Translation'),
                    value: settings.showTranslation,
                    onChanged: settings.toggleTranslation,
                  ),
                ],

                if (hasTransliteration) ...[
                  const SizedBox(height: 12),
                  _SliderRow(
                    label: 'Transliteration',
                    value: settings.transliterationScale,
                    min: 0.8,
                    max: 1.6,
                    onChanged: settings.setTransliterationScale,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Transliteration'),
                    value: settings.showTransliteration,
                    onChanged: settings.toggleTransliteration,
                  ),
                ],

                const SizedBox(height: 24),

                // =====================
                // AUDIO (PLACEHOLDER)
                // =====================
                Row(
                  children: const [
                    Icon(Icons.mic),
                    SizedBox(width: 8),
                    Text(
                      'Audio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Audio settings coming soon',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
