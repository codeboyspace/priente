import 'package:flutter/material.dart';

class InputCustomizado extends StatefulWidget {
  final String hint;
  final bool obscure;
  final Icon icon;

  const InputCustomizado({
    super.key,
    required this.hint,
    this.obscure = false,
    required this.icon,
  });

  @override
  State<InputCustomizado> createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _cursorColorAnimation;
  late Animation<double> _borderGlowAnimation;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Animation for glowing border and cursor
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _cursorColorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.blue,
    ).animate(_controller);

    _borderGlowAnimation = Tween<double>(begin: 1.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _cursorColorAnimation.value!.withOpacity(0.5),
                blurRadius: _borderGlowAnimation.value,
                spreadRadius: 1,
              ),
            ],
            color: Colors.white,
          ),
          child: TextField(
  focusNode: _focusNode,
  obscureText: widget.obscure,
  cursorColor: _cursorColorAnimation.value,
  style: const TextStyle(fontSize: 16, color: Colors.black),
  decoration: InputDecoration(
    hintText: widget.hint,
    hintStyle: TextStyle(color: Colors.grey.shade400),
    prefixIcon: widget.icon,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12), // Adjust padding for vertical centering
    border: InputBorder.none,
  ),
  textAlignVertical: TextAlignVertical.center, // Ensures hint text is vertically centered
),

        );
      },
    );
  }
}
