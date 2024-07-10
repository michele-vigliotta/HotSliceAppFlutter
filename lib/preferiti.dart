import 'package:flutter/material.dart';
import 'colors.dart';

class Preferiti extends StatelessWidget {
  const Preferiti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Colore di sfondo bianco
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferiti',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Numero di articoli preferiti, sostituire con dati reali
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Articolo preferito $index'),
                  trailing: const Icon(Icons.favorite, color: AppColors.primaryColor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
