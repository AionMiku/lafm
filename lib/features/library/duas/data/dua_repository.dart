import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/dua_models.dart';
import 'package:flutter/foundation.dart';
class DuaRepository {
  static const String _duapiUrl = 'https://raw.githubusercontent.com/AionMiku/lafm_v1/main/hisnulMuslim.json';

  static String _cleanBrackets(String text) {
    if (text.isEmpty) return text;
    String clean = text.replaceAll('\u200F', '').replaceAll('\u200E', '').trim();
    
    // Remove brackets from the start
    clean = clean.replaceAll(RegExp(r'^[()[\]{}«»\x22\x27\s]+'), '');
    // Remove brackets from the end, even if followed by punctuation
    clean = clean.replaceAll(RegExp(r'[()[\]{}«»\x22\x27\s]+(?=[.,،;!?]*$)'), '');
    
    return clean.trim();
  }

  /// DUAS (Hisnul Muslim)
  static Future<List<DuaCategory>> loadDuaCategories() async {
    final file = File(join((await getApplicationDocumentsDirectory()).path, 'hisnul_muslim_v2.json'));
    String jsonString;
    if (await file.exists()) {
      jsonString = await file.readAsString();
    } else {
      debugPrint('Downloading online hisnulMuslim.json...');
      final response = await http.get(Uri.parse(_duapiUrl));
      if (response.statusCode == 200) {
        jsonString = utf8.decode(response.bodyBytes);
        await file.writeAsString(jsonString, flush: true);
      } else {
        throw Exception('Failed to download Duas');
      }
    }

    final raw = jsonDecode(jsonString);
    final List categoriesJson = raw['English'];

    return categoriesJson.map((c) {
      return DuaCategory(
        id: c['ID'],
        titleEnglish: c['TITLE'],
        titleUrdu: c['TITLE_UR'],
        titleUrduRoman: c['TITLE_UR_ROMAN'],
        audioUrl: c['AUDIO_URL'] ?? '',
        duas: (c['TEXT'] as List).map((d) {
          return DuaItem(
            id: d['ID'],
            arabic: _cleanBrackets(d['ARABIC_TEXT']?.toString() ?? ''),
            transliteration: _cleanBrackets(d['LANGUAGE_ARABIC_TRANSLATED_TEXT']?.toString() ?? ''),
            translationEnglish: _cleanBrackets(d['TRANSLATED_TEXT']?.toString() ?? ''),
            translationUrdu: _cleanBrackets(d['TRANSLATED_TEXT_UR']?.toString() ?? ''),
            translationUrduRoman: _cleanBrackets(d['TRANSLATED_TEXT_UR_ROMAN']?.toString() ?? ''),
            repeat: d['REPEAT'] ?? 1,
            audioUrl: d['AUDIO'] ?? '',
          );
        }).toList(),
      );
    }).toList();
  }

  /// ADHKAR (Parsed directly from bundled SQLite)
  static Future<List<DuaCategory>> loadAdhkarCategories() async {
    final dbPath = join(await getDatabasesPath(), 'adhkar.db');
    final exists = await databaseExists(dbPath);
    if (!exists) {
      debugPrint('Downloading online Adhkar DB...');
      final response = await http.get(Uri.parse('https://raw.githubusercontent.com/AionMiku/lafm_v1/main/adhkar.db'));
      if (response.statusCode == 200) {
        await File(dbPath).writeAsBytes(response.bodyBytes, flush: true);
      } else {
        throw Exception('Failed to download Adhkar DB');
      }
    }

    final db = await openDatabase(dbPath, readOnly: true);
    final categories = await db.query('category', orderBy: 'position');
    
    List<DuaCategory> result = [];
    for (var c in categories) {
      final resources = await db.query('resource', where: 'category = ?', whereArgs: [c['id']], orderBy: 'position');
      result.add(DuaCategory(
        id: c['id'] as int,
        titleEnglish: c['title']?.toString() ?? '',
        titleUrdu: c['title']?.toString() ?? '', // Adhkar.db might not have urdu mapped directly.
        titleUrduRoman: '',
        audioUrl: '',
        duas: resources.map((r) {
          return DuaItem(
            id: r['id'] as int,
            arabic: _cleanBrackets(r['text']?.toString() ?? ''),
            transliteration: _cleanBrackets(r['transliteration']?.toString() ?? ''),
            translationEnglish: _cleanBrackets(r['pronunciation']?.toString() ?? ''), // We use pronunciation here if translation isn't available
            translationUrdu: '',
            translationUrduRoman: '',
            repeat: 1, // 'count' isn't explicitly known to be what type in resource, default to 1.
            audioUrl: r['audio_url']?.toString() ?? '',
          );
        }).toList(),
      ));
    }
    await db.close();
    return result;
  }
}
