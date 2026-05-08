

class DuaCategory {
  final int id;

  /// Category titles
  final String titleEnglish;
  final String titleUrdu;
  final String titleUrduRoman;

  /// Optional category-level audio
  final String audioUrl;

  /// All duas inside this category
  final List<DuaItem> duas;

  const DuaCategory({
    required this.id,
    required this.titleEnglish,
    required this.titleUrdu,
    required this.titleUrduRoman,
    required this.audioUrl,
    required this.duas,
  });
}

class DuaItem {
  final int id;

  final String arabic;
  final String transliteration;

  final String translationEnglish;
  final String translationUrdu;
  final String translationUrduRoman;

  final int repeat;
  final String audioUrl;

  const DuaItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translationEnglish,
    required this.translationUrdu,
    required this.translationUrduRoman,
    required this.repeat,
    required this.audioUrl,
  });
}
