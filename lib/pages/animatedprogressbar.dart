import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final Duration duration;

  const AnimatedProgressBar({super.key, required this.duration});

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: 1.0 - _controller.value, // Reverse progress direction
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // Line color
          backgroundColor: Colors.white.withOpacity(0.3), // Background line color
        );
      },
    );
  }
}
