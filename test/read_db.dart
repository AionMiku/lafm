import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

void main() {
  final dbPath = 'adhkar.db';
  print('Reading Schema from: $dbPath');

  try {
    final db = sqlite3.open(dbPath);
    final ResultSet result = db.select("SELECT name, sql FROM sqlite_master WHERE type='table';");

    for (final Row row in result) {
      print('Table: ${row['name']}');
      print('Schema: ${row['sql']}');
      print('-------------------------');
    }

    db.dispose();
  } catch (e) {
    print('Failed to open database: $e');
  }
}
