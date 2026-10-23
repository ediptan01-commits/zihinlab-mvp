import '../models/puzzle.dart';

const puzzleBank = <Puzzle>[
  Puzzle(
    id: 'mantik-01',
    title: 'Sayı merdiveni',
    mode: PuzzleMode.logic,
    question: '2, 6, 12, 20, 30, ? Sıradaki sayı kaçtır?',
    options: ['40', '42', '44', '48'],
    answers: ['42'],
    hints: [
      'Ardışık sayıların arasındaki farklara bak.',
      'Farklar 4, 6, 8 ve 10 şeklinde artıyor.',
      'Bir sonraki fark 12; 30 + 12 = 42.',
    ],
    explanation: 'Farklar 4, 6, 8, 10 ve 12 olur; her adımda fark 2 artar.',
    points: 100,
    difficulty: 1,
    skill: 'Örüntü tanıma',
  ),
  Puzzle(
    id: 'mantik-02',
    title: 'Büyük taş',
    mode: PuzzleMode.logic,
    question: 'Kırmızı taşların hepsi büyük. Mavi taşların hiçbiri büyük değil. Büyük bir taş seçtin. Rengi ne olabilir?',
    options: [
      'Yalnızca kırmızı',
      'Yalnızca mavi',
      'Kırmızı veya mavi',
      'Rengi bilinemez',
    ],
    answers: ['Yalnızca kırmızı'],
    hints: [
      'Büyük taşın mavi olamayacağını hatırla.',
      'Mavi taşların hiçbiri büyük değil.',
      'Büyük taş kırmızı olmalı.',
    ],
    explanation: 'Mavi taşların hiçbiri büyük olmadığına göre seçilen büyük taş kırmızıdır.',
    points: 100,
    difficulty: 1,
    skill: 'Koşullu çıkarım',
  ),
  Puzzle(
    id: 'mantik-03',
    title: 'Yarış sırası',
    mode: PuzzleMode.logic,
    question: 'Ece, Bora’dan hızlı. Can da Ece’den hızlı. En yavaş kimdir?',
    options: ['Ece', 'Bora', 'Can', 'Belirlenemez'],
    answers: ['Bora'],
    hints: [
      'Hızlıdan yavaşa bir sıra kur.',
      'Can, Ece’nin önünde; Ece, Bora’nın önünde.',
      'Sıranın sonunda Bora var.',
    ],
    explanation: 'Can > Ece > Bora sıralaması olduğundan en yavaş Bora’dır.',
    points: 110,
    difficulty: 2,
    skill: 'Sıralı çıkarım',
  ),
  Puzzle(
    id: 'mantik-04',
    title: 'Kare sayılar',
    mode: PuzzleMode.logic,
    question: '1, 4, 9, 16, 25, ? Dizideki kuralı bul.',
    options: ['30', '35', '36', '49'],
    answers: ['36'],
    hints: [
      'Sayıları kendileriyle çarpılan sayılar olarak düşün.',
      '1², 2², 3², 4², 5² şeklinde gidiyor.',
      '6² = 36.',
    ],
    explanation:
        'Dizi ardışık sayıların karelerinden oluşur; sıradaki 6² yani 36’dır.',
    points: 120,
    difficulty: 2,
    skill: 'Sayı örüntüsü',
  ),
  Puzzle(
    id: 'mantik-05',
    title: 'Üç anahtar',
    mode: PuzzleMode.logic,
    question: 'Üç anahtardan biri odadaki ampule bağlı. Odaya yalnızca bir kez girebilirsin. Hangi yöntemi seçersin?',
    options: [
      'İlkini açıp hemen girerim.',
      'İlkini bir süre açıp kapatır, ikincisini açıp girerim.',
      'Üçünü aynı anda açarım.',
      'Hiçbirine dokunmam.',
    ],
    answers: ['İlkini bir süre açıp kapatır, ikincisini açıp girerim.'],
    hints: [
      'Ampulün ışığı dışında bir özelliği de var.',
      'Isı, daha önce yanıp yanmadığını gösterir.',
      'İkinci açık, ilk sıcak, üçüncü soğuk olur.',
    ],
    explanation: 'Yanıyorsa ikinci; sönük ama sıcaksa ilk; sönük ve soğuksa üçüncü anahtardır.',
    points: 150,
    difficulty: 3,
    skill: 'Deney tasarlama',
  ),

  Puzzle(
    id: 'hamle-01',
    title: 'İki hamlede hedef',
    mode: PuzzleMode.moves,
    question: 'Taşları 1’den 8’e sırala, boş kare en sonda kalsın.',
    answers: ['tamamlandı'],
    hints: [
      'Boş kareyi sağa, 5’in olduğu kareye taşı.',
      'Ardından 6’yı aşağı kaydır.',
      'Hedef sırası 1–8 ve boş karedir.',
    ],
    explanation:
        'Önce 5’i, sonra 6’yı boş kareye kaydırarak dizilimi tamamlarsın.',
    points: 120,
    difficulty: 1,
    skill: 'Planlama',
    slideStart: [1, 2, 3, 4, 0, 5, 7, 8, 6],
    moveLimit: 3,
  ),
  Puzzle(
    id: 'hamle-02',
    title: 'Dört adım',
    mode: PuzzleMode.moves,
    question: 'Boş kareyi kullanarak taşları hedef sıraya getir. En iyi çözüm dört hamle.',
    answers: ['tamamlandı'],
    hints: [
      'Boş kare sol üst köşede.',
      'Sağa, sonra aşağı kaydır.',
      'Son iki hamlede 5 ve 6’yı yerlerine taşı.',
    ],
    explanation: 'Her hamlede yalnızca boşluğa komşu taşı kaydır; dört doğru adım yeterli.',
    points: 140,
    difficulty: 2,
    skill: 'Hamleleri öngörme',
    slideStart: [0, 1, 3, 4, 2, 5, 7, 8, 6],
    moveLimit: 5,
  ),
  Puzzle(
    id: 'hamle-03',
    title: 'Dar koridor',
    mode: PuzzleMode.moves,
    question: 'Taşları 1’den 8’e sırala. Her kaydırma bir hamledir.',
    answers: ['tamamlandı'],
    hints: [
      'Boş kare ortadaki kutuda.',
      'Boşluğu sola, yukarı, sağa götür.',
      'Aşağı, sağa ve aşağı hamleleriyle bitir.',
    ],
    explanation:
        'Kısa bir planla boşluğu doğru konuma getirip taşları sıraya sokarsın.',
    points: 160,
    difficulty: 3,
    skill: 'Uzamsal planlama',
    slideStart: [4, 1, 3, 2, 0, 5, 7, 8, 6],
    moveLimit: 7,
  ),
  Puzzle(
    id: 'hamle-04',
    title: 'Üç kaydırma',
    mode: PuzzleMode.moves,
    question: 'Hedef dizilimi üç hamleden kısa sürede tamamlamayı dene.',
    answers: ['tamamlandı'],
    hints: [
      'Boş kare orta sıranın solunda.',
      '4 ve 5’i sırayla sağa kaydır.',
      'Son hamlede 6’yı aşağı indir.',
    ],
    explanation: 'Boş kareyi soldan sağa üç kez ilerleterek hedefe ulaşırsın.',
    points: 130,
    difficulty: 2,
    skill: 'Hamle sıralama',
    slideStart: [1, 2, 3, 0, 4, 5, 7, 8, 6],
    moveLimit: 4,
  ),
  Puzzle(
    id: 'hamle-05',
    title: 'Köşe dönüşü',
    mode: PuzzleMode.moves,
    question:
        'Taşları hedef sıraya getirirken boş kareyi köşeden merkeze taşı.',
    answers: ['tamamlandı'],
    hints: [
      'Boş kare üst sıranın sağında.',
      'Aşağı, sola, tekrar aşağı ilerle.',
      'Son hamlede 8’i boşluğa kaydır.',
    ],
    explanation: 'Boş kareyi merkez üzerinden yönlendirip dört hamlede sıralamayı bitirebilirsin.',
    points: 150,
    difficulty: 3,
    skill: 'Uzamsal akıl yürütme',
    slideStart: [1, 2, 0, 4, 6, 3, 7, 5, 8],
    moveLimit: 6,
  ),

  Puzzle(
    id: 'gorsel-01',
    title: 'Şekil sırası',
    mode: PuzzleMode.visual,
    question: '△  ○  △  ○  ? Sıradaki şekil hangisi?',
    options: ['△', '○', '□', '◇'],
    answers: ['△'],
    hints: [
      'Şekiller dönüşümlü ilerliyor.',
      'Üçgen ve daire sırayla geliyor.',
      'Daireden sonra üçgen gelir.',
    ],
    explanation: 'Dizide üçgen ve daire dönüşümlüdür; sırada üçgen vardır.',
    points: 100,
    difficulty: 1,
    skill: 'Görsel örüntü',
  ),
  Puzzle(
    id: 'gorsel-02',
    title: 'Dönen ok',
    mode: PuzzleMode.visual,
    question: '↑  →  ↓  ? Ok her adımda çeyrek tur dönüyor.',
    options: ['←', '↑', '→', '↓'],
    answers: ['←'],
    hints: [
      'Saat yönündeki dönüşü izle.',
      'Yukarı, sağ, aşağı şeklinde ilerliyor.',
      'Sıradaki yön soldur.',
    ],
    explanation:
        'Ok her adımda saat yönünde 90 derece döner; sırada sol vardır.',
    points: 110,
    difficulty: 2,
    skill: 'Dönüşü zihinde canlandırma',
  ),
  Puzzle(
    id: 'gorsel-03',
    title: 'Renk ve biçim',
    mode: PuzzleMode.visual,
    question: '🔵  🟡  🔵  🟡  ? Renk kuralını sürdür.',
    options: ['🔵', '🟡', '🔴', '🟢'],
    answers: ['🔵'],
    hints: [
      'İki renk sırayla tekrarlanıyor.',
      'Mavi daireden sonra sarı geliyor.',
      'Sarıdan sonra mavi gelir.',
    ],
    explanation: 'Mavi ve sarı dönüşümlü tekrar eder; sıradaki mavi dairedir.',
    points: 110,
    difficulty: 2,
    skill: 'Renk örüntüsü',
  ),
  Puzzle(
    id: 'gorsel-04',
    title: 'Eksik parça',
    mode: PuzzleMode.visual,
    question:
        '■ □ □  |  □ ■ □  |  □ □ ? Her satırda siyah kare yer değiştiriyor.',
    options: ['■', '□', '●', '▲'],
    answers: ['■'],
    hints: [
      'Siyah kare satır başından ortaya kaydı.',
      'Her satırda bir siyah kare var.',
      'Üçüncü satırın sonu siyah olmalı.',
    ],
    explanation:
        'Siyah kare her satırda bir sütun sağa geçer; son sütuna gelir.',
    points: 130,
    difficulty: 3,
    skill: 'Görsel konum takibi',
  ),
  Puzzle(
    id: 'gorsel-05',
    title: 'Büyüyen dizi',
    mode: PuzzleMode.visual,
    question: '• | •• | ••• | ? Bir sonraki parçayı seç.',
    options: ['••••', '••', '•••••', '•'],
    answers: ['••••'],
    hints: [
      'Her adımda bir nokta ekleniyor.',
      'Üçüncü parçanın üç noktası var.',
      'Dört noktalı seçeneği işaretle.',
    ],
    explanation: 'Her parça bir önceki parçadan bir nokta fazladır; sırada dört nokta bulunur.',
    points: 130,
    difficulty: 3,
    skill: 'Parça sayma',
  ),

  Puzzle(
    id: 'gorsel-00-fark',
    title: 'Fark avcısı',
    mode: PuzzleMode.visual,
    question: 'İki kartı karşılaştır. Farklı olan üç simgeyi bulup kartların üstüne dokun.',
    answers: const [],
    hints: const [
      'Simge sıralarını soldan sağa karşılaştır.',
      'Üst, orta ve alt sıradaki öğelere ayrı ayrı bak.',
      'Üç farklı noktayı işaretlediğinde kontrol edebilirsin.',
    ],
    explanation: 'Her iki karttaki dokuz simgeyi konumlarına göre karşılaştırarak üç değişikliği buldun.',
    points: 130,
    difficulty: 1,
    skill: 'Görsel karşılaştırma ve dikkat',
    differenceLeft: const [0, 1, 2, 3, 4, 5, 6, 7, 8],
    differenceRight: const [0, 1, 9, 3, 10, 5, 6, 11, 8],
    differencePositions: const [2, 4, 7],
  ),
  Puzzle(
    id: 'gorsel-06-fark',
    title: 'Bahçe kartları',
    mode: PuzzleMode.visual,
    question: 'Bahçe kartlarında değişen üç simgeyi bul. Her farkın olduğu kareye dokun.',
    answers: const [],
    hints: const [
      'Aynı konumdaki simgeleri iki kart arasında karşılaştır.',
      'Bir değişiklik orta sırada, biri alt sırada.',
      'Toplam üç farklı kareyi işaretle.',
    ],
    explanation:
        'Simgelerin konumunu karşılaştırıp üç değişikliği tek tek işaretledin.',
    points: 150,
    difficulty: 2,
    skill: 'Ayrıntı tarama',
    differenceLeft: const [3, 4, 5, 6, 7, 8, 9, 10, 11],
    differenceRight: const [3, 12, 5, 6, 7, 2, 9, 10, 0],
    differencePositions: const [1, 5, 8],
  ),
  Puzzle(
    id: 'gorsel-07-fark',
    title: 'Gece gökyüzü',
    mode: PuzzleMode.visual,
    question:
        'Gece kartlarını incele ve iki resim arasındaki üç farkı işaretle.',
    answers: const [],
    hints: const [
      'Simgeleri aynı sıradaki kareler arasında karşılaştır.',
      'Üst ve alt sıradaki simgelere dikkat et.',
      'Bulduğun her farklı konuma kartlardan birinde dokun.',
    ],
    explanation:
        'Kartların aynı konumundaki şekilleri karşılaştırarak üç farkı buldun.',
    points: 170,
    difficulty: 3,
    skill: 'Görsel seçici dikkat',
    differenceLeft: const [5, 4, 3, 2, 1, 0, 11, 10, 9],
    differenceRight: const [5, 4, 3, 12, 1, 13, 11, 10, 0],
    differencePositions: const [3, 5, 8],
  ),

  Puzzle(
    id: 'gizem-01',
    title: 'Kayıp kurabiye',
    mode: PuzzleMode.mystery,
    question: 'Ali “Ben almadım.”, Ece “Ali aldı.”, Can “Ece almadı.” dedi. Yalnızca bir kişi doğru söylüyorsa kurabiyeyi kim aldı?',
    options: ['Ali', 'Ece', 'Can', 'Belirlenemez'],
    answers: ['Ece'],
    hints: [
      'Her olasılıkta üç ifadeyi tek tek dene.',
      'Ali aldıysa iki kişi doğru söylemiş olur.',
      'Ece aldıysa yalnızca Ali’nin sözü doğru çıkar.',
    ],
    explanation: 'Kurabiyeyi Ece aldıysa Ali doğru, Ece ve Can yanlış söyler; yalnız bir ifade doğrudur.',
    points: 140,
    difficulty: 3,
    skill: 'Olasılıkları eleme',
  ),
  Puzzle(
    id: 'gizem-02',
    title: 'Müze alarmı',
    mode: PuzzleMode.mystery,
    question: 'Alarm 20.00’de çaldı. Güvenlik 20.10’da geldi. Kamera 20.05’te salonun boş olduğunu gösteriyor. Hırsızın giriş saati çıkarılabilir mi?',
    options: [
      '20.00’den önce',
      '20.05 ile 20.10 arasında',
      '20.10’dan sonra',
      'Kesin olarak bilinemez',
    ],
    answers: ['Kesin olarak bilinemez'],
    hints: [
      'Bir görüntü yalnızca kaydedildiği anı gösterir.',
      '20.05’te salonun boş olması tek başına giriş saatini söylemez.',
      'Kesin bir saat çıkarılamaz.',
    ],
    explanation: 'Tek bir kamera karesi giriş anını kanıtlamaz; verilen bilgilerle saat belirlenemez.',
    points: 120,
    difficulty: 2,
    skill: 'Kanıtın sınırlarını fark etme',
  ),
  Puzzle(
    id: 'gizem-03',
    title: 'Islak ayak izi',
    mode: PuzzleMode.mystery,
    question: 'Yağmurdan sonra ıslak izler doğrudan bahçe kapısına ulaşıyor. Kütüphane kapısının önü kuru. Hangi giriş daha olası?',
    options: [
      'Bahçe kapısı',
      'Kütüphane kapısı',
      'Çatı penceresi',
      'Kesin olarak bilinemez',
    ],
    answers: ['Bahçe kapısı'],
    hints: [
      'Islak izlerin yönünü takip et.',
      'İzler bahçe kapısına ulaşıyor.',
      'Kanıt bahçe girişini destekliyor.',
    ],
    explanation: 'Islak ayak izleri doğrudan bahçe kapısına ulaştığı için bu giriş daha olasıdır.',
    points: 120,
    difficulty: 2,
    skill: 'Kanıtları birleştirme',
  ),
  Puzzle(
    id: 'gizem-04',
    title: 'Üç kutu',
    mode: PuzzleMode.mystery,
    question: 'Anahtar üç kutudan birinde. A etiketi “Anahtar burada değil”, B “Anahtar A’da”, C “Anahtar B’de” diyor. Yalnız bir etiket doğruysa anahtar nerede?',
    options: ['A kutusunda', 'B kutusunda', 'C kutusunda', 'Bilgi yetmez'],
    answers: ['C kutusunda'],
    hints: [
      'Her kutuyu olasılık olarak dene.',
      'Anahtar A’da olursa iki etiket doğru olur.',
      'C’de olursa sadece A etiketi doğru olur.',
    ],
    explanation:
        'Anahtar C’deyse yalnız A etiketi doğru; böylece koşul sağlanır.',
    points: 150,
    difficulty: 4,
    skill: 'Tutarlılık kontrolü',
  ),
  Puzzle(
    id: 'gizem-05',
    title: 'Kapalı oda',
    mode: PuzzleMode.mystery,
    question: 'Kilitli odada zorlama izi yok, yerde su var ve masada erimiş buz duruyor. En makul olasılık hangisi?',
    options: [
      'Buzdan anahtar kullanılmış olabilir',
      'Kesinlikle pencereden girildi',
      'Kapı kırılarak açıldı',
      'Bir kişi içeri girmedi',
    ],
    answers: ['Buzdan anahtar kullanılmış olabilir'],
    hints: [
      'Eriyen buz hangi izi ortadan kaldırabilir?',
      'Buz eriyince yerde su kalır.',
      'Bu makul bir olasılıktır, kesin kanıt değildir.',
    ],
    explanation: 'Buzdan yapılmış bir anahtar eriyerek kaybolmuş olabilir; ipuçları bunun kesin olduğunu kanıtlamaz.',
    points: 160,
    difficulty: 4,
    skill: 'Alternatif açıklama kurma',
  ),

  Puzzle(
    id: 'hafiza-01',
    title: 'Üç sembol',
    mode: PuzzleMode.memory,
    question: 'Sembollere birkaç saniye bak; sonra sırayı hatırla.',
    options: ['▲ → ● → ■', '● → ▲ → ■', '▲ → ■ → ●', '■ → ● → ▲'],
    answers: ['▲ → ● → ■'],
    hints: [
      'Önce ilk sembolü zihninde tut.',
      'Ortadaki sembol daireydi.',
      'Sıra üçgen, daire, kare.',
    ],
    explanation: 'Sırayı doğru hatırladın. Bu tur kısa bilgiyi koruyup geri çağırmayı çalıştırır.',
    points: 100,
    difficulty: 1,
    skill: 'Sıralı görsel hafıza',
    memorySequence: ['▲', '●', '■'],
  ),
  Puzzle(
    id: 'hafiza-02',
    title: 'Renk sırası',
    mode: PuzzleMode.memory,
    question:
        'Renkli sembol dizisini incele, sonra seçeneklerden aynısını seç.',
    options: ['🔵 → 🟡 → 🔴', '🟡 → 🔵 → 🔴', '🔵 → 🔴 → 🟡', '🔴 → 🟡 → 🔵'],
    answers: ['🔵 → 🟡 → 🔴'],
    hints: [
      'İlk rengi aklında tut.',
      'Sarı, maviden sonra geliyordu.',
      'Son renk kırmızıydı.',
    ],
    explanation: 'Üç renkli sırayı doğru geri çağırdın.',
    points: 110,
    difficulty: 2,
    skill: 'Renkli görsel hafıza',
    memorySequence: ['🔵', '🟡', '🔴'],
  ),
  Puzzle(
    id: 'hafiza-03',
    title: 'Dört adımlı dizi',
    mode: PuzzleMode.memory,
    question: 'Sıra gizlenmeden önce dikkatlice incele.',
    options: [
      '★ → ▲ → ● → ■',
      '★ → ● → ▲ → ■',
      '▲ → ★ → ● → ■',
      '★ → ▲ → ■ → ●',
    ],
    answers: ['★ → ▲ → ● → ■'],
    hints: [
      'Başlangıç yıldızdı.',
      'İkinci şekil üçgendi.',
      'Son iki şekil daire ve kare.',
    ],
    explanation: 'Dört şeklin sırasını hatırladın.',
    points: 120,
    difficulty: 3,
    skill: 'Çalışma belleği',
    memorySequence: ['★', '▲', '●', '■'],
  ),
  Puzzle(
    id: 'hafiza-04',
    title: 'Değişimi yakala',
    mode: PuzzleMode.memory,
    question: 'Kısa süre gösterilen sembol sırasını aklında tut.',
    options: [
      '● → ● → ▲ → ★',
      '● → ▲ → ● → ★',
      '▲ → ● → ● → ★',
      '● → ● → ★ → ▲',
    ],
    answers: ['● → ● → ▲ → ★'],
    hints: [
      'İlk iki şekil aynıydı.',
      'Üçüncü şekil üçgen.',
      'Sıra iki daire, üçgen, yıldız.',
    ],
    explanation: 'Tekrar eden şekli ve son iki değişimi doğru hatırladın.',
    points: 130,
    difficulty: 3,
    skill: 'Dikkat ve sıra hafızası',
    memorySequence: ['●', '●', '▲', '★'],
  ),
  Puzzle(
    id: 'hafiza-05',
    title: 'Beş sembol',
    mode: PuzzleMode.memory,
    question: 'Bu uzun sırayı incele; gizlenince doğru seçeneği bul.',
    options: [
      '▲ → ★ → ● → ◆ → ■',
      '▲ → ● → ★ → ◆ → ■',
      '★ → ▲ → ● → ■ → ◆',
      '▲ → ★ → ◆ → ● → ■',
    ],
    answers: ['▲ → ★ → ● → ◆ → ■'],
    hints: [
      'İlk iki sembol üçgen ve yıldız.',
      'Ortada daire var.',
      'Son iki sembol baklava ve kare.',
    ],
    explanation: 'Beş sembollü sırayı doğru geri çağırdın.',
    points: 150,
    difficulty: 4,
    skill: 'Yoğun dikkat ve çalışma belleği',
    memorySequence: ['▲', '★', '●', '◆', '■'],
  ),
];

