import 'package:flutter/material.dart';

class Carrello extends StatelessWidget {
  const Carrello({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Colore di sfondo bianco
      body: Center(
        child: Text(
          'Pagina Carrello',
          style: TextStyle(
            fontSize: 24,
            color: Colors.red, // Puoi cambiare il colore del testo se preferisci
          ),
        ),
      ),
    );
  }
}
