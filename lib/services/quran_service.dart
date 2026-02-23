import '../models/language.dart';
import '../models/meta.dart';
import '../models/surah.dart';
import '../data/meta/surah_metadata_list.dart';
import '../data/meta/sajda_keys.dart';
import '../data/navigation/navigation_index.dart';
import '../data/search/arabic_search.dart';
import '../data/search/english_search.dart';
import '../data/quran/arabic/quran_data_index.dart' as quran_ar;
import '../data/quran/english/quran_data_index.dart' as quran_en;
import '../data/tafsir/arabic/tafsir_data_index.dart' as tafsir_ar;
import '../data/rub/rub_boundaries.dart';
import '../data/rub/rub_index_map.dart';

class QuranService {
  static QuranService? _instance;
  static QuranService get instance => _instance ??= QuranService._();

  final Map<String, List<Map<String, dynamic>>> _searchIndexByLanguage = {};

  QuranService._();

  // --- Navigation Methods ---

  /// Get all ayahs on a specific page (1-604).
  List<Ayah> getPage(
    int pageNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final segments = pageIndex[pageNumber];
    if (segments == null) return [];
    final result = <Ayah>[];
    for (final segment in segments) {
      final surahId = segment['surah']!;
      final start = segment['start']!;
      final end = segment['end']!;
      final surah = getSurah(surahId, language: language);
      result.addAll(surah.verses.where((v) => v.id >= start && v.id <= end));
    }
    return result;
  }

  /// Alias for [getPage].
  List<Ayah> getVersesByPage(
    int pageNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) =>
      getPage(pageNumber, language: language);

  /// Get all ayahs in a specific Juz (1-30).
  List<Ayah> getJuz(
    int juzNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final segments = juzIndex[juzNumber];
    if (segments == null) return [];
    final result = <Ayah>[];
    for (final segment in segments) {
      final surahId = segment['surah']!;
      final start = segment['start']!;
      final end = segment['end']!;
      final surah = getSurah(surahId, language: language);
      result.addAll(surah.verses.where((v) => v.id >= start && v.id <= end));
    }
    return result;
  }

  /// Get metadata for all 114 surahs.
  List<SurahMetadata> getAllSurahs() => allSurahMetadata;

  /// Get metadata for a specific surah.
  SurahMetadata getSurahMetadata(int surahNumber) {
    // allSurahMetadata is ordered 1-114, so direct index is O(1).
    return allSurahMetadata[surahNumber - 1];
  }

  /// Get the English name of a surah.
  String getSurahNameEnglish(int surahNumber) =>
      getSurahMetadata(surahNumber).nameEn;

  /// Get the Arabic name of a surah.
  String getSurahNameArabic(int surahNumber) =>
      getSurahMetadata(surahNumber).nameAr;

  /// Get the ayah count for a surah.
  int getVerseCount(int surahNumber) => getSurahMetadata(surahNumber).ayahCount;

  /// Get the place of revelation for a surah ("Meccan" or "Medinan").
  String? getPlaceOfRevelation(int surahNumber) =>
      getSurahMetadata(surahNumber).revelationType;

  /// Get a full surah.
  Surah getSurah(
    int surahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final data = _quranDataForLanguage(language)[surahNumber];
    if (data == null) {
      throw Exception('Surah $surahNumber not found for ${language.code}.');
    }
    return _annotateSurah(Surah.fromJson(data), surahNumber);
  }

  /// Get the tafsir for a surah (Arabic only; returns empty map for English).
  Map<int, String> getTafsir(
    int surahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final data = _tafsirDataForLanguage(language)[surahNumber];
    if (data == null) return {};
    return _parseTafsirFromMap(data);
  }

  /// Get all ayahs for a surah.
  List<Ayah> getVersesBySurah(
    int surahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) =>
      getSurah(surahNumber, language: language).verses;

  /// Generate an audio URL for a specific ayah and reciter.
  String getAudioUrl(int surah, int ayah, {String? reciterIdentifier}) {
    final reciter = reciterIdentifier ?? 'Alafasy_128kbps';
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$reciter/$s$a.mp3';
  }

  /// Get a single ayah.
  Ayah getAyah(
    int surahNumber,
    int ayahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final surah = getSurah(surahNumber, language: language);
    return surah.verses.firstWhere(
      (v) => v.id == ayahNumber,
      orElse: () =>
          throw Exception('Ayah $ayahNumber not found in Surah $surahNumber'),
    );
  }

