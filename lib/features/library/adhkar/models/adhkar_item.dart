class AdhkarItem {
  final int id;
  final String title;
  final String content;
  final String contentHtml;

  AdhkarItem({
    required this.id,
    required this.title,
    required this.content,
    required this.contentHtml,
  });

  static String _cleanBrackets(String text) {
    if (text.isEmpty) return text;
    String clean = text.replaceAll('\u200F', '').replaceAll('\u200E', '').trim();
    
    // Remove brackets from the start
    clean = clean.replaceAll(RegExp(r'^[()[\]{}«»\x22\x27\s]+'), '');
    // Remove brackets from the end, even if followed by punctuation
    clean = clean.replaceAll(RegExp(r'[()[\]{}«»\x22\x27\s]+(?=[.,،;!?]*$)'), '');
    
    return clean.trim();
  }

  factory AdhkarItem.fromMap(Map<String, dynamic> map) {
    return AdhkarItem(
      id: map['id'] ?? 0,
      title: _cleanBrackets(map['title']?.toString() ?? ''),
      content: _cleanBrackets(map['content']?.toString() ?? ''),
      contentHtml: map['content_html']?.toString() ?? '',
    );
  }
}
