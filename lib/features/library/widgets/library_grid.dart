import 'package:flutter/material.dart';
import '../quran/quran_home_screen.dart';
import '../hadith/hadith_library_screen.dart';
import '../duas/duas_home_screen.dart';
import '../adhkar/adhkar_home_screen.dart';
import '../tasbeeh/screens/tasbeeh_screen.dart';

class LibraryGrid extends StatelessWidget {
  const LibraryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item('Quran', Icons.menu_book),
      _Item('Hadith', Icons.receipt_long),
      _Item('Duas', Icons.shield_outlined),
      _Item('Adhkar', Icons.favorite_border),
      _Item('Tasbeeh', Icons.brightness_3),
      _Item('Stories', Icons.auto_stories),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const rows = 3;
        const cols = 2;

        final rowHeight = (constraints.maxHeight - (spacing * (rows - 1))) / rows;
        final colWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;
        
        // To guarantee no vertical overflow, calculating aspect ratio explicitly
        // A slightly larger aspect ratio means items will be shorter.
        final targetRatio = colWidth / (rowHeight > 0 ? rowHeight : 64);
        final safeRatio = targetRatio + 0.05; // 5% buffer guarantees they never get cut

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: safeRatio > 0 ? safeRatio : 2.5, 
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: EdgeInsets.zero,
              // Inherit AppTheme shape (frosted glass + strokes) 
              child: InkWell(
                borderRadius: BorderRadius.circular(20), // Match AppTheme border radius
                onTap: () {
                  switch (item.title) {
                    case 'Quran':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuranHomeScreen()),
                      );
                      break;
                    case 'Hadith':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HadithLibraryScreen()),
                      );
                      break;
                    case 'Duas':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DuaHomeScreen()),
                      );
                      break;
                    case 'Adhkar':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdhkarHomeScreen()),
                      );
                      break;
                    case 'Tasbeeh':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasbeehScreen()),
                      );
                      break;
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.title} coming soon')),
                      );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon, 
                      size: 20, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }
}

class _Item {
  final String title;
  final IconData icon;

  _Item(this.title, this.icon);
}
