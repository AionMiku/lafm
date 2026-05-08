import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbeehBeadsRing extends StatefulWidget {
  final int count;
  final VoidCallback onIncrement;
  final bool isTapMode;
  final bool isVibrationEnabled;

  const TasbeehBeadsRing({
    super.key,
    required this.count,
    required this.onIncrement,
    this.isTapMode = false,
    this.isVibrationEnabled = true,
  });

  @override
  State<TasbeehBeadsRing> createState() => _TasbeehBeadsRingState();
}

class _TasbeehBeadsRingState extends State<TasbeehBeadsRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Allow downward dragging
      if (details.delta.dy > 0) {
         _dragOffset += details.delta.dy;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.isTapMode) return; // ignore slide if tap mode
    
    // Sensitivity reduced from 30 to 15 for smoother slide
    if (_dragOffset > 15) {
      if (widget.isVibrationEnabled) HapticFeedback.lightImpact();
      widget.onIncrement();
    }
    
    // Animate back to original position
    _controller.forward(from: 0).then((_) {
      setState(() {
        _dragOffset = 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: widget.isTapMode ? null : _onPanUpdate,
      onPanEnd: widget.isTapMode ? null : _onPanEnd,
      onTap: widget.isTapMode 
          ? () {
              if (widget.isVibrationEnabled) HapticFeedback.lightImpact();
              widget.onIncrement();
            }
          : null,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 15,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Count Display
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text(
                  'Tasbeeh',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            
            // Interactive Drag Bead
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Return to center when animation plays
                double currentOffset = _dragOffset * (1 - _controller.value);
                
                return Positioned(
                  top: 15 + currentOffset, // Start near the top
                  child: Container(
                    width: 30,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
