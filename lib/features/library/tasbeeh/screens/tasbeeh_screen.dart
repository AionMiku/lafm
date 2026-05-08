import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/settings/theme_controller.dart';
import '../widgets/beads_ring.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _count = 0;
  bool _isTapMode = false;
  bool _isVibrationEnabled = true;

  void _incrementCount() {
    setState(() {
      _count++;
    });
  }

  void _resetCount() {
    setState(() {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Tasbeeh'),
        actions: [
          // Vibration Toggle
          IconButton(
            icon: Icon(_isVibrationEnabled ? Icons.vibration : Icons.smartphone),
            tooltip: _isVibrationEnabled ? 'Vibration On' : 'Vibration Off',
            onPressed: () {
              setState(() => _isVibrationEnabled = !_isVibrationEnabled);
            },
          ),
          // Mode Toggle
          IconButton(
            icon: Icon(_isTapMode ? Icons.touch_app : Icons.swipe_down),
            tooltip: _isTapMode ? 'Tap Mode' : 'Slide Mode',
            onPressed: () {
              setState(() => _isTapMode = !_isTapMode);
            },
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetCount,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'سبحان الله',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri', // Assuming an Arabic font is available
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Subhan Allah',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            
            // Interactive Ring Component
            TasbeehBeadsRing(
              count: _count,
              onIncrement: _incrementCount,
              isTapMode: _isTapMode,
              isVibrationEnabled: _isVibrationEnabled,
            ),
            
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _isTapMode ? 'Tap anywhere on the ring to count' : 'Drag the bead downwards to count',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
