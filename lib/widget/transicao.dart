import 'dart:async';

import 'package:flutter/material.dart';

import 'animated_letter.dart';

class Transicao extends StatefulWidget {
  final Widget telaDestino;

  const Transicao({super.key, required this.telaDestino});

  @override
  State<Transicao> createState() => _TransicaoState();
}

class _TransicaoState extends State<Transicao>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  bool _mostrarTexto = false;
  final List<String> _textoAnimado = 'Carregando...'.split('');

  @override
  void initState() {
    super.initState();
    _iniciarAnimacao();
  }

  void _iniciarAnimacao() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _mostrarTexto = true);
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.telaDestino),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildImagemComFade()),
          if (_mostrarTexto) _buildTextoAnimado(),
        ],
      ),
    );
  }

  Widget _buildImagemComFade() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Image.asset(
        "images/background_game.jpg",
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildTextoAnimado() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_textoAnimado.length, (index) {
          return AnimatedLetter(
            letra: _textoAnimado[index],
            delay: Duration(milliseconds: 100 * index),
          );
        }),
      ),
    );
  }
}
