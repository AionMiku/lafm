import 'package:flutter/material.dart';
import 'widgets/dua_of_the_day_card.dart';
import 'widgets/asma_ul_husna_card.dart';
import 'widgets/library_grid.dart';



class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Universal Search Bar (Pill)
            Hero(
              tag: 'universal_search',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // TODO: Implement contextual library search
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Search Quran, Hadith, Duas...',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Dua of the Day (Shrunk size to ~35 flex)
            Expanded(
              flex: 35,
              child: const DuaOfDayCard(),
            ),

            const SizedBox(height: 10),

            // 🔹 Compact Asma ul Husna (fixed height)
            const AsmaUlHusnaCard(),

            const SizedBox(height: 10),

            // 🔹 Grid (2 × 3) - reduced heights
            Expanded(
              flex: 30,
              child: LibraryGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
