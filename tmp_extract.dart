import 'dart:convert';
import 'dart:io';

void main() {
  final files = Directory('assets/hadith/raw').listSync().whereType<File>();
  print('final List<HadithBook> hadithBooksConfig = [');
  for (final file in files) {
    if (!file.path.endsWith('.json')) continue;
    final jsonStr = file.readAsStringSync();
    final data = jsonDecode(jsonStr);
    final id = data['metadata']['id'] ?? file.path.split(Platform.pathSeparator).last.split('.').first;
    final meta = data['metadata'];
    print('''  HadithBook(
    id: '${id}',
    titleArabic: '${meta['arabic']['title'].replaceAll("'", "\\'")}',
    titleEnglish: '${meta['english']['title'].replaceAll("'", "\\'")}',
    author: '${meta['english']['author'].replaceAll("'", "\\'")}',
    totalHadith: ${meta['length']},
  ),''');
  }
  print('];');
}
