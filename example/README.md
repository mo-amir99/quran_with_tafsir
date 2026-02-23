# Quran With Tafsir — Example App

A Flutter example app demonstrating all features of the `quran_with_tafsir` package.

## Structure

```
lib/
  main.dart                          — App entry point & tab navigation
  screens/
    surah_list_screen.dart           — Browse all 114 surahs
    surah_detail_screen.dart         — Read a surah with tafsir toggle
    page_browser_screen.dart         — Navigate by page (1-604)
    juz_browser_screen.dart          — Navigate by juz (1-30)
    search_screen.dart               — Full-text search
  widgets/
    ayah_card.dart                   — Reusable ayah display card
    language_dropdown.dart           — Arabic/English language switcher
```

## Tabs

| Tab | Description |
|---|---|
| **Surahs** | Lists all 114 surahs with Arabic/English names, ayah count, and revelation type. Tap to read with optional tafsir. |
| **Pages** | Page-by-page Quran browsing (604 pages). Tap page number to jump to any page. |
| **Juz** | Browse by juz (1-30) with ayah count display. |
| **Search** | Full-text search with Arabic normalization. Switch between Arabic and English. |

## Running

```bash
cd example
flutter run
```
