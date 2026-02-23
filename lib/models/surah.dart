class Ayah {
  final int id; // Ayah Number in Surah
  final int surahNumber;
  final String text;
  final int page;
  final int juz;
  final String? tafsir;
  final String? audioUrl;
  final bool isSajda;

  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.text,
    required this.page,
    required this.juz,
    this.tafsir,
    this.audioUrl,
    this.isSajda = false,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      id: json['id'] as int,
      surahNumber: json['surah'] as int? ?? 0,
      text: json['text'] as String,
      page: json['page'] as int,
      juz: json['juz'] as int,
      tafsir:
          json['tafsir'] as String?, // Might be null if loaded from quran only
      isSajda: json['is_sajda'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'surah': surahNumber,
        'text': text,
        'page': page,
        'juz': juz,
        if (tafsir != null) 'tafsir': tafsir,
        if (audioUrl != null) 'audioUrl': audioUrl,
        if (isSajda) 'is_sajda': true,
      };

  Ayah copyWith({
    int? id,
    int? surahNumber,
    String? text,
    int? page,
    int? juz,
    String? tafsir,
    String? audioUrl,
    bool? isSajda,
  }) =>
      Ayah(
        id: id ?? this.id,
        surahNumber: surahNumber ?? this.surahNumber,
        text: text ?? this.text,
        page: page ?? this.page,
        juz: juz ?? this.juz,
        tafsir: tafsir ?? this.tafsir,
        audioUrl: audioUrl ?? this.audioUrl,
        isSajda: isSajda ?? this.isSajda,
      );

  @override
  String toString() =>
      'Ayah(surah: $surahNumber, id: $id, page: $page, juz: $juz)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayah &&
          other.surahNumber == surahNumber &&
          other.id == id;

  @override
  int get hashCode => Object.hash(surahNumber, id);
}

class Surah {
  final int id;
  final List<Ayah> verses;

  Surah({required this.id, required this.verses});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      verses: (json['verses'] as List).map((e) => Ayah.fromJson(e)).toList(),
    );
  }
}
