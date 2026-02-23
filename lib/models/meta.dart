class SurahMetadata {
  final int number;
  final String nameEn;
  final String nameAr;
  final int ayahCount;
  final String? revelationType;

  const SurahMetadata({
    required this.number,
    required this.nameEn,
    required this.nameAr,
    required this.ayahCount,
    this.revelationType,
  });

  /// Whether this surah was revealed in Makkah.
  bool get isMeccan => revelationType?.toLowerCase() == 'meccan';

  /// Whether this surah was revealed in Madinah.
  bool get isMedinan => revelationType?.toLowerCase() == 'medinan';

  @override
  String toString() =>
      'SurahMetadata($number: $nameEn / $nameAr, $ayahCount ayat)';
}
