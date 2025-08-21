import 'package:flutter/material.dart';
import 'package:jogoteca/constants/app_constants.dart';
import 'package:jogoteca/screens/home/home_screen.dart';

class AppEmConstrucaoScreen extends StatelessWidget {
  const AppEmConstrucaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppConstants.appBuildingImage,
              fit: BoxFit.fill,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(),
                      ),
                    );
                  },
                  child: const Text('Voltar', style: TextStyle(fontSize: 16),),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
