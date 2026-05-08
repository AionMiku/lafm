import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extract schema', () {
    final file = File('adhkar.db');
    final bytes = file.readAsBytesSync();
    final buffer = StringBuffer();
    for (var i = 0; i < bytes.length; i++) {
      var c = bytes[i];
      if (c >= 32 && c <= 126) {
        buffer.writeCharCode(c);
      } else {
        if (buffer.length > 8) {
          final str = buffer.toString();
          if (str.toUpperCase().contains('CREATE TABLE')) {
            print('Found Schema: $str');
          }
        }
        buffer.clear();
      }
    }
  });
}
