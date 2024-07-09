import 'package:flutter/material.dart';
import 'package:hot_slice_app/carrello_model.dart';
import 'colors.dart';
import 'home.dart';
import 'offerte.dart';
import 'preferiti.dart';
import 'ordini.dart';
import 'carrello.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Indice dell'icona selezionata

  


  

  

  // Metodo per aggiornare l'indice dell'icona selezionata
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lista di widget per ciascuna pagina
  List<Widget> _pages = <Widget>[
    const Home(),
    const Offerte(),
    const Preferiti(),
    const Carrello(),
    Ordini(),
  ];

    return Scaffold(
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
    );
  }
}
