import 'package:flutter/material.dart';
import 'colors.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Colore di sfondo bianco
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HUNGRY NOW?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(112, 2, 2, 2),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: AppColors.secondaryColor),
                  onPressed: () {
                    // Logica per il logout
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Find your food ...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                    color: Color.fromARGB(112, 2, 2, 2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logica per il pulsante Pizza
                    },
                    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.secondaryColor
                    ),
                    child: const Text('Pizza'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logica per il pulsante Bibite
                    },
                    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.secondaryColor
                    ),
                    child: const Text('Bibite'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Logica per il pulsante Dolci
                    },
                    style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.secondaryColor
                    ),
                    child: const Text('Dolci'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                color: Colors.grey[200], // Colore del contenitore delle categorie
                child: const Center(
                  child: Text('Placeholder per la lista di cibi'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
