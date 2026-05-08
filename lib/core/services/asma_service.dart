import '../../data/models/asma_model.dart';
import 'api_service.dart';
import 'database_service.dart';

class AsmaService {
  final _dbService = DatabaseService();
  final _apiService = ApiService();

  Future<List<AsmaName>> loadNames() async {
    // 1. Check local cache
    var localAsma = await _dbService.getAsma();
    
    // 2. If empty, fetch from API
    if (localAsma.isEmpty) {
      try {
        localAsma = await _apiService.fetchAsmaUlHusna();
      } catch (e) {
        print('Error fetching Asma: \$e');
        return [];
      }
    }

    // 3. Map to models
    return localAsma.map((e) => AsmaName(
      number: e['id'] ?? 0,
      arabic: e['name_ar'] ?? '',
      transliteration: e['name_en'] ?? '',
      meaning: e['meaning'] ?? '',
      description: '', // Aladhan API does not provide extended descriptions
    )).toList();
  }
}
