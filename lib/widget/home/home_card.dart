import 'package:flutter/material.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/models/home/home_model.dart';
import 'package:jogoteca/widget/shared/adult_content_dialog.dart';
import 'package:jogoteca/widget/transicao.dart';

class HomeCard extends StatelessWidget {
  final HomeModel jogo;
  final bool isPressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTapCancel;
  final double width;
  final double height;
  final bool showTitle;

  const HomeCard({
    super.key,
    required this.jogo,
    required this.isPressed,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    this.width = 120,
    this.height = 140,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: showTitle ? 4 : 1,
            child: _buildCard(context),
          ),
          if (showTitle) ...[
            const SizedBox(height: 6),
            Flexible(
              child: _buildTitle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapCancel,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            jogo.imagem,
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      jogo.nome,
      style: const TextStyle(color: Colors.white, fontSize: 12),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      maxLines: 2,
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