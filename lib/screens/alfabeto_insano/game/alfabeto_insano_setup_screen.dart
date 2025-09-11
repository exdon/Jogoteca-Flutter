import 'package:flutter/material.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/screens/alfabeto_insano/game/alfabeto_insano_game_screen.dart';

class AlfabetoInsanoSetupScreen extends StatelessWidget {
  const AlfabetoInsanoSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void startGame(int timeSetup) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => AlfabetoInsanoGameScreen(time: timeSetup),
          ),
      );
    }

    String _formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
    }

    Widget _buildModeButton({
      required String title,
      required int timeInSeconds,
      required Color color,
      required VoidCallback onPressed,
    }) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
          child: Column(
            children: [
              Text(title),
              SizedBox(height: 4),
              Text(
                '${_formatTime(timeInSeconds)}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundAlfabetoInsano),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Selecione o Modo do Jogo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 40),

                // Botões dos modos
                _buildModeButton(
                  title: 'Modo Diversão',
                  timeInSeconds: 150,
                  color: Colors.green,
                  onPressed: () => startGame(150),
                ),

                _buildModeButton(
                  title: 'Modo Tensão',
                  timeInSeconds: 120,
                  color: Colors.blue,
                  onPressed: () => startGame(120),
                ),

                _buildModeButton(
                  title: 'Modo Sufoco',
                  timeInSeconds: 90,
                  color: Colors.orange,
                  onPressed: () => startGame(90),
                ),

                _buildModeButton(
                  title: 'Modo Insano',
                  timeInSeconds: 60,
                  color: Colors.red,
                  onPressed: () => startGame(60),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
