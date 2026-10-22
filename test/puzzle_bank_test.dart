import 'package:flutter_test/flutter_test.dart';
import 'package:zihinlab/data/puzzle_bank.dart';
void main(){test('starter puzzle bank has unique IDs and complete content',(){expect(validatePuzzleBank(puzzleBank),isTrue);expect(puzzleBank.map((p)=>p.id).toSet().length,puzzleBank.length);});test('answer matching trims spaces and punctuation',(){expect(puzzleBank.first.accepts(' 42! '),isTrue);});}
