/// Represents a hadith book (e.g. Sahih Bukhari, Sahih Muslim)
class HadithBook {
  /// Internal ID used to match asset filename
  /// example: bukhari, muslim, tirmidhi
  final String id;

  /// Arabic title of the book
  final String titleArabic;

  /// English title of the book
  final String titleEnglish;

  /// Author name (English)
  final String author;

  /// Total hadith count in this book
  final int totalHadith;

  /// Whether this book is downloaded locally
  /// (for now default = false, later we persist it)
  final bool isDownloaded;

  HadithBook({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.author,
    required this.totalHadith,
    this.isDownloaded = false,
  });
}

/// Represents a chapter inside a hadith book
class HadithChapter {
  final int id;
  final String arabic;
  final String english;

  HadithChapter({
    required this.id,
    required this.arabic,
    required this.english,
  });
}

/// Represents a single hadith
class Hadith {
  final int id;
  final int numberInBook; // idInBook from JSON
  final int chapterId;

  final String arabic;
  final String narrator;
  final String englishText;

  Hadith({
    required this.id,
    required this.numberInBook,
    required this.chapterId,
    required this.arabic,
    required this.narrator,
    required this.englishText,
  });
}
