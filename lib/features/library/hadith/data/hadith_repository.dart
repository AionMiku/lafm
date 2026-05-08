import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../hadith_models.dart';
import 'hadith_books_config.dart';
import 'hadith_download_manager.dart';
import '../../../../core/services/database_service.dart';

class HadithRepository {
  /// Ensures the hadith book is downloaded and parsed into the ultra-fast SQLite DB.
  static Future<void> _ensureBookLoaded(String bookId) async {
    final dbService = DatabaseService();
    if (await dbService.hasHadithBook(bookId)) return; // Already super-cached in DB

    // It's not in DB. Check if we have the massive JSON downloaded
    String? cachedJson = await HadithDownloadManager.loadCachedBookString(bookId);
    
    if (cachedJson == null || cachedJson.isEmpty) {
      debugPrint('Downloading Hadith book: $bookId...');
      await HadithDownloadManager.downloadBook(bookId);
      cachedJson = await HadithDownloadManager.loadCachedBookString(bookId);
    }
    
    if (cachedJson != null && cachedJson.isNotEmpty) {
      // Offload massive JSON parsing to a background thread to prevent UI freezing!
      final data = await compute(jsonDecode, cachedJson) as Map<String, dynamic>;
      
      // Blast into SQLite for instant querying
      await dbService.insertHadithBookData(
        bookId, 
        data['metadata'], 
        data['chapters'], 
        data['hadiths']
      );
      
      // Destroy the gigantic raw JSON payload to free up permanent device storage!
      await HadithDownloadManager.deleteBookCache(bookId);
    } else {
      throw Exception("Failed to load hadith book $bookId from API");
    }
  }
  
  /// Returns list of available hadith books from config
  static List<String> getAvailableBookIds() {
    return hadithBooksConfig.map((b) => b.id).toList();
  }

  /// Remove invisible Unicode junk that breaks layout & search
  static String _cleanText(String text) {
    return text
        .replaceAll('\u200F', '')
        .replaceAll('\u200E', '')
        .trim();
  }

  /// Get book metadata directly from DB
  static Future<HadithBook> loadBookInfo(String bookId) async {
    await _ensureBookLoaded(bookId);
    final dbInfo = await DatabaseService().getHadithBook(bookId);
    if (dbInfo == null) throw Exception("Failed to find metadata in DB");

    return HadithBook(
      id: bookId,
      titleArabic: dbInfo['titleArabic'].toString(),
      titleEnglish: dbInfo['titleEnglish'].toString(),
      author: dbInfo['author'].toString(),
      totalHadith: (dbInfo['totalHadith'] as num).toInt(),
      isDownloaded: true,
    );
  }

  /// Get chapters list from DB
  static Future<List<HadithChapter>> loadChapters(String bookId) async {
    await _ensureBookLoaded(bookId);
    final chapters = await DatabaseService().getHadithChapters(bookId);

    return chapters.map((c) {
      return HadithChapter(
        id: (c['id'] as num).toInt(),
        arabic: _cleanText(c['arabic'].toString()),
        english: _cleanText(c['english'].toString()),
      );
    }).toList();
  }

  /// Get all hadiths instantly from DB
  static Future<List<Hadith>> loadHadiths(String bookId) async {
    await _ensureBookLoaded(bookId);
    final hadiths = await DatabaseService().getHadiths(bookId);

    return hadiths.map((h) {
      return Hadith(
        id: (h['id'] as num).toInt(),
        numberInBook: (h['numberInBook'] as num).toInt(),
        chapterId: (h['chapterId'] as num).toInt(),
        arabic: _cleanText(h['arabic'].toString()),
        narrator: _cleanText(h['narrator'].toString()),
        englishText: _cleanText(h['english'].toString()),
      );
    }).toList();
  }
}
