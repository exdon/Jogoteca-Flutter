import 'package:flutter/material.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/widget/home/home_card.dart';

class CategoryScreen extends StatefulWidget {
  final String titulo;
  final List<HomeModel> jogos;

  const CategoryScreen({
    super.key,
    required this.titulo,
    required this.jogos,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Set<int> _pressedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.titulo, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 5,
        ),
        itemCount: widget.jogos.length,
        itemBuilder: (context, index) {
          final jogo = widget.jogos[index];
          final bool isPressed = _pressedCards.contains(index);

          return HomeCard(
            jogo: jogo,
            isPressed: isPressed,
            onTapDown: () => setState(() => _pressedCards.add(index)),
            onTapUp: () => setState(() => _pressedCards.remove(index)),
            onTapCancel: () => setState(() => _pressedCards.remove(index)),
            width: double.infinity,
            height: 160,
            showTitle: true,
          );
        },
      ),
    );
  }
}