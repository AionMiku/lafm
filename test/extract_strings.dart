import 'dart:io';

void main() {
  final file = File('adhkar.db');
  final bytes = file.readAsBytesSync();
  final buffer = StringBuffer();
  for (var i = 0; i < bytes.length; i++) {
    var c = bytes[i];
    if ((c >= 32 && c <= 126) || c == 10 || c == 13) {
      buffer.writeCharCode(c);
    } else {
      if (buffer.length > 8) {
        final str = buffer.toString();
        if (str.toUpperCase().contains('CREATE TABLE') && str.length > 20) {
          print('--- SCHEMA ---');
          print(str);
        }
      }
      buffer.clear();
    }
  }
}
