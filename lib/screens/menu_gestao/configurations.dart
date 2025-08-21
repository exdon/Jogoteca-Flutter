import 'package:flutter/material.dart';

class Configurations extends StatelessWidget {
  const Configurations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: Text('Configurações', style: TextStyle(color: Colors.white),),
      ),
    );
  }
}
