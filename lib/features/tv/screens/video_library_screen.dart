import 'package:flutter/material.dart';

class VideoLibraryScreen extends StatelessWidget {
  const VideoLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [

        _VideoPlaceholder(
          title: "Friday Khutbah",
          subtitle: "Latest khutbah videos",
        ),

        _VideoPlaceholder(
          title: "Islamic Lectures",
          subtitle: "Talks by scholars",
        ),

        _VideoPlaceholder(
          title: "Stories of Prophets",
          subtitle: "Educational series",
        ),

      ],
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _VideoPlaceholder({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: const Icon(Icons.play_circle),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}