import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import '../widgets/ayah_card.dart';
import '../widgets/language_dropdown.dart';

/// Full-text search with Arabic normalization support.
class SearchScreen extends StatefulWidget {
  final QuranLanguage language;

  const SearchScreen({super.key, required this.language});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late QuranLanguage _language = widget.language;
  final _controller = TextEditingController();
  List<Ayah> _results = [];
  bool _searched = false;

  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _results = QuranService.instance.search(
        query,
        limit: 50,
        language: _language,
      );
      _searched = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Search bar ---
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _language == QuranLanguage.arabic
                        ? 'ابحث في القرآن...'
                        : 'Search the Quran...',
                    border: const OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  textDirection: _language == QuranLanguage.arabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
              const SizedBox(width: 4),
              LanguageDropdown(
                value: _language,
                onChanged: (l) => setState(() {
                  _language = l;
                  _results = [];
                  _searched = false;
                }),
              ),
            ],
          ),
        ),
        if (_searched)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_results.length} results',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        const Divider(height: 1),

        // --- Results ---
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    _searched ? 'No results found.' : 'Enter a search query.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) =>
                      AyahCard(ayah: _results[index], language: _language),
                ),
        ),
      ],
    );
  }
}
