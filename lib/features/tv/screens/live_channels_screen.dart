import 'package:flutter/material.dart';
import '../widgets/live_channel_card.dart';
import '../models/media_item.dart';

class LiveChannelsScreen extends StatelessWidget {
  const LiveChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final channels = [
      MediaItem(
        title: "Makkah Live",
        subtitle: "Masjid Al Haram",
        thumbnail: "https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?q=80&w=600&auto=format&fit=crop",
        type: MediaType.live,
        url: "8H_ZlY_H9H0", // Haramain Info Makkah Live
      ),
      MediaItem(
        title: "Madinah Live",
        subtitle: "Masjid An Nabawi",
        thumbnail: "https://images.unsplash.com/photo-1591604129935-1153308ce7a8?q=80&w=600&auto=format&fit=crop",
        type: MediaType.live,
        url: "YvPqQh-Uiyc", // Haramain Info Madinah Live
      ),
      MediaItem(
        title: "Quran TV",
        subtitle: "Quran Broadcast",
        thumbnail: "https://images.unsplash.com/photo-1606122017369-d78222896d8e?q=80&w=600&auto=format&fit=crop",
        type: MediaType.live,
        url: "tJkE303JgWk",
      ),
      MediaItem(
        title: "Eman Channel",
        subtitle: "Islamic Channel",
        thumbnail: "https://images.unsplash.com/photo-1574246604907-dbbc562be64d?q=80&w=600&auto=format&fit=crop",
        type: MediaType.live,
        url: "zT16W2yL3N4",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Channels"),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: channels.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          return LiveChannelCard(
            channel: channels[index],
          );
        },
      ),
    );
  }
}