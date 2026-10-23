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
      final dayOfYear = DateTime(
        today.year,
        today.month,
        today.day,
      ).difference(DateTime(today.year, 1, 1)).inDays;
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
    final choices = due.isNotEmpty
        ? due
        : unsolved.isNotEmpty
        ? unsolved
        : candidates;
    final target = progress.targetDifficulty(mode);
    choices.sort((a, b) {
      final distance = (a.difficulty - target).abs().compareTo(
        (b.difficulty - target).abs(),
      );
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
      final points =
          (puzzle.points * stars ~/ 3) + (_mode == PuzzleMode.daily ? 50 : 0);
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
    final adjacent =
        (sameRow && (index - empty).abs() == 1) || (index - empty).abs() == 3;
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
            .where(
              (item) =>
                  item.mode == _mode && _progress.solved.containsKey(item.id),
            )
            .length;

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: ink,
        body: Center(
          child: CircularProgressIndicator(color: cyan, strokeWidth: 2.5),
        ),
      );
    }
    final level = (_coreSolvedCount ~/ 5) + 1;
    final dailyDone = _progress.dailyCompletions.contains(
      dateKey(DateTime.now()),
    );
    return Scaffold(
      backgroundColor: ink,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0B1228), ink, Color(0xFF080B19)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      purple.withValues(alpha: .12),
                      purple.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                _header(),
                const SizedBox(height: 24),
                _welcome(level),
                const SizedBox(height: 17),
                _progressOverview(),
                const SizedBox(height: 25),
                _sectionLabel(
                  'BİR BECERİ SEÇ',
                  'Her mod farklı bir düşünme biçimi çalıştırır.',
                ),
                const SizedBox(height: 12),
                _modeSelector(),
                const SizedBox(height: 24),
                if (_mode == PuzzleMode.daily) _dailyBanner(dailyDone),
                _questionCard(),
                const SizedBox(height: 14),
                if (puzzle.mode == PuzzleMode.memory) _memoryPanel(),
                if (puzzle.mode == PuzzleMode.moves) _slidingBoard(),
                if (puzzle.mode != PuzzleMode.moves && !_memoryVisible)
                  _answerPanel(),
                if (!_complete && !_memoryVisible) _actionRow(),
                if (_hintsUsed > 0) _hintPanel(),
                if (_complete) _successPanel(),
                if (!_complete && _wrongAnswers > 0) _retryPanel(),
                const SizedBox(height: 22),
                _footerStatus(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcome(int level) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GÜNLÜK ANTRENMAN',
              style: TextStyle(
                color: cyan,
                fontSize: 10,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Bulmaca zamanı',
              style: TextStyle(
                fontSize: 28,
                height: 1.08,
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'Küçük bir meydan okuma, güçlü bir odak.',
              style: TextStyle(
                color: Color(0xFF9BA7C1),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: purple.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: purple.withValues(alpha: .35)),
        ),
        child: Column(
          children: [
            Text(
              level.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: purple,
                fontSize: 19,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'SEVİYE',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 8,
                letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _progressOverview() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF17213B), Color(0xFF111A30)],
      ),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: const Color(0xFF263653)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İLERLEMEN',
                    style: TextStyle(
                      color: Color(0xFF9BA7C1),
                      fontSize: 9,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _coreSolvedCount.toString() +
                        ' / ' +
                        puzzleBank.length.toString() +
                        ' bulmaca',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _metric(
              Icons.bolt_rounded,
              _progress.score.toString(),
              'PUAN',
              const Color(0xFFFFC85C),
            ),
            const SizedBox(width: 8),
            _metric(
              Icons.local_fire_department_rounded,
              _progress.dailyStreak().toString(),
              'SERİ',
              const Color(0xFFFF8A61),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: _coreSolvedCount / puzzleBank.length,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: .07),
            valueColor: const AlwaysStoppedAnimation<Color>(cyan),
          ),
        ),
      ],
    ),
  );

  Widget _metric(IconData icon, String value, String label, Color color) =>
      Container(
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: .85),
                fontSize: 7,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  Widget _sectionLabel(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE8EEFB),
          fontSize: 11,
          letterSpacing: 1.35,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF8491AC),
          fontSize: 11,
          height: 1.35,
        ),
      ),
    ],
  );

  Widget _footerStatus() => Column(
    children: [
      Text(
        _mode == PuzzleMode.daily
            ? 'Günlük seri  ·  ' + _progress.dailyStreak().toString() + ' gün'
            : _mode.title +
                  '  ·  ' +
                  _modeSolvedCount.toString() +
                  ' / 5 tamamlandı',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF8793AA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 15),
      Container(height: 1, color: Colors.white.withValues(alpha: .06)),
      const SizedBox(height: 13),
      const Text(
        'ZihinLab düşünme ve dikkat pratiği sunar; genel zekânın artacağını garanti etmez.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF626E87), fontSize: 10, height: 1.45),
      ),
    ],
  );

  Widget _header() => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cyan, Color(0xFF698CFF), purple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cyan.withValues(alpha: .18),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.psychology_alt_rounded, color: ink, size: 27),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ZihinLab',
              style: TextStyle(
                fontSize: 21,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -.35,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'ZİHNİNİ ÇALIŞTIR',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 2.1,
                color: cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      _pill(Icons.stars_rounded, _progress.totalStars.toString()),
    ],
  );

  Widget _modeSelector() => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 9.0;
      final width = (constraints.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: PuzzleMode.values
            .map((mode) => _modeCard(mode, width))
            .toList(),
      );
    },
  );

  Widget _modeCard(PuzzleMode mode, double width) {
    final selected = mode == _mode;
    return SizedBox(
      width: width,
      height: 77,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),
          onTap: () => _changeMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        cyan.withValues(alpha: .2),
                        cyan.withValues(alpha: .08),
                      ],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF141D34), Color(0xFF11192E)],
                    ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected
                    ? cyan.withValues(alpha: .62)
                    : const Color(0xFF26324A),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: cyan.withValues(alpha: .07),
                        blurRadius: 15,
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _modeIcon(mode),
                      size: 17,
                      color: selected ? cyan : const Color(0xFFAAB5CC),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: cyan,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  mode.shortTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFFEAFBFF)
                        : const Color(0xFFD3D9E8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _modeIcon(PuzzleMode mode) => switch (mode) {
    PuzzleMode.logic => Icons.psychology_alt_rounded,
    PuzzleMode.moves => Icons.grid_view_rounded,
    PuzzleMode.visual => Icons.auto_awesome_rounded,
    PuzzleMode.mystery => Icons.manage_search_rounded,
    PuzzleMode.memory => Icons.memory_rounded,
    PuzzleMode.daily => Icons.today_rounded,
  };

  Widget _dailyBanner(bool done) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF251D45), Color(0xFF171B36)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: purple.withValues(alpha: .38)),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: purple.withValues(alpha: .17),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.today_rounded, color: purple, size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            done
                ? 'Bugünün meydan okuması tamamlandı.'
                : 'Günün özel bulmacasını çöz, 50 bonus puan kazan.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFFE1DCF6),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _progress.dailyStreak().toString() + ' 🔥',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  Widget _questionCard() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF17213A), Color(0xFF11192E), Color(0xFF10182D)],
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: cyan.withValues(alpha: .25)),
      boxShadow: [
        BoxShadow(
          color: cyan.withValues(alpha: .055),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        children: [
          Positioned(
            top: -44,
            right: -24,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cyan.withValues(alpha: .09),
                      cyan.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _category(puzzle.mode.shortTitle.toUpperCase()),
                    const SizedBox(width: 7),
                    _difficultyTag(),
                    const Spacer(),
                    const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFFFD15C),
                      size: 17,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      puzzle.points.toString(),
                      style: const TextStyle(
                        color: Color(0xFFD5DDF0),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                Text(
                  puzzle.title,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  puzzle.question,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.55,
                    color: Color(0xFFD5DDEF),
                  ),
                ),
                if (puzzle.mode != PuzzleMode.moves) ...[
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: cyan.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cyan.withValues(alpha: .13)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.track_changes_rounded,
                          color: cyan,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Çalışan beceri  ·  ' + puzzle.skill,
                            style: const TextStyle(
                              color: Color(0xFF9FEAFF),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _difficultyTag() {
    final label = switch (puzzle.difficulty) {
      1 => 'BAŞLANGIÇ',
      2 => 'ORTA',
      3 => 'İLERİ',
      4 => 'UZMAN',
      _ => 'USTA',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF9CA9C0),
          fontSize: 7,
          letterSpacing: .7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _memoryPanel() {
    final shown = _memoryVisible;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF241E43), Color(0xFF171A32)],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: purple.withValues(alpha: .32)),
      ),
      child: Column(
        children: [
          Text(
            shown ? 'SIRAYI İNCELE' : 'SIRA GİZLENDİ',
            style: const TextStyle(
              color: Color(0xFFC4A9FF),
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            shown
                ? puzzle.memorySequence.join('   ')
                : 'Şimdi hatırladığın sırayı seç.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          if (shown) ...[
            const SizedBox(height: 8),
            const Text(
              'Dört saniye sonra gizlenir.',
              style: TextStyle(color: Color(0xFFA6A0BA), fontSize: 11),
            ),
            const SizedBox(height: 3),
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
        padding: EdgeInsets.only(bottom: 10),
        child: Text(
          'BİR CEVAP SEÇ',
          style: TextStyle(
            color: Color(0xFF9BA7BE),
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      for (var i = 0; i < puzzle.options.length; i++)
        _answerOption(i, puzzle.options[i]),
    ],
  );

  Widget _answerOption(int index, String option) {
    final selected = _selectedAnswer == option;
    final correctAnswer = _complete && puzzle.accepts(option);
    final accent = correctAnswer ? const Color(0xFF65E3B0) : cyan;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: _complete
              ? null
              : () => setState(() => _selectedAnswer = option),
          borderRadius: BorderRadius.circular(17),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        accent.withValues(alpha: .14),
                        accent.withValues(alpha: .07),
                      ],
                    )
                  : null,
              color: selected ? null : const Color(0xFF121B30),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected || correctAnswer
                    ? accent.withValues(alpha: .72)
                    : const Color(0xFF27344C),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: .07),
                        blurRadius: 14,
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected || correctAnswer
                        ? accent.withValues(alpha: .13)
                        : Colors.white.withValues(alpha: .035),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected || correctAnswer
                          ? accent.withValues(alpha: .6)
                          : const Color(0xFF46516A),
                    ),
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      color: selected || correctAnswer
                          ? accent
                          : const Color(0xFFAAB5CA),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Color(0xFFE0E6F3),
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (correctAnswer)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF65E3B0),
                    size: 19,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slidingBoard() => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hamle: ' +
                  _moves.toString() +
                  ' / ' +
                  puzzle.moveLimit.toString(),
            ),
            const Text(
              'Komşu taşı kaydır',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
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
                  border: Border.all(
                    color: value == 0
                        ? Colors.white10
                        : cyan.withValues(alpha: .3),
                  ),
                ),
                child: value == 0
                    ? const SizedBox.shrink()
                    : Text(
                        value.toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: cyan,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    ],
  );

  Widget _actionRow() => Padding(
    padding: const EdgeInsets.only(top: 1),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _hintsUsed < 3 ? _showNextHint : null,
            icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
            label: Text(
              _hintsUsed < 3
                  ? 'İpucu  ' + (3 - _hintsUsed).toString()
                  : 'Bitti',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFC2A5FF),
              side: BorderSide(color: purple.withValues(alpha: .48)),
              backgroundColor: purple.withValues(alpha: .045),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (puzzle.mode != PuzzleMode.moves) ...[
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: _selectedAnswer == null ? null : _submitAnswer,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Kontrol et'),
              style: FilledButton.styleFrom(
                backgroundColor: cyan,
                foregroundColor: ink,
                disabledBackgroundColor: const Color(0xFF283047),
                disabledForegroundColor: const Color(0xFF777F93),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _hintPanel() {
    final children = <Widget>[];
    for (var i = 0; i < _hintsUsed; i++) {
      final title = i == 0
          ? 'Küçük ipucu'
          : i == 1
          ? 'Çözüm yöntemi'
          : 'Bir adım daha';
      children.add(
        Container(
          margin: const EdgeInsets.only(top: 9),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF211C3D),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: purple.withValues(alpha: .26)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: .17),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: Color(0xFFC2A5FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title + '  ·  ' + puzzle.hints[i],
                  style: const TextStyle(
                    color: Color(0xFFE4DFF3),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _retryPanel() => Container(
    margin: const EdgeInsets.only(top: 13),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF2A211F),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFA673).withValues(alpha: .26)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.tips_and_updates_outlined,
          color: Color(0xFFFFB16F),
          size: 19,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Henüz değil; doğru cevabı açıklamadan küçük bir ipucu verdim. Bir seçenek daha dene.',
            style: TextStyle(
              color: Color(0xFFFFC28C),
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _successPanel() => Container(
    margin: const EdgeInsets.only(top: 13),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF142E31), Color(0xFF12262D)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFF65E3B0).withValues(alpha: .34)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.celebration_rounded,
              color: Color(0xFF65E3B0),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _alreadySolved
                    ? 'Bu bulmacayı daha önce tamamladın.'
                    : 'Harika, doğru cevap!  ' +
                          List<String>.filled(_earnedStars(), '★').join(),
                style: const TextStyle(
                  color: Color(0xFF7DEBC0),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          puzzle.explanation,
          style: const TextStyle(
            color: Color(0xFFE0EBE8),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cyan.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            'Bu turda çalıştırdığın beceri: ' + puzzle.skill,
            style: const TextStyle(
              color: Color(0xFF9FEAFF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 5),
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
    decoration: BoxDecoration(
      color: cyan.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: cyan,
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
