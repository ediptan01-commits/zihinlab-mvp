import 'dart:async';

import 'package:flutter/material.dart';

import '../data/puzzle_bank.dart';
import '../models/puzzle.dart';
import '../services/progress_store.dart';

const cyan = Color(0xFF38D9FF);
const purple = Color(0xFF9B6BFF);
const panel = Color(0xFF111A32);
const ink = Color(0xFF080D20);

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ProgressStore _store = ProgressStore();
  PlayerProgress _progress = const PlayerProgress();
  PuzzleMode _mode = PuzzleMode.logic;
  Puzzle? _puzzle;
  List<int> _tiles = [];
  int _moves = 0;
  int _hintsUsed = 0;
  int _wrongAnswers = 0;
  String? _selectedAnswer;
  bool _ready = false;
  bool _memoryVisible = false;
  bool _complete = false;
  bool _alreadySolved = false;
  Timer? _memoryTimer;

  Puzzle get puzzle => _puzzle!;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProgress());
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final loaded = await _store.load();
    if (!mounted) return;
    _progress = loaded;
    _activatePuzzle(_choosePuzzle(_mode, loaded));
    setState(() => _ready = true);
  }

  Puzzle _choosePuzzle(PuzzleMode mode, PlayerProgress progress) {
    final today = DateTime.now();
    if (mode == PuzzleMode.daily) {
      final pool = puzzleBank.toList();
      final dayOfYear = DateTime(today.year, today.month, today.day)
          .difference(DateTime(today.year, 1, 1))
          .inDays;
      final chosen = pool[(dayOfYear + today.year * 13) % pool.length];
      return Puzzle(
        id: 'daily-' + dateKey(today),
        title: chosen.title,
        mode: chosen.mode,
        question: chosen.question,
        options: chosen.options,
        answers: chosen.answers,
        hints: chosen.hints,
        explanation: chosen.explanation,
        points: chosen.points + 25,
        skill: chosen.skill,
        difficulty: chosen.difficulty,
        slideStart: chosen.slideStart,
        moveLimit: chosen.moveLimit,
        memorySequence: chosen.memorySequence,
      );
    }

    final candidates = puzzleBank.where((item) => item.mode == mode).toList();
    if (candidates.isEmpty) return puzzleBank.first;
    final todayKey = dateKey(today);
    final due = candidates.where((item) {
      final dueDate = progress.reviewDue[item.id];
      return dueDate != null && dueDate.compareTo(todayKey) <= 0;
    }).toList();
    final unsolved = candidates
        .where((item) => !progress.solved.containsKey(item.id))
        .toList();
    final choices = due.isNotEmpty ? due : unsolved.isNotEmpty ? unsolved : candidates;
    final target = progress.targetDifficulty(mode);
    choices.sort((a, b) {
      final distance = (a.difficulty - target).abs().compareTo((b.difficulty - target).abs());
      if (distance != 0) return distance;
      return a.id.compareTo(b.id);
    });
    return choices.first;
  }

  void _activatePuzzle(Puzzle next) {
    _memoryTimer?.cancel();
    _puzzle = next;
    _tiles = List<int>.of(next.slideStart);
    _moves = 0;
    _hintsUsed = 0;
    _wrongAnswers = 0;
    _selectedAnswer = null;
    _complete = false;
    _alreadySolved = _progress.solved.containsKey(next.id);
    _memoryVisible = next.mode == PuzzleMode.memory && !_alreadySolved;
    if (_memoryVisible) {
      _memoryTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _memoryVisible = false);
      });
    }
  }

  void _changeMode(PuzzleMode mode) {
    if (mode == _mode || !_ready) return;
    setState(() {
      _mode = mode;
      _activatePuzzle(_choosePuzzle(mode, _progress));
    });
  }

  void _nextPuzzle() {
    setState(() => _activatePuzzle(_choosePuzzle(_mode, _progress)));
  }

  Future<void> _showNextHint() async {
    if (_hintsUsed >= 3 || _complete) return;
    setState(() => _hintsUsed++);
  }

  Future<void> _submitAnswer() async {
    final answer = _selectedAnswer;
    if (answer == null || _complete || _memoryVisible) return;
    if (puzzle.accepts(answer)) {
      final stars = _hintsUsed == 0 && _wrongAnswers == 0
          ? 3
          : _hintsUsed <= 1 && _wrongAnswers <= 1
              ? 2
              : 1;
      await _finishPuzzle(stars);
      return;
    }

    final now = DateTime.now();
    final updated = _progress.recordWrong(puzzle.id, puzzle.mode, now);
    if (mounted) {
      setState(() {
        _wrongAnswers++;
        if (_hintsUsed < 2) _hintsUsed++;
        _selectedAnswer = null;
        _progress = updated;
      });
    }
    await _store.save(updated);
  }

  Future<void> _finishPuzzle(int stars) async {
    final previouslyDone = _mode == PuzzleMode.daily
        ? _progress.dailyCompletions.contains(dateKey(DateTime.now()))
        : _progress.solved.containsKey(puzzle.id);
    var updated = _progress;
    if (!previouslyDone) {
      final points = (puzzle.points * stars ~/ 3) +
          (_mode == PuzzleMode.daily ? 50 : 0);
      updated = _progress.solve(
        puzzle.id,
        stars,
        points,
        mode: _mode,
        daily: _mode == PuzzleMode.daily,
      );
      await _store.save(updated);
    }
    if (!mounted) return;
    setState(() {
      _alreadySolved = previouslyDone;
      _complete = true;
      _progress = updated;
    });
  }

  Future<void> _slideTile(int index) async {
    if (_complete || _tiles.isEmpty || _tiles[index] == 0) return;
    final empty = _tiles.indexOf(0);
    final sameRow = index ~/ 3 == empty ~/ 3;
    final adjacent = (sameRow && (index - empty).abs() == 1) ||
        (index - empty).abs() == 3;
    if (!adjacent) return;
    final moved = List<int>.of(_tiles);
    moved[empty] = moved[index];
    moved[index] = 0;
    final nextMoves = _moves + 1;
    final solved = _isGoal(moved);
    setState(() {
      _tiles = moved;
      _moves = nextMoves;
    });
    if (solved) {
      final par = puzzle.moveLimit;
      final stars = nextMoves <= par && _hintsUsed == 0
          ? 3
          : nextMoves <= par * 2
              ? 2
              : 1;
      await _finishPuzzle(stars);
    }
  }

  bool _isGoal(List<int> board) {
    if (board.length != 9) return false;
    for (var i = 0; i < 8; i++) {
      if (board[i] != i + 1) return false;
    }
    return board[8] == 0;
  }

  int get _coreSolvedCount =>
      puzzleBank.where((item) => _progress.solved.containsKey(item.id)).length;

  int get _modeSolvedCount => _mode == PuzzleMode.daily
      ? (_progress.dailyCompletions.contains(dateKey(DateTime.now())) ? 1 : 0)
      : puzzleBank
          .where((item) => item.mode == _mode && _progress.solved.containsKey(item.id))
          .length;

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final level = (_coreSolvedCount ~/ 5) + 1;
    final dailyDone = _progress.dailyCompletions.contains(dateKey(DateTime.now()));
    return Scaffold(
      backgroundColor: ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _header(),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text('Bulmaca zamanı',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                ),
                Text('Seviye ' + level.toString(),
                    style: const TextStyle(color: purple, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              _coreSolvedCount.toString() + '/' + puzzleBank.length.toString() +
                  ' çözüldü  •  ' + _progress.score.toString() + ' puan',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _coreSolvedCount / puzzleBank.length,
                minHeight: 6,
                backgroundColor: Colors.white10,
                color: cyan,
              ),
            ),
            const SizedBox(height: 18),
            _modeSelector(),
            const SizedBox(height: 14),
            if (_mode == PuzzleMode.daily) _dailyBanner(dailyDone),
            _questionCard(),
            const SizedBox(height: 14),
            if (puzzle.mode == PuzzleMode.memory) _memoryPanel(),
            if (puzzle.mode == PuzzleMode.moves) _slidingBoard(),
            if (puzzle.mode != PuzzleMode.moves && !_memoryVisible) _answerPanel(),
            if (!_complete && !_memoryVisible) _actionRow(),
            if (_hintsUsed > 0) _hintPanel(),
            if (_complete) _successPanel(),
            if (!_complete && _wrongAnswers > 0) _retryPanel(),
            const SizedBox(height: 18),
            Text(
              _mode == PuzzleMode.daily
                  ? 'Günlük seri: ' + _progress.dailyStreak().toString() + ' gün'
                  : _mode.title + ' • ' + _modeSolvedCount.toString() + '/5 tamamlandı',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 14),
            const Text(
              'ZihinLab düşünme ve dikkat pratiği sunar; genel zekânın artacağını garanti etmez.',
              style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [cyan, purple]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.psychology_alt_rounded, color: ink),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ZihinLab', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                Text('ZİHNİNİ ÇALIŞTIR',
                    style: TextStyle(fontSize: 10, letterSpacing: 2, color: cyan)),
              ],
            ),
          ),
          _pill(Icons.stars_rounded, _progress.totalStars.toString()),
        ],
      );

  Widget _modeSelector() => Wrap(
        spacing: 7,
        runSpacing: 7,
        children: PuzzleMode.values.map((mode) {
          return ChoiceChip(
            label: Text(mode.shortTitle),
            selected: mode == _mode,
            onSelected: (_) => _changeMode(mode),
            selectedColor: cyan.withValues(alpha: .18),
            backgroundColor: panel,
            labelStyle: TextStyle(
              color: mode == _mode ? cyan : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(color: mode == _mode ? cyan.withValues(alpha: .55) : Colors.white12),
          );
        }).toList(),
      );

  Widget _dailyBanner(bool done) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: purple.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.today_rounded, color: purple),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                done
                    ? 'Bugünün meydan okuması tamamlandı.'
                    : 'Günün özel bulmacası • tamamla ve 50 bonus puan kazan.',
                style: const TextStyle(height: 1.35),
              ),
            ),
            Text(_progress.dailyStreak().toString() + ' 🔥',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _questionCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(21),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cyan.withValues(alpha: .25)),
          boxShadow: [BoxShadow(color: cyan.withValues(alpha: .07), blurRadius: 24)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _category(puzzle.mode.shortTitle.toUpperCase()),
                const Spacer(),
                Icon(Icons.bolt_rounded, color: Colors.amber.shade300, size: 18),
                const SizedBox(width: 4),
                Text(puzzle.points.toString() + ' puan',
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 18),
            Text(puzzle.title,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 11),
            Text(puzzle.question,
                style: const TextStyle(fontSize: 16, height: 1.55, color: Color(0xFFE1E7F5))),
            if (puzzle.mode != PuzzleMode.moves) ...[
              const SizedBox(height: 13),
              Text('Çalışan beceri: ' + puzzle.skill,
                  style: const TextStyle(color: cyan, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      );

  Widget _memoryPanel() {
    final shown = _memoryVisible;
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: purple.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Text(shown ? 'SIRAYI İNCELE' : 'SIRA GİZLENDİ',
              style: const TextStyle(color: purple, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            shown ? puzzle.memorySequence.join('   ') : 'Şimdi hatırladığın sırayı seç.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          if (shown) ...[
            const SizedBox(height: 10),
            const Text('Dört saniye sonra gizlenir.', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _memoryTimer?.cancel();
                setState(() => _memoryVisible = false);
              },
              child: const Text('Hazırım, gizle'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 9),
            child: Text('BİR CEVAP SEÇ',
                style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.3)),
          ),
          for (var i = 0; i < puzzle.options.length; i++) _answerOption(i, puzzle.options[i]),
        ],
      );

  Widget _answerOption(int index, String option) {
    final selected = _selectedAnswer == option;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: _complete ? null : () => setState(() => _selectedAnswer = option),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? cyan.withValues(alpha: .12) : panel,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selected ? cyan : Colors.white12),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? cyan : Colors.white24),
                ),
                child: Text(String.fromCharCode(65 + index),
                    style: TextStyle(color: selected ? cyan : Colors.white70)),
              ),
              const SizedBox(width: 11),
              Expanded(child: Text(option, style: const TextStyle(height: 1.35))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slidingBoard() => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(13)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hamle: ' + _moves.toString() + ' / ' + puzzle.moveLimit.toString()),
                const Text('Komşu taşı kaydır', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final value = _tiles[index];
              return Material(
                color: value == 0 ? Colors.white.withValues(alpha: .04) : panel,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () => unawaited(_slideTile(index)),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: value == 0 ? Colors.white10 : cyan.withValues(alpha: .3)),
                    ),
                    child: value == 0
                        ? const SizedBox.shrink()
                        : Text(value.toString(),
                            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: cyan)),
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _actionRow() => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _hintsUsed < 3 ? _showNextHint : null,
                icon: const Icon(Icons.lightbulb_outline),
                label: Text(_hintsUsed < 3 ? 'İpucu (' + (3 - _hintsUsed).toString() + ')' : 'İpuçları bitti'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: purple,
                  side: BorderSide(color: purple.withValues(alpha: .55)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (puzzle.mode != PuzzleMode.moves) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _selectedAnswer == null ? null : _submitAnswer,
                  style: FilledButton.styleFrom(
                    backgroundColor: cyan,
                    foregroundColor: ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Kontrol et', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _hintPanel() {
    final children = <Widget>[];
    for (var i = 0; i < _hintsUsed; i++) {
      final title = i == 0 ? 'Küçük ipucu' : i == 1 ? 'Çözüm yöntemi' : 'Bir adım daha';
      children.add(Container(
        margin: const EdgeInsets.only(top: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: purple.withValues(alpha: .3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, size: 18, color: purple),
            const SizedBox(width: 10),
            Expanded(child: Text(title + ': ' + puzzle.hints[i], style: const TextStyle(height: 1.4))),
          ],
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _retryPanel() => Container(
        margin: const EdgeInsets.only(top: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: .3)),
        ),
        child: const Text(
          'Henüz değil; doğru cevabı açıklamadan bir ipucu verdim. Bir seçenek daha dene.',
          style: TextStyle(color: Colors.orangeAccent, height: 1.4),
        ),
      );

  Widget _successPanel() => Container(
        margin: const EdgeInsets.only(top: 13),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.greenAccent.withValues(alpha: .35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _alreadySolved ? 'Bu bulmacayı daha önce tamamladın.' : 'Harika, doğru cevap!  ' + List<String>.filled(_earnedStars(), '★').join(),
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 9),
            Text(puzzle.explanation, style: const TextStyle(height: 1.45)),
            const SizedBox(height: 8),
            Text('Bu turda çalıştırdığın beceri: ' + puzzle.skill,
                style: const TextStyle(color: cyan, fontWeight: FontWeight.w600)),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _nextPuzzle,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Sonraki bulmaca'),
              ),
            ),
          ],
        ),
      );

  int _earnedStars() {
    if (puzzle.mode == PuzzleMode.moves) {
      if (_moves <= puzzle.moveLimit && _hintsUsed == 0) return 3;
      if (_moves <= puzzle.moveLimit * 2) return 2;
      return 1;
    }
    if (_hintsUsed == 0 && _wrongAnswers == 0) return 3;
    if (_hintsUsed <= 1 && _wrongAnswers <= 1) return 2;
    return 1;
  }

  Widget _pill(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: .13),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: purple.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber.shade300, size: 18),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _category(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: cyan.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: const TextStyle(color: cyan, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
      );
}
