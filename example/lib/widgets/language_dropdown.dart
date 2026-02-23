import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

/// Dropdown to switch between Arabic and English.
class LanguageDropdown extends StatelessWidget {
  final QuranLanguage value;
  final ValueChanged<QuranLanguage> onChanged;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<QuranLanguage>(
      value: value,
      underline: const SizedBox.shrink(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      items: const [
        DropdownMenuItem(
          value: QuranLanguage.arabic,
          child: Text('العربية'),
        ),
        DropdownMenuItem(
          value: QuranLanguage.english,
          child: Text('English'),
        ),
      ],
    );
  }
}
