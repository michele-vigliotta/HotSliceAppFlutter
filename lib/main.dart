import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hot_slice_app/login.dart'; // Importa la tua pagina di login
import 'package:hot_slice_app/main_page.dart'; // Importa la tua MainPage
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inizializza Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HotSlice App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/container': (context) => const MainPage(), // Aggiorna con la tua route per la MainPage
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Se lo stato dell'utente è in attesa, mostra uno splash screen o uno schermo di caricamento
          return const SplashScreen();
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            // Se l'utente è loggato, naviga alla MainPage
            return const MainPage(); // Sostituisci con la tua widget della MainPage
          } else {
            // Se l'utente non è loggato, mostra la pagina di login
            return const LoginPage(); // Sostituisci con la tua widget della pagina di login
          }
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Implementa uno splash screen personalizzato o uno schermo di caricamento qui
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Esempio di indicatore di caricamento
      ),
    );
  }
}
