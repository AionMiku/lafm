import 'package:flutter/material.dart';
import '../hadith_models.dart';

class HadithBookCard extends StatelessWidget {
  final HadithBook book;
  final VoidCallback onTap;

  const HadithBookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Inherit elevation and shape from AppTheme
      child: InkWell(
        borderRadius: BorderRadius.circular(20), // Match AppTheme card border radius
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                book.titleEnglish,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${book.totalHadith} hadiths',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7) ??
                      Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
