import 'package:flutter/material.dart';
import 'painters.dart';
import 'play_controller.dart';
import '../game/progress.dart';
import '../game/sound_service.dart';

/// Main gameplay screen: tubes of arrows, tap to sort.
class GameScreen extends StatefulWidget {
  final int level;
  final Progress? progress;

  const GameScreen({super.key, required this.level, this.progress});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PlayController _ctrl;
  bool _winSaved = false;

  @override
  void initState() {
    super.initState();
    _ctrl = PlayController(widget.level);
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    if (_ctrl.isWon && !_winSaved) {
      _winSaved = true;
      _saveWin();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _showWinDialog();
      });
    }
    setState(() {});
  }

  Future<void> _saveWin() async {
    final p = widget.progress;
    SoundService().win();
    if (p == null) return;
    await p.completeLevel(widget.level);
    await p.addMoves(_ctrl.moves);
    // Coin sound after win fanfare.
    Future.delayed(const Duration(milliseconds: 800), () {
      SoundService().coin();
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Level Complete!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
        content: Text('Level ${widget.level} solved in ${_ctrl.moves} moves!',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('MENU',
                style: TextStyle(color: Color(0xFFFFD54F))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: const Color(0xFF1A237E),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) =>
                        GameScreen(level: widget.level + 1)),
              );
            },
            child: const Text('NEXT'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tubeCount = _ctrl.game.tubeCount;
    // Responsive grid: 4-5 tubes per row.
    const perRow = 4;

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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < tubeCount; i++)
                          _buildTube(i, perRow),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'LEVEL ${widget.level}',
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_ctrl.moves} moves',
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTube(int index, int perRow) {
    final screenW = MediaQuery.of(context).size.width;
    final tubeW = (screenW - 32 - (perRow - 1) * 16) / perRow;
    final tubeH = tubeW * 3.2;
    final arrows = _ctrl.game.tubes[index];
    final isSelected = _ctrl.selectedTube == index;
    // Highlight if selected tube can move here.
    final canDrop = _ctrl.selectedTube != null &&
        _ctrl.selectedTube != index &&
        _ctrl.game.canMove(_ctrl.selectedTube!, index);
    // Hint highlight.
    final isHintFrom =
        _ctrl.hintMove != null && _ctrl.hintMove!.$1 == index;
    final isHintTo =
        _ctrl.hintMove != null && _ctrl.hintMove!.$2 == index;

    return GestureDetector(
      onTap: () => _ctrl.tapTube(index),
      child: SizedBox(
        width: tubeW,
        height: tubeH,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(tubeW, tubeH),
              painter: TubePainter(
                  highlighted: canDrop || isHintFrom || isHintTo,
                  selected: isSelected || isHintFrom),
            ),
            // Arrows stacked bottom-up.
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: tubeW * 0.2, vertical: tubeH * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (final color in arrows)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: CustomPaint(
                          size: Size(tubeW * 0.6, tubeH * 0.16),
                          painter: ArrowPainter(color),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionBtn(Icons.undo, 'Undo', _ctrl.canUndo, _ctrl.undo),
          _actionBtn(Icons.restart_alt, 'Restart', true, () {
            _ctrl.restart();
          }),
          _actionBtn(Icons.lightbulb_outline, 'Hint\n20 coins', true,
              () async {
            final p = widget.progress;
            if (p != null && p.coins < 20) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Not enough coins! Complete levels to earn more.')),
              );
              return;
            }
            if (_ctrl.showHint()) {
              if (p != null) {
                await p.spendCoins(20);
                await p.addHintUsed();
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Try the glowing tubes!'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hints available')),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon,
                  color: const Color(0xFF1A237E), size: 26),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
