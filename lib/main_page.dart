import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hot_slice_app/no_internet_scaffold.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
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

  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionSubscription;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    _internetConnectionSubscription =
        InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
      }
    });
    _checkUserRole();
  }

  @override
  void dispose() {
    _internetConnectionSubscription?.cancel();
    super.dispose();
  }

  // Metodo per verificare il ruolo dell'utente
  void _checkUserRole() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc =
            await db.collection('users').doc(currentUser.uid).get();
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
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error checking user role: $e");
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
    List<BottomNavigationBarItem> _bottomNavBarItems =
        <BottomNavigationBarItem>[
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

    // Scaffold per quando c'è connessione a Internet
    Widget connectedScaffold = Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ) // Mostra un indicatore di caricamento finché il ruolo non è caricato
          : _pages[_selectedIndex], // Mostra la pagina corrente
      bottomNavigationBar: isLoading
          ? SizedBox() // Mostra una BottomNavigationBar vuota finché il ruolo non è caricato
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Le icone non si muovono
              showSelectedLabels:
                  false, // Nasconde le etichette delle icone selezionate
              showUnselectedLabels:
                  false, // Nasconde le etichette delle icone non selezionate
              currentIndex: _selectedIndex, // Imposta l'indice corrente
              backgroundColor: AppColors
                  .primaryColor, // Colore di sfondo della BottomNavigationBar
              selectedItemColor: Colors.white, // Colore delle icone selezionate
              unselectedItemColor:
                  Colors.black54, // Colore delle icone non selezionate
              onTap: _onItemTapped, // Callback per il tap
              items: _bottomNavBarItems,
            ),
    );



    // Restituisci lo Scaffold appropriato in base allo stato della connessione Internet
    return isConnectedToInternet ? connectedScaffold : NoInternetScaffold();
  }
}
