import 'api_service.dart';
import 'database_service.dart';
import '../../data/models/surah_model.dart';

class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  final _dbService = DatabaseService();
  final _apiService = ApiService();

  final List<Surah> _surahs = [];
  bool _surahsLoaded = false;

  Future<void> loadSurahs() async {
    if (_surahsLoaded) return;
    try {
      // 1. Try DB
      var localSurahs = await _dbService.getSurahs();
      if (localSurahs.isNotEmpty) {
        _surahs.clear();
        _surahs.addAll(localSurahs);
        _surahsLoaded = true;
        return;
      }
      
      // 2. Fetch API
      var apiSurahs = await _apiService.fetchSurahs();
      _surahs.clear();
      _surahs.addAll(apiSurahs);
      _surahsLoaded = true;
    } catch (e) {
      print("Error loading Surahs: \$e");
    }
  }

  List<Surah> get surahs => _surahs;

  /* =========================
   * LOAD AYAH DATA
   * ========================= */

  // This replaces loadArabic, loadTransliteration, loadEnglish
  Future<void> loadAyahsForSurah(int surahNumber) async {
    bool hasLocal = await _dbService.hasAyahsForSurah(surahNumber);
    if (!hasLocal) {
      // Need to fetch and sync from API
      await _apiService.fetchAyahsForSurah(surahNumber);
    }
  }

  /* =========================
   * SURAH → AYAH
   * ========================= */

  Future<List<Map<String, dynamic>>> getSurahAyahs(int surah) async {
    await loadAyahsForSurah(surah);
    final ayahs = await _dbService.getAyahsForSurah(surah);
    return ayahs;
  }
}
