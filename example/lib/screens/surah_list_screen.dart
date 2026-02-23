import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import 'surah_detail_screen.dart';

/// Lists all 114 surahs with metadata — tap to open.
class SurahListScreen extends StatelessWidget {
  final QuranLanguage language;

  const SurahListScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final surahs = QuranService.instance.getAllSurahs();
    return ListView.builder(
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${surah.number}')),
          title: Text(surah.nameEn),
          subtitle: Text(
            '${surah.ayahCount} ayat · ${surah.revelationType ?? ''}',
          ),
          trailing: Text(
            surah.nameAr,
            style: const TextStyle(fontSize: 18),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailScreen(
                  surahNumber: surah.number,
                  language: language,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
