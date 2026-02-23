import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../widgets/ayah_card.dart';
import '../widgets/language_dropdown.dart';

/// Browse Quran page-by-page (1-604).
class PageBrowserScreen extends StatefulWidget {
  final QuranLanguage language;

  const PageBrowserScreen({super.key, required this.language});

  @override
  State<PageBrowserScreen> createState() => _PageBrowserScreenState();
}

class _PageBrowserScreenState extends State<PageBrowserScreen> {
  late QuranLanguage _language = widget.language;
  int _page = 1;

  List<Ayah> get _verses =>
      QuranService.instance.getPage(_page, language: _language);

  void _goTo(int page) {
    if (page < 1 || page > 604) return;
    setState(() => _page = page);
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
                onPressed: _page > 1 ? () => _goTo(_page - 1) : null,
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      final controller = TextEditingController(text: '$_page');
                      final result = await showDialog<int>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Go to page'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            autofocus: true,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final p =
                                    int.tryParse(controller.text) ?? _page;
                                Navigator.pop(context, p);
                              },
                              child: const Text('Go'),
                            ),
                          ],
                        ),
                      );
                      if (result != null) _goTo(result);
                    },
                    child: Text(
                      'Page $_page / 604',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _page < 604 ? () => _goTo(_page + 1) : null,
              ),
              LanguageDropdown(
                value: _language,
                onChanged: (l) => setState(() => _language = l),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // --- Verses list ---
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