bool validatePuzzleBank(Iterable<Puzzle> puzzles) {
  final list = puzzles.toList();
  if (list.isEmpty) return false;
  final ids = <String>{};
  for (final puzzle in list) {
    final commonInvalid =
        puzzle.id.trim().isEmpty ||
        !ids.add(puzzle.id) ||
        puzzle.title.trim().isEmpty ||
        puzzle.question.trim().isEmpty ||
        puzzle.explanation.trim().isEmpty ||
        puzzle.skill.trim().isEmpty ||
        puzzle.hints.length != 3 ||
        puzzle.hints.any((hint) => hint.trim().isEmpty) ||
        puzzle.points <= 0 ||
        puzzle.difficulty < 1 ||
        puzzle.difficulty > 5;
    if (commonInvalid) return false;
    if (puzzle.isDifferencePuzzle) {
      if (puzzle.differenceLeft.length != 9 ||
          puzzle.differenceRight.length != 9) {
        return false;
      }
      final actualDifferences = <int>[
        for (var i = 0; i < puzzle.differenceLeft.length; i++)
          if (puzzle.differenceLeft[i] != puzzle.differenceRight[i]) i,
      ];
      final selected = puzzle.differencePositions.toSet();
      final actual = actualDifferences.toSet();
      if (puzzle.mode != PuzzleMode.visual ||
          puzzle.options.isNotEmpty ||
          puzzle.answers.isNotEmpty ||
          puzzle.differenceLeft.length != 9 ||
          puzzle.differenceRight.length != 9 ||
          puzzle.differencePositions.length != 3 ||
          selected.length != 3 ||
          selected.difference(actual).isNotEmpty ||
          actual.difference(selected).isNotEmpty ||
          [
            ...puzzle.differenceLeft,
            ...puzzle.differenceRight,
          ].any((item) => item < 0 || item > 13)) {
        return false;
      }
    } else if (puzzle.differenceLeft.isNotEmpty ||
        puzzle.differenceRight.isNotEmpty ||
        puzzle.differencePositions.isNotEmpty) {
      return false;
    } else if (puzzle.mode == PuzzleMode.moves) {
      if (puzzle.slideStart.length != 9 ||
          puzzle.slideStart.toSet().length != 9 ||
          puzzle.slideStart.toSet().difference({
            0,
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
          }).isNotEmpty ||
          puzzle.moveLimit < 2)
        return false;
    } else {
      final uniqueOptions = puzzle.options
          .map((option) => option.trim())
          .toSet();
      if (puzzle.options.length != 4 ||
          puzzle.options.any((option) => option.trim().isEmpty) ||
          uniqueOptions.length != puzzle.options.length ||
          puzzle.answers.isEmpty ||
          puzzle.options.where(puzzle.accepts).length != 1)
        return false;
    }
    if ((puzzle.mode == PuzzleMode.memory &&
            puzzle.memorySequence.length < 3) ||
        (puzzle.mode != PuzzleMode.memory && puzzle.memorySequence.isNotEmpty))
      return false;
  }
  return list.length >= 25 &&
      list.map((puzzle) => puzzle.mode).toSet().length == 5;
}
