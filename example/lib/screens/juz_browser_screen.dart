import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../widgets/ayah_card.dart';
import '../widgets/language_dropdown.dart';

/// Browse Quran by Juz (1-30).
class JuzBrowserScreen extends StatefulWidget {
  final QuranLanguage language;

  const JuzBrowserScreen({super.key, required this.language});

  @override
  State<JuzBrowserScreen> createState() => _JuzBrowserScreenState();
}

class _JuzBrowserScreenState extends State<JuzBrowserScreen> {
  late QuranLanguage _language = widget.language;
  int _juz = 1;

  List<Ayah> get _verses =>
      QuranService.instance.getJuz(_juz, language: _language);

  void _goTo(int juz) {
    if (juz < 1 || juz > 30) return;
    setState(() => _juz = juz);
  }

  @override
  Widget build(BuildContext context) {
    final verses = _verses;
    return Column(
      children: [
        // --- Controls ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _juz > 1 ? () => _goTo(_juz - 1) : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Juz $_juz / 30  (${verses.length} ayat)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _juz < 30 ? () => _goTo(_juz + 1) : null,
              ),
              LanguageDropdown(
                value: _language,
                onChanged: (l) => setState(() => _language = l),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- Verses ---
        Expanded(
          child: ListView.builder(
            itemCount: verses.length,
            itemBuilder: (context, index) =>
                AyahCard(ayah: verses[index], language: _language),
          ),
        ),
      ],
    );
  }
}
