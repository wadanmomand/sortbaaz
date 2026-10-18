import 'package:flutter/material.dart';
import '../game/sort_game.dart';
import '../game/progress.dart';
import '../game/sound_service.dart';
import 'game_screen.dart';
import 'painters.dart';

/// Home screen: logo, play button, level grid, coins, daily challenge.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Progress? _progress;

  @override
  void initState() {
    super.initState();
    Progress.load().then((p) => setState(() => _progress = p));
  }

  /// Daily challenge level: derived from date (1-10000).
  int get dailyLevel {
    final now = DateTime.now();
    final dayOfYear =
        now.difference(DateTime(now.year, 1, 1)).inDays + 1;
    return ((now.year * 366 + dayOfYear) % 10000) + 1;
  }

  String get todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get dailyDone => _progress?.dailyDone == todayStr;

  void _playLevel(int level) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
              builder: (_) =>
                  GameScreen(level: level, progress: _progress)),
        )
        .then((_) => setState(() {})); // refresh coins on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1330)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              // Logo: mini arrows + title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final c in [
                    ArrowColor.red,
                    ArrowColor.blue,
                    ArrowColor.green,
                    ArrowColor.yellow,
                  ])
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      child: CustomPaint(
                        size: const Size(36, 56),
                        painter: ArrowPainter(c),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'SORTBAAZ',
                style: TextStyle(
                  color: Color(0xFFFFD54F),
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 3)),
                  ],
                ),
              ),
              const Text(
                'Sort the arrows. Clear the tubes.',
                style:
                    TextStyle(color: Colors.white60, fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Big PLAY button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 72, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                onPressed: () =>
                    _playLevel((_progress?.completedUpTo ?? 0) + 1),
                child: const Text('PLAY',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              // Daily challenge button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: dailyDone
                      ? Colors.white38
                      : const Color(0xFFFFD54F),
                  side: BorderSide(
                      color: dailyDone
                          ? Colors.white24
                          : const Color(0xFFFFD54F)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                icon: Icon(dailyDone
                    ? Icons.check_circle
                    : Icons.calendar_today),
                label: Text(dailyDone
                    ? 'DAILY DONE ✓'
                    : 'DAILY CHALLENGE'),
                onPressed: dailyDone
                    ? null
                    : () => _playDaily(context),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showLevels(context),
                child: const Text('SELECT LEVEL',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 16)),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text('10,000 levels • Offline • Free',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Stats button
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white70),
            onPressed: () {
              SoundService().button();
              _showStats(context);
            },
          ),
          // Coins pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on,
                    color: Color(0xFFFFD54F), size: 20),
                const SizedBox(width: 6),
                Text('${_progress?.coins ?? 0}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          // Sound toggle
          IconButton(
            icon: Icon(
              SoundService().enabled
                  ? Icons.volume_up
                  : Icons.volume_off,
              color: Colors.white70,
            ),
            onPressed: () async {
              final newVal = !SoundService().enabled;
              await SoundService().setEnabled(newVal);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _playDaily(BuildContext context) async {
    await _progress?.markDailyDone(todayStr);
    _playLevel(dailyLevel);
  }

  void _showStats(BuildContext context) {
    final p = _progress;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Stats',
            style: TextStyle(color: Color(0xFFFFD54F)),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('Levels completed', '${p?.completedUpTo ?? 0}'),
            _statRow('Total moves', '${p?.totalMoves ?? 0}'),
            _statRow('Hints used', '${p?.hintsUsed ?? 0}'),
            _statRow('Coins', '${p?.coins ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE',
                style: TextStyle(color: Color(0xFFFFD54F))),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  void _showLevels(BuildContext context) {
    final completed = _progress?.completedUpTo ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A237E),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Select Level',
                  style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: 100,
                itemBuilder: (_, i) {
                  final lvl = i + 1;
                  final done = lvl <= completed;
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      _playLevel(lvl);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xFFFFD54F)
                                .withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: done
                                ? const Color(0xFFFFD54F)
                                : Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text('$lvl',
                            style: TextStyle(
                                color: done
                                    ? const Color(0xFFFFD54F)
                                    : Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Showing 1–100 of 10,000',
                  style:
                      TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
