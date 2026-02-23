import 'package:flutter/material.dart';
import 'package:quran_with_tafsir/quran_with_tafsir.dart';
import 'screens/surah_list_screen.dart';
import 'screens/page_browser_screen.dart';
import 'screens/juz_browser_screen.dart';
import 'screens/search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranExampleApp());
}

class QuranExampleApp extends StatelessWidget {
  const QuranExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran With Tafsir — Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  QuranLanguage _language = QuranLanguage.arabic;

  static const _labels = ['Surahs', 'Pages', 'Juz', 'Search'];
  static const _icons = [
    Icons.list_alt,
    Icons.auto_stories,
    Icons.bookmark,
    Icons.search,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_labels[_tab])),
      body: IndexedStack(
        index: _tab,
        children: [
          SurahListScreen(language: _language),
          PageBrowserScreen(language: _language),
          JuzBrowserScreen(language: _language),
          SearchScreen(language: _language),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: List.generate(
          _labels.length,
          (i) => NavigationDestination(
            icon: Icon(_icons[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}
