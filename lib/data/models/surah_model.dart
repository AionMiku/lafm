class Surah {
  final int number;
  final String nameAr;
  final String nameEn;
  final String? nameEnMeaning;
  final int ayahs;

  Surah({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    this.nameEnMeaning,
    required this.ayahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      nameEnMeaning: json['name_en_meaning'],
      ayahs: json['ayahs'],
    );
  }
}
