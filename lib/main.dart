import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hot_slice_app/app_colors.dart';
import 'package:hot_slice_app/carrello_provider.dart';
import 'package:hot_slice_app/login.dart'; 
import 'package:hot_slice_app/main_page.dart'; 
import 'package:hot_slice_app/offerte.dart';
import 'package:hot_slice_app/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inizializza Firebase

  // Imposta l'orientamento verticale
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    ChangeNotifierProvider(
      create: (context) => CarrelloProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HotSlice App',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          AuthWrapper(), //determina la schermata iniziale in base allo stato di autenticazione dell'utente
      routes: {
        '/login': (context) => LoginPage(),
        '/container': (context) =>MainPage(), // Aggiorna con la route per la MainPage
        '/register': (context) => RegisterPage(),
        '/offerte': (context) => Offerte(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), //questo stream notifica quando lo stato di autenticazione dell'utente cambia
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        //snapshot.data!.uid
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ), 
      ),
    );
  }
}
