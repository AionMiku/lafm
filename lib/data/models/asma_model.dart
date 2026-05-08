class AsmaName {
  final int number;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String description;

  AsmaName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.description,
  });

  factory AsmaName.fromJson(Map<String, dynamic> json) {
    return AsmaName(
      number: json['number'],
      arabic: json['arabic'],
      transliteration: json['transliteration'],
      meaning: json['meaning'],
      description: json['description'],
    );
  }
}
