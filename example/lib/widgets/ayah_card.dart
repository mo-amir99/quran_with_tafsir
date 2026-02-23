import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';

/// Reusable card widget that displays a single Ayah with optional tafsir.
class AyahCard extends StatelessWidget {
  final Ayah ayah;
  final QuranLanguage language;
  final String? tafsir;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.language,
    this.tafsir,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = language == QuranLanguage.arabic;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Ayah text ---
            Text(
              ayah.text,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              style: isArabic
                  ? const TextStyle(
                      fontFamily: 'QuranFont',
                      fontSize: 24,
                      height: 2.0,
                    )
                  : Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),

            // --- Info row ---
            Row(
              children: [
                Text(
                  'Surah ${ayah.surahNumber} · Ayah ${ayah.id} · '
                  'Page ${ayah.page} · Juz ${ayah.juz}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (ayah.isSajda) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_downward, size: 16, color: Colors.red),
                  Text(' Sajda',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red)),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 20),
                  tooltip: 'Show audio URL',
                  onPressed: ayah.surahNumber == 0
                      ? null
                      : () {
                          final url = QuranService.instance.getAudioUrl(
                            ayah.surahNumber,
                            ayah.id,
                            reciterIdentifier: Reciters.alafasy,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(url)));
                        },
                ),
              ],
            ),

            // --- Tafsir (optional) ---
            if (tafsir != null && tafsir!.isNotEmpty) ...[
              const Divider(),
              Text(
                tafsir!,
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                style: isArabic
                    ? const TextStyle(
                        fontFamily: 'TafsirFont',
                        fontSize: 18,
                        height: 1.8,
                      )
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
