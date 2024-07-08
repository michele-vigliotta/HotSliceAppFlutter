import 'package:flutter/material.dart';
import 'colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Indice del pulsante selezionato, inizialmente impostato su Pizza (indice 0)
  int _selectedButtonIndex = 0;

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
                    color: Color.fromARGB(150, 2, 2, 2),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.secondaryColor, // Sfondo colorato
                  radius: 24, // Raggio del cerchio, regola come desideri
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black), // Icona nera
                    onPressed: () {
                      // Logica per il logout
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search View con stile personalizzato
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Sfondo bianco
                borderRadius: BorderRadius.circular(8.0), // Angoli arrotondati
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Ombra nera con opacità
                    blurRadius: 4.0, // Raggio di sfocatura
                    offset: const Offset(0, 2), // Posizione dell'ombra
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Find your food ...',
                  hintStyle: TextStyle(color: Colors.grey[500]), // Testo suggerimento
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0), // Angoli arrotondati
                    borderSide: BorderSide(color: Colors.grey[300]!), // Bordo grigio
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    borderSide: BorderSide(color: Colors.grey[300]!), // Bordo grigio
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.0),
                    borderSide: BorderSide(color: Colors.grey[300]!), // Bordo grigio più scuro quando è attivo
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]), // Icona di ricerca
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Padding del contenuto
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(150, 2, 2, 2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 0 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent, // Disabilita l'ombra
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Pizza'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 1 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent, // Disabilita l'ombra
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Bibite'),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = 2;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 2 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent, // Disabilita l'ombra
                      foregroundColor: Colors.black,
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
