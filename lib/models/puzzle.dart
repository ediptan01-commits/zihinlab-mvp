enum PuzzleMode { logic, moves, visual, mystery, memory, daily }

extension PuzzleModeInfo on PuzzleMode {
  String get title => switch (this) {
        PuzzleMode.logic => 'Mantık dedektifi',
        PuzzleMode.moves => 'Hamleni hesapla',
        PuzzleMode.visual => 'Görsel zekâ',
        PuzzleMode.mystery => 'Gizem odası',
        PuzzleMode.memory => 'Hafıza ve dikkat',
        PuzzleMode.daily => 'Günün meydan okuması',
      };

  String get shortTitle => switch (this) {
        PuzzleMode.logic => 'Mantık',
        PuzzleMode.moves => 'Hamle',
        PuzzleMode.visual => 'Görsel',
        PuzzleMode.mystery => 'Gizem',
        PuzzleMode.memory => 'Hafıza',
        PuzzleMode.daily => 'Günlük',
      };

  String get description => switch (this) {
        PuzzleMode.logic => 'Kuralları bul, çıkarım yap.',
        PuzzleMode.moves => 'Taşları hedefe az hamlede taşı.',
        PuzzleMode.visual => 'Şekillerdeki değişimi keşfet.',
        PuzzleMode.mystery => 'İpuçlarını birleştir, olayı çöz.',
        PuzzleMode.memory => 'Kısa süre gördüğün sırayı hatırla.',
        PuzzleMode.daily => 'Her gün yeni bir meydan okuma.',
      };
}

class Puzzle {
  const Puzzle({
    required this.id,
    required this.title,
    required this.mode,
    required this.question,
    this.options = const [],
    required this.answers,
    required this.hints,
    required this.explanation,
    required this.points,
    required this.skill,
    this.difficulty = 1,
    this.slideStart = const [],
    this.moveLimit = 0,
    this.memorySequence = const [],
  });

  final String id, title, question, explanation, skill;
  final PuzzleMode mode;
  final List<String> options, answers, hints, memorySequence;
  final List<int> slideStart;
  final int points, difficulty, moveLimit;

  String normalize(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool accepts(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return answers.any((answer) => answer.trim() == value.trim());
    }
    return answers.any((answer) => normalize(answer) == normalized);
  }
}
