import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../adhkar/models/adhkar_item.dart';

import 'package:flutter/services.dart';

class AdhkarRepository {
  static const String _dbName = 'adhkar.db';

  Database? _db;

  /// Public method used by UI
  Future<List<AdhkarItem>> loadAdhkar() async {
  final db = await _openDb();

  final rows = await db.query('article');

  debugPrint('🔥 loadAdhkar called');
  debugPrint('🔥 adhkar rows count: ${rows.length}');
  debugPrint(rows.first.keys.toString());


  return rows.map((e) => AdhkarItem.fromMap(e)).toList();
}

  /// Opens DB (copies from assets once)
  Future<Database> _openDb() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final exists = await databaseExists(path);

    if (!exists) {
      debugPrint('Downloading online Adhkar DB...');
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/AionMiku/lafm_v1/main/adhkar.db'));
        if (response.statusCode == 200) {
          await File(path).writeAsBytes(response.bodyBytes, flush: true);
        } else {
          throw Exception('Failed to download Adhkar DB from API');
        }
      } catch (e) {
        debugPrint('Failed Adhkar API: $e');
        rethrow;
      }
    }

    _db = await openDatabase(path, readOnly: true);
    return _db!;
  }
}
