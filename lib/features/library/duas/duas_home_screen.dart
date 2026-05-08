import 'package:flutter/material.dart';
import '../duas/data/dua_repository.dart';
import '../duas/models/dua_models.dart';
import '../duas/ui/duas_list_screen.dart';

class DuaHomeScreen extends StatelessWidget {
  const DuaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duas'),
      ),
      body: FutureBuilder<List<DuaCategory>>(
        future: DuaRepository.loadDuaCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No duas found'));
          }

          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.4, // Matches the rectangular shape in the photo
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final aesthetics = _getAesthetics(category.titleEnglish);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DuaListScreen(category: category),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: aesthetics['colors'] as List<Color>,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (aesthetics['colors'] as List<Color>)[1].withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Large Decorative Background Icon
                      Positioned(
                        right: -15,
                        bottom: -15,
                        child: Icon(
                          aesthetics['icon'] as IconData,
                          size: 90,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      
                      // Top Right Small Label Icon
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Icon(
                          aesthetics['icon'] as IconData,
                          size: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      
                      // Bottom Left Title perfectly mimicking the screenshot
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.titleEnglish,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper method to assign rich, contextual gradients based on keywords
  Map<String, dynamic> _getAesthetics(String title) {
    title = title.toLowerCase();
    
    if (title.contains('morning')) {
      return {'colors': [Colors.teal.shade300, Colors.teal.shade500], 'icon': Icons.wb_sunny};
    } else if (title.contains('evening')) {
      return {'colors': [Colors.brown.shade300, Colors.brown.shade500], 'icon': Icons.wb_twilight};
    } else if (title.contains('sleep') || title.contains('night')) {
      return {'colors': [const Color(0xFF2C3E50), const Color(0xFF3498DB)], 'icon': Icons.bedtime};
    } else if (title.contains('cloth')) {
      return {'colors': [Colors.green.shade400, Colors.teal.shade700], 'icon': Icons.dry_cleaning};
    } else if (title.contains('lavatory') || title.contains('wudu')) {
      return {'colors': [Colors.indigo.shade300, Colors.indigo.shade500], 'icon': Icons.water_drop};
    } else if (title.contains('salah') || title.contains('prayer') || title.contains('adhan')) {
      return {'colors': [Colors.blueGrey.shade400, Colors.blueGrey.shade700], 'icon': Icons.mosque};
    } else if (title.contains('food') || title.contains('drink') || title.contains('eat')) {
      return {'colors': [Colors.orange.shade300, Colors.deepOrange.shade400], 'icon': Icons.restaurant};
    } else if (title.contains('home') || title.contains('house')) {
      return {'colors': [Colors.red.shade300, Colors.red.shade500], 'icon': Icons.home};
    } else if (title.contains('illness') || title.contains('ruqyah') || title.contains('sick')) {
      return {'colors': [Colors.pink.shade300, Colors.pink.shade600], 'icon': Icons.healing};
    } else if (title.contains('ummah') || title.contains('family')) {
       return {'colors': [Colors.amber.shade400, Colors.orange.shade500], 'icon': Icons.people};
    } else if (title.contains('travel') || title.contains('journey')) {
       return {'colors': [Colors.cyan.shade400, Colors.blue.shade600], 'icon': Icons.flight_takeoff};
    } else {
      return {'colors': [Colors.blue.shade400, Colors.blue.shade800], 'icon': Icons.menu_book};
    }
  }
}
