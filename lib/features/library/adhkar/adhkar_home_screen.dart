import 'package:flutter/material.dart';
import 'data/adhkar_repository.dart';
import 'models/adhkar_item.dart';
import 'ui/adhkar_detail_screen.dart';

class AdhkarHomeScreen extends StatelessWidget {
  const AdhkarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adhkar'),
      ),
      body: FutureBuilder<List<AdhkarItem>>(
        future: AdhkarRepository().loadAdhkar(),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Empty or error
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No adhkar found'));
          }

          final adhkar = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adhkar.length,
            itemBuilder: (context, index) {
              final item = adhkar[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdhkarDetailScreen(item: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
