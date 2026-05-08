import 'package:flutter/material.dart';

class AdvertisementPlaceholder extends StatelessWidget {
  const AdvertisementPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.campaign_outlined, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Advertisement Space',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Your ad could be here!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
