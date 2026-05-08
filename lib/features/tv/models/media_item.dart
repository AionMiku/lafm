enum MediaType {
  live,
  video,
  audio,
  reel,
}

class MediaItem {
  final String title;
  final String? subtitle;
  final String thumbnail;
  final MediaType type;
  final String? url;

  MediaItem({
    required this.title,
    this.subtitle,
    required this.thumbnail,
    required this.type,
    this.url,
  });
}