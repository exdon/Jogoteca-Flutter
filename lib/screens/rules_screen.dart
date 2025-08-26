import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesScreen<T extends StateStreamableSource<Object?>> extends StatefulWidget {
  final String backgroundImagePath;
  final String rulesText;
  final T bloc;
  final Widget Function(String partidaId, T bloc) destinationBuilder;

  const RulesScreen({
    super.key,
    required this.backgroundImagePath,
    required this.rulesText,
    required this.bloc,
    required this.destinationBuilder,
  });

  @override
  State<RulesScreen> createState() => _RulesScreenState<T>();
}

class _RulesScreenState<T extends StateStreamableSource<Object?>> extends State<RulesScreen<T>> {
  double _boxOpacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _boxOpacity = 1.0);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _textOpacity = 1.0);
      });
    });
  }

  void _navigate() {
    final partidaId = _generatePartidaId();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: widget.bloc,
          child: widget.destinationBuilder(partidaId, widget.bloc),
        ),
      ),
    );
  }

  String _generatePartidaId() {
    String f(int n) => n.toString().padLeft(2, '0');
    final agora = DateTime.now();
    return "${agora.year}-${f(agora.month)}-${f(agora.day)}_${f(agora.hour)}:${f(agora.minute)}:${f(agora.second)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(widget.backgroundImagePath, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildRulesContainer(),
            const SizedBox(height: 16),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesContainer() {
    return Expanded(
      child: AnimatedOpacity(
        opacity: _boxOpacity,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeIn,
                child: Text(
                  widget.rulesText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _navigate,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: const Text('Iniciar', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[900],
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
