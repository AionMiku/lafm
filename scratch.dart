void main() {
  String test1 = "((This is a test)).";
  String test2 = "«Another test»،";
  String test3 = "[Test with internal (brackets) ok]!";
  String test4 = "{Arabic test))";
  
  String _clean(String text) {
    if (text.isEmpty) return text;
    String clean = text.trim();
    clean = clean.replaceAll(RegExp(r'^[\(\)\[\]\{\}«»\"\'\s]+'), '');
    clean = clean.replaceAll(RegExp(r'[\(\)\[\]\{\}«»\"\'\s]+(?=[.,،;!?]*$)'), '');
    return clean;
  }

  print("1: ${_clean(test1)}");
  print("2: ${_clean(test2)}");
  print("3: ${_clean(test3)}");
  print("4: ${_clean(test4)}");
}
