import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../screens/youtube_live_player_screen.dart';

class LiveChannelCard extends StatelessWidget {
  final MediaItem channel;

  const LiveChannelCard({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (channel.url != null && channel.url!.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YoutubeLivePlayerScreen(
                videoId: channel.url!,
                title: channel.title,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Stream currently unavailable.")),
          );
        }
      },
      child: Container(
        width: 220,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      child: Stack(
        children: [

          /// CHANNEL IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                channel.thumbnail,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          /// DARK OVERLAY
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ),

          /// CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tv,
                  size: 40,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                Text(
                  channel.title,
                  style: TextStyle( // Removed const because Theme.of(context) is not a constant
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}