import 'package:flutter/material.dart';
import 'colors.dart';
import 'home.dart';
import 'offerte.dart';
import 'preferiti.dart';
import 'ordini.dart';
import 'carrello.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // Indice dell'icona selezionata

  // Lista di widget per ciascuna pagina
  static const List<Widget> _pages = <Widget>[
    Home(),
    Offerte(),
    Preferiti(),
    Carrello(),
    Ordini(),
  ];

  // Metodo per aggiornare l'indice dell'icona selezionata
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
          child: AppBar(
            backgroundColor: AppColors.primaryColor,
          ),
        ),
        body: _pages[_selectedIndex], // Mostra la pagina corrente
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Le icone non si muovono
          showSelectedLabels: false, // Nasconde le etichette delle icone selezionate
          showUnselectedLabels: false, // Nasconde le etichette delle icone non selezionate
          currentIndex: _selectedIndex, // Imposta l'indice corrente
          backgroundColor: AppColors.primaryColor, // Colore di sfondo della BottomNavigationBar
          selectedItemColor: Colors.white, // Colore delle icone selezionate
          unselectedItemColor: Colors.black54, // Colore delle icone non selezionate
          onTap: _onItemTapped, // Callback per il tap
          items: const [
            BottomNavigationBarItem(
              label: 'Home', 
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Offerte', 
              icon: Icon(Icons.celebration),
            ),
            BottomNavigationBarItem(
              label: 'Preferiti', 
              icon: Icon(Icons.favorite),
            ),
            BottomNavigationBarItem(
              label: 'Carrello', 
              icon: Icon(Icons.add_shopping_cart),
            ),
            BottomNavigationBarItem(
              label: 'Ordini', 
              icon: Icon(Icons.access_time),
            ),
          ],
        ),
      ),
    );
  }
}