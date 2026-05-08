import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class HadithDownloadManager {
  // Use GitHub Raw URL for the Hadith JSON files (must be public)
  static const String _apiBaseUrl = 'https://raw.githubusercontent.com/AionMiku/lafm_v1/main/assets/hadith/raw/';

  /// Checks if a specific Hadith book is completely downloaded and available offline.
  static Future<bool> isBookDownloaded(String bookId) async {
    try {
      final file = await _getLocalFile(bookId);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Initiates a fetch from the remote API and writes it to permanent local device storage.
  /// Throws an exception if the network fails.
  static Future<void> downloadBook(String bookId) async {
    final file = await _getLocalFile(bookId);

    // Fetch from reliable secure API
    final response = await http.get(Uri.parse('$_apiBaseUrl$bookId.json')).timeout(
      const Duration(seconds: 45), // Hadith JSONs are large (5-15MB)
    );

    if (response.statusCode == 200) {
      // Validate JSON formatting before saving
      try {
        jsonDecode(utf8.decode(response.bodyBytes)); // Ensure it's not corrupted
        await file.writeAsBytes(response.bodyBytes, flush: true);
      } catch (e) {
        throw Exception("Downloaded database is corrupted.");
      }
    } else {
      throw Exception("Failed to download database from server. Error ${response.statusCode}");
    }
  }

  /// Returns the absolute system path to the cached JSON file.
  static Future<File> _getLocalFile(String bookId) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/hadith_${bookId}_v2.json');
  }

  /// Provide the cached string payload for the repository to instantly parse
  static Future<String?> loadCachedBookString(String bookId) async {
    try {
      final file = await _getLocalFile(bookId);
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (e) {
      debugPrint("Read cache error: $e");
    }
    return null;
  }
  
  /// Utility to delete a downloaded book if the user needs to free up space
  static Future<void> deleteBookCache(String bookId) async {
    try {
      final file = await _getLocalFile(bookId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Delete cache error: $e");
    }
  }
}
