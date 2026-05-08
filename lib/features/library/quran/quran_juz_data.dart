class JuzBoundary {
  final int id;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  const JuzBoundary({
    required this.id,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });
}

// Global mapping of all 30 Juz
const List<JuzBoundary> juzBoundaries = [
  JuzBoundary(id: 1, startSurah: 1, startAyah: 1, endSurah: 2, endAyah: 141),
  JuzBoundary(id: 2, startSurah: 2, startAyah: 142, endSurah: 2, endAyah: 252),
  JuzBoundary(id: 3, startSurah: 2, startAyah: 253, endSurah: 3, endAyah: 92),
  JuzBoundary(id: 4, startSurah: 3, startAyah: 93, endSurah: 4, endAyah: 23),
  JuzBoundary(id: 5, startSurah: 4, startAyah: 24, endSurah: 4, endAyah: 147),
  JuzBoundary(id: 6, startSurah: 4, startAyah: 148, endSurah: 5, endAyah: 81),
  JuzBoundary(id: 7, startSurah: 5, startAyah: 82, endSurah: 6, endAyah: 110),
  JuzBoundary(id: 8, startSurah: 6, startAyah: 111, endSurah: 7, endAyah: 87),
  JuzBoundary(id: 9, startSurah: 7, startAyah: 88, endSurah: 8, endAyah: 40),
  JuzBoundary(id: 10, startSurah: 8, startAyah: 41, endSurah: 9, endAyah: 92),
  JuzBoundary(id: 11, startSurah: 9, startAyah: 93, endSurah: 11, endAyah: 5),
  JuzBoundary(id: 12, startSurah: 11, startAyah: 6, endSurah: 12, endAyah: 52),
  JuzBoundary(id: 13, startSurah: 12, startAyah: 53, endSurah: 14, endAyah: 52),
  JuzBoundary(id: 14, startSurah: 15, startAyah: 1, endSurah: 16, endAyah: 128),
  JuzBoundary(id: 15, startSurah: 17, startAyah: 1, endSurah: 18, endAyah: 74),
  JuzBoundary(id: 16, startSurah: 18, startAyah: 75, endSurah: 20, endAyah: 135),
  JuzBoundary(id: 17, startSurah: 21, startAyah: 1, endSurah: 22, endAyah: 78),
  JuzBoundary(id: 18, startSurah: 23, startAyah: 1, endSurah: 25, endAyah: 20),
  JuzBoundary(id: 19, startSurah: 25, startAyah: 21, endSurah: 27, endAyah: 55),
  JuzBoundary(id: 20, startSurah: 27, startAyah: 56, endSurah: 29, endAyah: 45),
  JuzBoundary(id: 21, startSurah: 29, startAyah: 46, endSurah: 33, endAyah: 30),
  JuzBoundary(id: 22, startSurah: 33, startAyah: 31, endSurah: 36, endAyah: 27),
  JuzBoundary(id: 23, startSurah: 36, startAyah: 28, endSurah: 39, endAyah: 31),
  JuzBoundary(id: 24, startSurah: 39, startAyah: 32, endSurah: 41, endAyah: 46),
  JuzBoundary(id: 25, startSurah: 41, startAyah: 47, endSurah: 45, endAyah: 37),
  JuzBoundary(id: 26, startSurah: 46, startAyah: 1, endSurah: 51, endAyah: 30),
  JuzBoundary(id: 27, startSurah: 51, startAyah: 31, endSurah: 57, endAyah: 29),
  JuzBoundary(id: 28, startSurah: 58, startAyah: 1, endSurah: 66, endAyah: 12),
  JuzBoundary(id: 29, startSurah: 67, startAyah: 1, endSurah: 77, endAyah: 50),
  JuzBoundary(id: 30, startSurah: 78, startAyah: 1, endSurah: 114, endAyah: 6),
];
