import 'package:flutter/material.dart';
import 'package:hot_slice_app/preferiti.dart';
import 'colors.dart';
import 'home.dart';
//import 'pages/favorites_page.dart';
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
    Center(child: Text('Offerte', style: TextStyle(fontSize: 24, color: AppColors.primaryColor))),
    Preferiti(), // Pagina Preferiti
    Center(child: Text('Carrello', style: TextStyle(fontSize: 24, color: AppColors.primaryColor))),
    Center(child: Text('Impostazioni', style: TextStyle(fontSize: 24, color: AppColors.primaryColor))),
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
              label: 'Home', // Questa label sarà nascosta
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Offerte', // Questa label sarà nascosta
              icon: Icon(Icons.celebration),
            ),
            BottomNavigationBarItem(
              label: 'Preferiti', // Questa label sarà nascosta
              icon: Icon(Icons.favorite),
            ),
            BottomNavigationBarItem(
              label: 'Carrello', // Questa label sarà nascosta
              icon: Icon(Icons.shopping_cart),
            ),
            BottomNavigationBarItem(
              label: 'Impostazioni', // Questa label sarà nascosta
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      ),
    );
  }
}
