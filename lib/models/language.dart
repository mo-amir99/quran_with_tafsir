enum QuranLanguage {
  arabic,
  english;

  /// Resolve a language from its code string ('arabic' or 'english').
  static QuranLanguage fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'english':
      case 'en':
        return QuranLanguage.english;
      case 'arabic':
      case 'ar':
      default:
        return QuranLanguage.arabic;
    }
  }
}

extension QuranLanguageExt on QuranLanguage {
  String get code {
    switch (this) {
      case QuranLanguage.arabic:
        return 'arabic';
      case QuranLanguage.english:
        return 'english';
    }
  }
}
