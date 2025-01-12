import 'package:flutter/material.dart';

class BotaoAnimado extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> largura;
  final Animation<double> altura;
  final Animation<double> radius;
  final Animation<double> opacidade;

  BotaoAnimado({super.key, required this.controller})
      : largura = Tween<double>(begin: 0, end: 500).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 0.5),
          ),
        ),
        altura = Tween<double>(begin: 0, end: 50).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.5, 0.7),
          ),
        ),
        radius = Tween<double>(begin: 0, end: 20).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 1.0),
          ),
        ),
        opacidade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.6, 0.8),
          ),
        );

  Widget _buildAnimation(BuildContext context, Widget? widget) {
    return InkWell(
      onTap: () {
        // Action when the button is tapped
      },
      child: Container(
        width: largura.value,
        height: altura.value,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.value),
          gradient: const LinearGradient(
            colors: [
              Colors.blue,
              Color.fromARGB(255, 90, 148, 248),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: opacidade,
            child: Row(
              mainAxisSize: MainAxisSize.min, // Ensures content wraps tightly
              mainAxisAlignment: MainAxisAlignment.center, // Centers the content
              children: [
                const Icon(
                  Icons.lock_open, // OTP-related icon
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8), // Spacing between icon and text
                const Text(
                  "Generate OTP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: _buildAnimation,
    );
  }
}
