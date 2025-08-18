import 'package:flutter/material.dart';
import 'package:jogoteca/screens/prazer_anonimo/rules_screen.dart';
import 'package:jogoteca/widget/transicao.dart';

class AdultContentNotify extends StatelessWidget {
  const AdultContentNotify({super.key});

  void _goToGame() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Column(
            children: [
              // Fundo
              Positioned.fill(
                child: Image.asset("images/18+_logo.webp", fit: BoxFit.cover),
              ),
              // Overlay escuro
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
              Text('data'),
              SizedBox(height: 50,),
              Row(
                children: [
                  ElevatedButton(onPressed: () => {}, child: Text('Sair')),
                  ElevatedButton(onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Transicao(telaDestino: RulesScreen()),
                      ),
                    );
                  }, child: Text('OK, SOU MAIOR DE IDADE')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
