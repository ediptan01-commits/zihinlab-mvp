import '../models/puzzle.dart';

const puzzleBank = <Puzzle>[
  Puzzle(
    id: 'desen-01',
    title: 'Sayı dizisi',
    category: 'DESENLER',
    question: '2, 6, 12, 20, 30, ?\n\nSıradaki sayı kaçtır?',
    options: ['40', '42', '44', '48'],
    answers: ['42'],
    hints: [
      'Ardışık sayıların arasındaki farklara bak.',
      'Farklar 4, 6, 8 ve 10 şeklinde artıyor.',
      'Bir sonraki fark 12; 30 + 12 = 42.',
    ],
    explanation: 'Farklar sırasıyla 4, 6, 8, 10 ve 12’dir. Her adımda fark 2 artar; cevap 42.',
    points: 100,
  ),
  Puzzle(
    id: 'mantik-01',
    title: 'Üç anahtar',
    category: 'AKIL YÜRÜTME',
    question: 'Bir odanın dışında üç anahtar, içeride tek bir ampul var. Odaya yalnızca bir kez girebilirsin. Hangi anahtarın ampule bağlı olduğunu nasıl anlarsın?',
    options: [
      'Bir anahtarı açıp odaya girer, ampul yanıyorsa onu seçerim.',
      'İlk anahtarı birkaç dakika açıp kapatır, ikinciyi açarım; ampulün ışığını ve sıcaklığını kontrol ederim.',
      'Üç anahtarı da sırayla açıp odaya girerim.',
      'Anahtarlara dokunmadan yalnızca ampule bakarım.',
    ],
    answers: [
      'İlk anahtarı birkaç dakika açıp kapatır, ikinciyi açarım; ampulün ışığını ve sıcaklığını kontrol ederim.',
    ],
    hints: [
      'Ampulün ışığı dışında bir özelliğini de kullanabilirsin.',
      'Isı, daha önce çalışıp çalışmadığını gösterir.',
      'Bir anahtarı birkaç dakika açık tut, kapat; ikinciyi aç ve odaya gir.',
    ],
    explanation: 'İkinci anahtar açıksa ampul yanar. Kapalı ama sıcaksa ilk anahtara bağlıdır. Kapalı ve soğuksa üçüncü anahtardır.',
    points: 150,
  ),
  Puzzle(
    id: 'kelime-01',
    title: 'Eksik harf',
    category: 'KELİME OYUNU',
    question: 'KAR kelimesinin sonuna bir harf ekleyince bir taşıt adı oluşur. Hangi harfi eklersin?',
    options: ['R', 'T', 'S', 'K'],
    answers: ['t'],
    hints: [
      'Taşıtın iki tekerleği olabilir.',
      'Kelime KART olur.',
      'Cevap T harfidir.',
    ],
    explanation: 'KAR kelimesinin sonuna T ekleyince KART oluşur; bu bir taşıt adıdır.',
    points: 80,
  ),
];

bool validatePuzzleBank(Iterable<Puzzle> puzzles) {
  final list = puzzles.toList();
  if (list.isEmpty) return false;
  final ids = <String>{};

  for (final puzzle in list) {
    final normalizedOptions = puzzle.options.map(puzzle.normalize).toList();
    if (puzzle.id.trim().isEmpty ||
        !ids.add(puzzle.id) ||
        puzzle.title.trim().isEmpty ||
        puzzle.question.trim().isEmpty ||
        puzzle.explanation.trim().isEmpty ||
        puzzle.answers.isEmpty ||
        puzzle.answers.any((answer) => answer.trim().isEmpty) ||
        puzzle.options.length != 4 ||
        puzzle.options.any((option) => option.trim().isEmpty) ||
        normalizedOptions.toSet().length != normalizedOptions.length ||
        puzzle.options.where(puzzle.accepts).length != 1 ||
        puzzle.hints.length != 3 ||
        puzzle.hints.any((hint) => hint.trim().isEmpty) ||
        puzzle.points <= 0) {
      return false;
    }
  }
  return true;
}
