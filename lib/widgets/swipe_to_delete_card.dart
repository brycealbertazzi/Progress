import 'package:flutter/material.dart';

class SwipeToDeleteCard extends StatefulWidget {
  const SwipeToDeleteCard({
    super.key,
    required this.onTap,
    required this.onDeleteConfirmed,
    required this.deleteTitle,
    required this.deleteMessage,
    required this.child,
    this.bottomMargin = 0.0,
  });

  final VoidCallback onTap;
  final VoidCallback onDeleteConfirmed;
  final String deleteTitle;
  final String deleteMessage;
  final Widget child;
  final double bottomMargin;

  @override
  State<SwipeToDeleteCard> createState() => _SwipeToDeleteCardState();
}

class _SwipeToDeleteCardState extends State<SwipeToDeleteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const double _actionWidth = 68.0;
  static const double _radius = 12.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dx < 0 || _controller.value > 0) {
      _controller.value =
          (_controller.value - d.delta.dx / _actionWidth).clamp(0.0, 1.0);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    if (d.velocity.pixelsPerSecond.dx < -300 || _controller.value > 0.5) {
      _controller.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  void _onTrashTapped() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(widget.deleteTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(
          widget.deleteMessage,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _controller.animateTo(0.0, curve: Curves.easeOut);
            },
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDeleteConfirmed();
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomMargin),
      child: GestureDetector(
        onTap: () {
          if (_controller.value > 0) {
            _controller.animateTo(0.0, curve: Curves.easeOut);
          } else {
            widget.onTap();
          }
        },
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Stack(
              children: [
                // Red trash area — sits behind the card, right-aligned
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: _actionWidth,
                      child: GestureDetector(
                        onTap: _onTrashTapped,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(_radius),
                              bottomRight: Radius.circular(_radius),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Card slides left; right corners transition from rounded to square
                Transform.translate(
                  offset: Offset(-_actionWidth * t, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(_radius),
                        bottomLeft: const Radius.circular(_radius),
                        topRight: Radius.circular(_radius * (1 - t)),
                        bottomRight: Radius.circular(_radius * (1 - t)),
                      ),
                    ),
                    child: child,
                  ),
                ),
              ],
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
