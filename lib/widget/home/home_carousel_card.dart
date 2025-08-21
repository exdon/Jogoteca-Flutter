import 'package:flutter/material.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/widget/shared/adult_content_dialog.dart';
import 'package:jogoteca/widget/transicao.dart';


class HomeCarouselCard extends StatelessWidget {
  final HomeModel jogo;

  const HomeCarouselCard({
    super.key,
    required this.jogo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              jogo.imagem,
              fit: BoxFit.cover,
            ),
            _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(8),
        child: Text(
          jogo.nome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (jogo.alert) {
      AdultContentDialog.show(context, jogo.target);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Transicao(telaDestino: jogo.target),
        ),
      );
    }
  }
}