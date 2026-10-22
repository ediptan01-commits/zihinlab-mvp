import '../models/puzzle.dart';
const puzzleBank = <Puzzle>[
 Puzzle(id:'desen-01',title:'Sayı dizisi',category:'DESENLER',question:'2, 6, 12, 20, 30, ?\n\nSıradaki sayı kaçtır?',answers:['42'],hints:['Ardışık sayıların arasındaki farklara bak.','Farklar 4, 6, 8 ve 10 şeklinde artıyor.','Bir sonraki fark 12; 30 + 12 = 42.'],explanation:'Farklar sırasıyla 4, 6, 8, 10 ve 12’dir. Her adımda fark 2 artar; cevap 42.',points:100),
 Puzzle(id:'mantik-01',title:'Üç anahtar',category:'AKIL YÜRÜTME',question:'Bir odanın dışında üç anahtar, içeride tek bir ampul var. Odaya yalnızca bir kez girebilirsin. Hangi anahtarın ampule bağlı olduğunu nasıl anlarsın?',answers:['isik ve sicaklik','ampulun sicakligindan','ampul sıcaklığından'],hints:['Ampulün ışığı dışında bir özelliğini de kullanabilirsin.','Isı, daha önce çalışıp çalışmadığını gösterir.','Bir anahtarı birkaç dakika açık tut, kapat; ikinciyi aç ve odaya gir.'],explanation:'İkinci anahtar açıksa ampul yanar. Kapalı ama sıcaksa ilk anahtara bağlıdır. Kapalı ve soğuksa üçüncü anahtardır.',points:150),
 Puzzle(id:'kelime-01',title:'Eksik harf',category:'KELİME OYUNU',question:'KAR kelimesinin sonuna bir harf ekleyince bir taşıt adı oluşur. Hangi harfi eklersin?',answers:['t'],hints:['Taşıtın iki tekerleği olabilir.','Kelime KART olur.','Cevap T harfidir.'],explanation:'KAR kelimesinin sonuna T ekleyince KART oluşur; bu bir taşıt adıdır.',points:80),
];
bool validatePuzzleBank(Iterable<Puzzle> puzzles) {
 final list=puzzles.toList(); if(list.isEmpty)return false; final ids=<String>{};
 for(final p in list){if(p.id.trim().isEmpty||!ids.add(p.id)||p.title.trim().isEmpty||p.question.trim().isEmpty||p.explanation.trim().isEmpty||p.answers.isEmpty||p.answers.any((a)=>a.trim().isEmpty)||p.hints.length!=3||p.hints.any((h)=>h.trim().isEmpty)||p.points<=0)return false;} return true;
}
