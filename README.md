# Quran With Tafsir

[![pub package](https://img.shields.io/pub/v/quran_with_tafsir.svg)](https://pub.dev/packages/quran_with_tafsir)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A production-ready, **fully offline** Quran package for Dart & Flutter. All data is embedded — no network calls, no initialization step, no async loading.

Works with any Dart project (CLI, server, Flutter).

---

## Features

| Category        | Details                                                                                     |
| --------------- | ------------------------------------------------------------------------------------------- |
| **Quran Text**  | Full Arabic text (Uthmani script) + English translation (Saheeh International)              |
| **Tafsir**      | Arabic Tafsir Al-Muyassar for all 114 surahs                                                |
| **Search**      | Fast local search with Arabic normalization (handles tashkeel, hamza variants)              |
| **Navigation**  | By Surah, Page (604 pages), Juz (30 parts), or individual Ayah                              |
| **Metadata**    | Surah names (Arabic/English), ayah count, revelation type (Meccan/Medinan), sajda locations |
| **Rub Al-Hizb** | Rub (quarter) boundary detection and index lookup                                           |
| **Audio**       | URL generation for 40+ reciters via everyayah.com                                           |
| **Reciters**    | Full catalog with English & Arabic display names                                            |
| **Offline**     | Zero network dependencies — every byte is embedded                                          |
| **Pure Dart**   | No Flutter dependency — use in CLI tools, servers, or Flutter apps                          |

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  quran_with_tafsir: ^1.0.1
```

Then run:

```bash
dart pub get        # Dart projects
flutter pub get     # Flutter projects
```

---

## Quick Start

```dart
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

void main() {
  final service = QuranService.instance;

  // Get Al-Fatihah
  final surah = service.getSurah(1);
  for (final ayah in surah.verses) {
    print('${ayah.id}: ${ayah.text}');
  }

  // Search
  final results = service.search('الحمد', limit: 10);
  print('Found ${results.length} results');
}
```

No `initialize()` call needed — all data is const and ready at import time.

---

## API Reference

### Metadata

```dart
final service = QuranService.instance;

// All 114 surahs
final List<SurahMetadata> surahs = service.getAllSurahs();

// Surah names
final String nameAr = service.getSurahNameArabic(1);   // "الفَاتِحة"
final String nameEn = service.getSurahNameEnglish(1);   // "Al-Fātiḥah"

// Revelation info
final String? place = service.getPlaceOfRevelation(1);  // "Meccan"
final bool isMeccan = service.getSurahMetadata(1).isMeccan; // true

// Ayah count
final int count = service.getVerseCount(1);  // 7
```

### Surah & Ayah

```dart
// Full surah (Arabic)
final Surah surah = service.getSurah(1);

// English translation
final Surah surahEn = service.getSurah(1, language: QuranLanguage.english);

// Single ayah
final Ayah ayah = service.getAyah(1, 1);

// Ayah properties:
//   ayah.id          → ayah number within the surah
//   ayah.surahNumber → surah number
//   ayah.text        → ayah text
//   ayah.page        → page number (1-604)
//   ayah.juz         → juz number (1-30)
//   ayah.isSajda     → whether this ayah has a sajda
```

### Page & Juz Navigation

```dart
// All ayahs on a page (1-604)
final List<Ayah> pageAyahs = service.getPage(1);

// All ayahs in a juz (1-30)
final List<Ayah> juzAyahs = service.getJuz(1);

// Look up page/juz for a specific ayah
final int? page = service.getPageNumber(1, 1);  // 1
final int? juz  = service.getJuzNumber(1, 1);   // 1
```

### Tafsir

```dart
// Arabic Tafsir Al-Muyassar (keyed by ayah number)
final Map<int, String> tafsir = service.getTafsir(1);

for (final entry in tafsir.entries) {
  print('Ayah ${entry.key}: ${entry.value}');
}
```

### Search

```dart
// Arabic search (handles tashkeel, hamza normalization)
final List<Ayah> results = service.search('الحمد', limit: 50);

// English search
final List<Ayah> enResults = service.search(
  'mercy',
  language: QuranLanguage.english,
  limit: 20,
);

// Async wrapper for UI contexts
final List<Ayah> asyncResults = await service.searchAsync('الحمد');
```

### Audio

```dart
// Audio URL for a specific ayah
final String url = service.getAudioUrl(1, 1, reciterIdentifier: Reciters.alafasy);
// → "https://everyayah.com/data/Alafasy_128kbps/001001.mp3"

// All reciter display names
final Map<String, String> names   = Reciters.displayNames;   // English
final Map<String, String> namesAr = Reciters.displayNamesAr; // Arabic
```

#### Built-in Reciters (40+)

| Constant                      | Reciter                     |
| ----------------------------- | --------------------------- |
| `Reciters.alafasy`            | Mishary Alafasy             |
| `Reciters.abdulBasit`         | Abdul Basit (Murattal)      |
| `Reciters.abdulBasitMujawwad` | Abdul Basit (Mujawwad)      |
| `Reciters.sudouk`             | Abdurrahman As-Sudais       |
| `Reciters.shuraym`            | Saood Ash-Shuraym           |
| `Reciters.husary`             | Mahmoud Khalil Al-Husary    |
| `Reciters.minshawi`           | Mohamed Siddiq Al-Minshawi  |
| `Reciters.maherMuaiqly`       | Maher Al-Muaiqly            |
| ...                           | See `Reciters.displayNames` |

### Sajda & Rub Al-Hizb

```dart
// Check if an ayah is a sajda location
final bool isSajda = service.isSajda(96, 19);  // true

// Check if an ayah is a rub al-hizb boundary
final bool isRub = service.isRubBoundary(2, 26);

// 1-based rub index (null if not a boundary)
final int? rubIndex = service.getRubIndex(2, 26);
```

---

## Models

### `Ayah`

| Property      | Type      | Description                   |
| ------------- | --------- | ----------------------------- |
| `id`          | `int`     | Ayah number within the surah  |
| `surahNumber` | `int`     | Surah number (1-114)          |
| `text`        | `String`  | Ayah text                     |
| `page`        | `int`     | Page number (1-604)           |
| `juz`         | `int`     | Juz number (1-30)             |
| `tafsir`      | `String?` | Tafsir text (if loaded)       |
| `audioUrl`    | `String?` | Audio URL (if set)            |
| `isSajda`     | `bool`    | Whether this ayah has a sajda |

Supports `copyWith()`, `==`, and `hashCode`.

### `SurahMetadata`

| Property         | Type      | Description           |
| ---------------- | --------- | --------------------- |
| `number`         | `int`     | Surah number (1-114)  |
| `nameEn`         | `String`  | English name          |
| `nameAr`         | `String`  | Arabic name           |
| `ayahCount`      | `int`     | Number of ayahs       |
| `revelationType` | `String?` | "Meccan" or "Medinan" |
| `isMeccan`       | `bool`    | Convenience getter    |
| `isMedinan`      | `bool`    | Convenience getter    |

### `QuranLanguage`

```dart
enum QuranLanguage { arabic, english }
```

---

## Data Sources

| Data                | Source                                                          |
| ------------------- | --------------------------------------------------------------- |
| Arabic text         | King Fahd Complex for the Printing of the Holy Qur'an (Madinah) |
| Tafsir (Arabic)     | Tafsir Al-Muyassar — King Fahd Complex                          |
| English translation | Saheeh International (via King Fahd Complex and QuranEnc)       |
| Metadata            | Tanzil.net                                                      |
| Audio               | everyayah.com                                                   |

---

## See It in Action

This package powers the **Al-Mu'min (المؤمن)** app — a comprehensive Islamic companion:

<p>
  <a href="https://play.google.com/store/apps/details?id=com.thebeast_code.almumin">
    <img alt="Get it on Google Play" src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" height="60" />
  </a>
  <a href="https://apps.apple.com/app/al-mumin-prayer-quran-dua/id6757585610">
    <img alt="Download on the App Store" src="https://developer.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg" height="60" />
  </a>
</p>

---

## Recommended Fonts

The package is plain text — rendering is entirely up to the host app. For the best Arabic display we recommend these two fonts for Uthmanic Hafs Style:

| Purpose        | Font                                          | Family name in Flutter |
| -------------- | --------------------------------------------- | ---------------------- |
| Quran text     | **KFG Hafs Uthmanic Script** (Uthmani script) | `QuranFont`            |
| Tafsir / prose | **Amiri Quran**                               | `TafsirFont`           |

Both fonts are included in the [`example/assets/fonts/`](example/assets/fonts/) folder — copy them into your app and register them in `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: QuranFont
      fonts:
        - asset: assets/fonts/KfgqpcHafsUthmanicScriptRegular-nARZ1.ttf
    - family: TafsirFont
      fonts:
        - asset: assets/fonts/AmiriQuran-Regular.ttf
```

Then use them with standard Flutter `TextStyle`:

```dart
// Quran text
Text(
  ayah.text,
  textDirection: TextDirection.rtl,
  style: const TextStyle(fontFamily: 'QuranFont', fontSize: 24, height: 2.0),
);

// Tafsir
Text(
  ayah.tafsir,
  textDirection: TextDirection.rtl,
  textAlign: TextAlign.right,
  style: const TextStyle(fontFamily: 'TafsirFont', fontSize: 18, height: 1.8),
);
```

---

## Example App

A full Flutter example app is included in the [`example/`](example) directory with 4 tabs.
It uses both bundled fonts out of the box — see [example/assets/fonts/](example/assets/fonts/).

- **Surahs** — Browse all 114 surahs, tap to read with tafsir toggle
- **Pages** — Page-by-page navigation (1-604) with go-to dialog
- **Juz** — Browse by juz (1-30)
- **Search** — Full-text search with Arabic/English toggle

```bash
cd example
flutter run
```

---

## About the Developer

This package is maintained by **The Beast Code**. We build high-quality digital experiences.
Check out our website: [thebeastcode.com](https://thebeastcode.com)

---

## License

MIT — see [LICENSE](LICENSE) for details.
