import 'dart:ui';

import 'botao_animado.dart';
import 'input_customizado.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animacaoBlur;
  Animation<double>? _animacaoFade;
  Animation<double>? _animacaoSize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacaoBlur = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.ease,
      ),
    );

    _animacaoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOutQuint,
      ),
    );

    _animacaoSize = Tween<double>(begin: 0, end: 500).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.decelerate,
      ),
    );

    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animacaoBlur!,
              builder: (context, widget) {
                return Container(
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/fundo.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _animacaoBlur!.value,
                      sigmaY: _animacaoBlur!.value,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 10,
                          child: FadeTransition(
                            opacity: _animacaoFade!,
                            child: Image.asset("images/detalhe1.png"),
                          ),
                        ),
                        Positioned(
                          left: 90,
                          child: FadeTransition(
                            opacity: _animacaoFade!,
                            child: Image.asset("images/detalhe2.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _animacaoSize!,
                    builder: (context, widget) {
                      return Container(
                        width: _animacaoSize?.value,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 80,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title for the form
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, // Centers the text and icon
                                children: [
                                  Icon(
                                    Icons.person, // User icon
                                    color: Colors.blue,
                                    size: 28, // Icon size
                                  ),
                                  const SizedBox(width: 8), // Adds spacing between the icon and text
                                  Text(
                                    "User Details",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'RobotoSlab', // Cursive font family
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Phone Number Field
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const InputCustomizado(
                                hint: 'Phone Number',
                                obscure: false,
                                icon: Icon(Icons.call, color: Colors.blue),
                              ),
                            ),

                            // OTP Field
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const InputCustomizado(
                                hint: 'OTP',
                                icon: Icon(Icons.password, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BotaoAnimado(controller: _controller!),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _animacaoFade!,
                    child: const Text(
                      "Create your new account!",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
