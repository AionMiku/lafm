import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/surah_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'lafm_library.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS hadiths');
          await _createTables(db, newVersion);
        }
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE surahs(
        number INTEGER PRIMARY KEY,
        name_ar TEXT,
        name_en TEXT,
        name_en_meaning TEXT,
        ayahs INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ayahs(
        id TEXT PRIMARY KEY,
        surah_number INTEGER,
        ayah_number INTEGER,
        arabic TEXT,
        translit TEXT,
        english TEXT,
        audio TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE asma(
        id INTEGER PRIMARY KEY,
        name_ar TEXT,
        name_en TEXT,
        meaning TEXT
      )
    ''');
    
    // Hadith, Duas, and Adhkar layout to follow...
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadiths(
        id INTEGER PRIMARY KEY,
        book TEXT,
        numberInBook INTEGER,
        chapterId INTEGER,
        arabic TEXT,
        narrator TEXT,
        english TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_chapters(
        id INTEGER,
        book TEXT,
        arabic TEXT,
        english TEXT,
        PRIMARY KEY (id, book)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hadith_books(
        id TEXT PRIMARY KEY,
        titleArabic TEXT,
        titleEnglish TEXT,
        author TEXT,
        totalHadith INTEGER
      )
    ''');
  }

  /* =========== SURAH DATA =========== */

  Future<void> insertSurahs(List<Surah> surahs) async {
    final db = await database;
    Batch batch = db.batch();
    for (var surah in surahs) {
      batch.insert(
        'surahs',
        {
          'number': surah.number,
          'name_ar': surah.nameAr,
          'name_en': surah.nameEn,
          'name_en_meaning': surah.nameEnMeaning,
          'ayahs': surah.ayahs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Surah>> getSurahs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('surahs', orderBy: 'number');
    
    return List.generate(maps.length, (i) {
      return Surah(
        number: maps[i]['number'],
        nameAr: maps[i]['name_ar'],
        nameEn: maps[i]['name_en'],
        nameEnMeaning: maps[i]['name_en_meaning'],
        ayahs: maps[i]['ayahs'],
      );
    });
  }

  /* =========== AYAH DATA =========== */
  
  Future<void> insertAyahs(int surahNumber, List<Map<String, dynamic>> ayahs) async {
    final db = await database;
    Batch batch = db.batch();
    for (var a in ayahs) {
      batch.insert(
        'ayahs',
        {
          'id': "${surahNumber}_${a['ayah_number']}",
          'surah_number': surahNumber,
          'ayah_number': a['ayah_number'],
          'arabic': a['arabic'],
          'translit': a['translit'],
          'english': a['english'],
          'audio': a['audio']
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAyahsForSurah(int surahNumber) async {
    final db = await database;
    return await db.query(
      'ayahs',
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah_number'
    );
  }

  Future<bool> hasAyahsForSurah(int surahNumber) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ayahs WHERE surah_number = ?', [surahNumber]));
    return (count ?? 0) > 0;
  }

  /* =========== ASMA DATA =========== */

  Future<void> insertAsma(List<Map<String, dynamic>> asmaList) async {
    final db = await database;
    Batch batch = db.batch();
    for (var a in asmaList) {
      batch.insert(
        'asma',
        a,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getAsma() async {
    final db = await database;
    return await db.query('asma', orderBy: 'id');
  }

  /* =========== HADITH DATA =========== */

  Future<void> insertHadithBookData(String bookId, Map<String, dynamic> metadata, List chapters, List hadiths) async {
    final db = await database;
    Batch batch = db.batch();
    
    // Insert Book Metadata
    batch.insert('hadith_books', {
      'id': bookId,
      'titleArabic': metadata['arabic']['title'],
      'titleEnglish': metadata['english']['title'],
      'author': metadata['english']['author'],
      'totalHadith': metadata['length'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Insert Chapters
    for (var c in chapters) {
      batch.insert('hadith_chapters', {
        'id': c['id'],
        'book': bookId,
        'arabic': c['arabic'] ?? '',
        'english': c['english'] ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Insert Hadiths
    for (var h in hadiths) {
      batch.insert('hadiths', {
        'id': h['id'],
        'book': bookId,
        'numberInBook': h['idInBook'],
        'chapterId': h['chapterId'],
        'arabic': h['arabic'] ?? '',
        'narrator': h['english']['narrator'] ?? '',
        'english': h['english']['text'] ?? '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>?> getHadithBook(String bookId) async {
    final db = await database;
    final res = await db.query('hadith_books', where: 'id = ?', whereArgs: [bookId]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getHadithChapters(String bookId) async {
    final db = await database;
    return await db.query('hadith_chapters', where: 'book = ?', whereArgs: [bookId], orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getHadiths(String bookId) async {
    final db = await database;
    return await db.query('hadiths', where: 'book = ?', whereArgs: [bookId], orderBy: 'id');
  }

  Future<bool> hasHadithBook(String bookId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM hadiths WHERE book = ?', [bookId]));
    return (count ?? 0) > 0;
  }
}
