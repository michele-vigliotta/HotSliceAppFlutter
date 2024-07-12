import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_colors.dart';
import 'home.dart';
import 'offerte.dart';
import 'ordini.dart';
import 'carrello.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Indice dell'icona selezionata
  String role = "";
  bool isLoading = true; // Indica se il caricamento è in corso
  late FirebaseAuth auth;
  late FirebaseFirestore db;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    _checkUserRole();
  }

  // Metodo per verificare il ruolo dell'utente
  void _checkUserRole() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await db.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          role = userDoc['role'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

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
      Offerte(),
      if (role != 'staff') const Carrello(),
      Ordini(),
    ];

    // Lista di voci per la BottomNavigationBar
    List<BottomNavigationBarItem> _bottomNavBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        label: 'Home',
        icon: Icon(Icons.home),
      ),
      const BottomNavigationBarItem(
        label: 'Offerte',
        icon: Icon(Icons.celebration),
      ),
      if (role != 'staff')
        const BottomNavigationBarItem(
          label: 'Carrello',
          icon: Icon(Icons.add_shopping_cart),
        ),
      const BottomNavigationBarItem(
        label: 'Ordini',
        icon: Icon(Icons.access_time),
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Mostra un indicatore di caricamento finché il ruolo non è caricato
          : _pages[_selectedIndex], // Mostra la pagina corrente
      bottomNavigationBar: isLoading
          ? SizedBox() // Mostra una BottomNavigationBar vuota finché il ruolo non è caricato
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Le icone non si muovono
              showSelectedLabels: false, // Nasconde le etichette delle icone selezionate
              showUnselectedLabels: false, // Nasconde le etichette delle icone non selezionate
              currentIndex: _selectedIndex, // Imposta l'indice corrente
              backgroundColor: AppColors.primaryColor, // Colore di sfondo della BottomNavigationBar
              selectedItemColor: Colors.white, // Colore delle icone selezionate
              unselectedItemColor: Colors.black54, // Colore delle icone non selezionate
              onTap: _onItemTapped, // Callback per il tap
              items: _bottomNavBarItems,
            ),
    );
  }
}
