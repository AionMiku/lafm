enum SearchResultType { surah, ayah }

class QuranSearchResult {
  final SearchResultType type;
  final int surah;
  final int? ayah;
  final String preview;

  QuranSearchResult({
    required this.type,
    required this.surah,
    this.ayah,
    required this.preview,
  });
}
