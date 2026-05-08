import 'package:flutter/material.dart';
import '../../map/screens/qibla_map_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QiblaMapScreen()),
              );
            },
            child: Row(
              children: const [
                Icon(Icons.location_on, size: 18),
                SizedBox(width: 4),
                Text(
                  'Hyderabad',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const Text(
            'lafm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
