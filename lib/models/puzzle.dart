class Puzzle {
  const Puzzle({
    required this.id,
    required this.title,
    required this.category,
    required this.question,
    this.options = const [],
    required this.answers,
    required this.hints,
    required this.explanation,
    required this.points,
  });

  final String id, title, category, question, explanation;
  final List<String> options, answers, hints;
  final int points;

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
      .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');

  bool accepts(String value) {
    final normalized = normalize(value);
    return normalized.isNotEmpty &&
        answers.any((answer) => normalize(answer) == normalized);
  }
}