  /// Synchronous full-text search with Arabic/English normalization.
  List<Ayah> search(
    String query, {
    int limit = 50,
    QuranLanguage language = QuranLanguage.arabic,
  }) {
    final normalizedQuery = language == QuranLanguage.english
        ? _normalizeEnglish(query)
        : _normalizeArabic(query);
    if (normalizedQuery.isEmpty) return [];

    final languageKey = language.code;
    if (!_searchIndexByLanguage.containsKey(languageKey)) {
      _searchIndexByLanguage[languageKey] =
          List<Map<String, dynamic>>.from(_searchDataForLanguage(language));
    }

    final index = _searchIndexByLanguage[languageKey]!;
    final matches = index
        .where((item) => (item['t'] as String).contains(normalizedQuery))
        .take(limit);

    // Group matches by surah to avoid re-parsing the same surah multiple times.
    final bySurah = <int, List<int>>{};
    for (final m in matches) {
      bySurah.putIfAbsent(m['s'] as int, () => []).add(m['a'] as int);
    }

    final results = <Ayah>[];
    for (final entry in bySurah.entries) {
      final surah = getSurah(entry.key, language: language);
      for (final id in entry.value) {
        results.add(surah.verses.firstWhere((v) => v.id == id));
      }
    }
    return results;
  }

  /// Async wrapper around [search] — useful in UI contexts.
  Future<List<Ayah>> searchAsync(
    String query, {
    int limit = 50,
    QuranLanguage language = QuranLanguage.arabic,
  }) async =>
      search(query, limit: limit, language: language);

  /// Whether a given ayah is a sajda location.
  bool isSajda(int surahNumber, int ayahNumber) =>
      sajdaKeys.contains('$surahNumber:$ayahNumber');

  /// Whether a given ayah is a rub al-hizb boundary.
  bool isRubBoundary(int surahNumber, int ayahNumber) =>
      rubBoundaries.contains('$surahNumber:$ayahNumber');

  /// The 1-based rub index for a given ayah, or null if not a boundary.
  int? getRubIndex(int surahNumber, int ayahNumber) =>
      rubIndexMap['$surahNumber:$ayahNumber'];

  /// The page number for a given ayah.
  int? getPageNumber(
    int surahNumber,
    int ayahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) =>
      getAyah(surahNumber, ayahNumber, language: language).page;

  /// The juz number for a given ayah.
  int? getJuzNumber(
    int surahNumber,
    int ayahNumber, {
    QuranLanguage language = QuranLanguage.arabic,
  }) =>
      getAyah(surahNumber, ayahNumber, language: language).juz;

  /// Raw page segments for a page (surah/start/end).
  List<Map<String, int>> getPageData(int pageNumber) =>
      pageIndex[pageNumber] ?? [];

  Surah _annotateSurah(Surah surah, int surahNumber) {
    final needsSurahNumber =
        surah.verses.isNotEmpty && surah.verses.first.surahNumber == 0;
    if (!needsSurahNumber && sajdaKeys.isEmpty) return surah;

    final updated = surah.verses
        .map((v) => Ayah(
              id: v.id,
              surahNumber: v.surahNumber == 0 ? surahNumber : v.surahNumber,
              text: v.text,
              page: v.page,
              juz: v.juz,
              tafsir: v.tafsir,
              audioUrl: v.audioUrl,
              isSajda: sajdaKeys.contains('$surahNumber:${v.id}'),
            ))
        .toList();
    return Surah(id: surah.id, verses: updated);
  }

  String _normalizeArabic(String input) {
    var s = input;
    s = s.replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '');
    s = s.replaceAll('ـ', '');
    s = s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي');
    s = s.replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  String _normalizeEnglish(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }
}

// ----------------
// Private helpers
// ----------------

Map<int, String> _parseTafsirFromMap(Map<String, dynamic> data) {
  final verses = data['verses'] as List;
  return {for (var v in verses) v['id'] as int: v['text'] as String};
}

Map<int, Map<String, dynamic>> _quranDataForLanguage(QuranLanguage language) {
  return language == QuranLanguage.english
      ? quran_en.quranDataenglish
      : quran_ar.quranDataarabic;
}

Map<int, Map<String, dynamic>> _tafsirDataForLanguage(QuranLanguage language) {
  // English tafsir is not available — only Arabic tafsir is currently supported.
  if (language == QuranLanguage.english) return {};
  return tafsir_ar.tafsirDataarabic;
}

List<dynamic> _searchDataForLanguage(QuranLanguage language) {
  return language == QuranLanguage.english
      ? englishSearchData
      : arabicSearchData;
}
