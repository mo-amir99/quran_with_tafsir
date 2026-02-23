import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../widgets/ayah_card.dart';
import '../widgets/language_dropdown.dart';

/// Displays a single surah with optional tafsir toggle.
class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final QuranLanguage language;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    required this.language,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late QuranLanguage _language = widget.language;
  late Surah _surah;
  Map<int, String>? _tafsir;
  bool _showTafsir = false;

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  void _loadSurah() {
    _surah = QuranService.instance.getSurah(
      widget.surahNumber,
      language: _language,
    );
    _tafsir = null;
    _showTafsir = false;
  }

  void _toggleTafsir() {
    _tafsir ??= QuranService.instance.getTafsir(
      widget.surahNumber,
      language: _language,
    );
    setState(() => _showTafsir = !_showTafsir);
  }

  void _changeLanguage(QuranLanguage lang) {
    setState(() {
      _language = lang;
      _loadSurah();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _language == QuranLanguage.english
        ? QuranService.instance.getSurahNameEnglish(widget.surahNumber)
        : QuranService.instance.getSurahNameArabic(widget.surahNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          LanguageDropdown(value: _language, onChanged: _changeLanguage),
          IconButton(
            icon: Icon(_showTafsir ? Icons.book : Icons.book_outlined),
            tooltip: _showTafsir ? 'Hide Tafsir' : 'Show Tafsir',
            onPressed: _toggleTafsir,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _surah.verses.length,
        itemBuilder: (context, index) {
          final ayah = _surah.verses[index];
          return AyahCard(
            ayah: ayah,
            language: _language,
            tafsir: (_showTafsir && _tafsir != null) ? _tafsir![ayah.id] : null,
          );
        },
      ),
    );
  }
}
