import 'package:flutter/material.dart';

class Ordini extends StatelessWidget {
  const Ordini({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Colore di sfondo bianco
      body: Center(
        child: Text(
          'Pagina Ordini',
          style: TextStyle(
            fontSize: 24,
            color: Colors.red, // Puoi cambiare il colore del testo se preferisci
          ),
        ),
      ),
    );
  }
}
