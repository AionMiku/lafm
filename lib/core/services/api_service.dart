import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/surah_model.dart';
import '../../core/services/database_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _dbService = DatabaseService();

  // Quran Cloud Endpoints
  final String _quranBaseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> fetchSurahs() async {
    final response = await http.get(Uri.parse('$_quranBaseUrl/surah'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] as List;
      
      List<Surah> surahs = data.map((s) => Surah(
        number: s['number'],
        nameAr: s['name'],
        nameEn: s['englishName'],
        nameEnMeaning: s['englishNameTranslation'],
        ayahs: s['numberOfAyahs'],
      )).toList();

      await _dbService.insertSurahs(surahs);
      return surahs;
    } else {
      throw Exception('Failed to load Surahs from API');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAyahsForSurah(int surahNumber) async {
    // We request 4 editions: 
    // quran-uthmani -> raw arabic
    // en.transliteration -> transliteration 
    // en.sahih -> english translation
    // ar.alafasy -> audio URLs
    final url = '$_quranBaseUrl/surah/$surahNumber/editions/quran-uthmani,en.transliteration,en.sahih,ar.alafasy';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final editions = json['data'] as List;

      if (editions.isEmpty) return [];

      final arabicEd = editions.firstWhere((e) => e['edition']['identifier'] == 'quran-uthmani')['ayahs'];
      final translitEd = editions.firstWhere((e) => e['edition']['identifier'] == 'en.transliteration')['ayahs'];
      final englishEd = editions.firstWhere((e) => e['edition']['identifier'] == 'en.sahih')['ayahs'];
      final audioEd = editions.firstWhere((e) => e['edition']['identifier'] == 'ar.alafasy')['ayahs'];

      List<Map<String, dynamic>> combinedAyahs = [];
      
      for (int i = 0; i < arabicEd.length; i++) {
        combinedAyahs.add({
          'ayah_number': arabicEd[i]['numberInSurah'],
          'arabic': arabicEd[i]['text'],
          'translit': translitEd[i]['text'],
          'english': englishEd[i]['text'],
          'audio': audioEd[i]['audio'],
        });
      }

      await _dbService.insertAyahs(surahNumber, combinedAyahs);
      return combinedAyahs;
    } else {
      throw Exception('Failed to load Ayahs from API for surah $surahNumber');
    }
  }

  // --- Asma Ul Husna ---
  
  Future<List<Map<String, dynamic>>> fetchAsmaUlHusna() async {
    // Free Aladhan API for Asma Ul Husna
    final response = await http.get(Uri.parse('http://api.aladhan.com/v1/asmaAlHusna'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      
      List<Map<String, dynamic>> results = data.map((e) => {
        'id': e['number'],
        'name_ar': e['name'],
        'name_en': e['transliteration'],
        'meaning': e['en']['meaning'],
      }).toList();

      await _dbService.insertAsma(results);
      return results;
    } else {
      throw Exception('Failed to load Asma Ul Husna');
    }
  }
}
