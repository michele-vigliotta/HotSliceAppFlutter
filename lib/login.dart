import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _rememberMe = false;
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        // Login successful
        if (_rememberMe) {
          // Implementa la tua logica per memorizzare lo stato di "Accedi automaticamente"
        }

        Navigator.of(context).pushReplacementNamed('/container'); // Naviga alla MainPage dopo il login
      } else {
        // Login fallito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email e/o password errati'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Errore durante il login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante il login. Riprova più tardi.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50.0),
              const Text(
                'HotSlice',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              Image.asset(
                'images/pizzalogin.png', // Assicurati di avere l'immagine nella cartella 'images'
                height: 186.0,
                width: 234.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci l\'email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci la password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          activeColor: Colors.red,
                        ),
                        const Text(
                          'Accedi automaticamente',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Colore del pulsante
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 24.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/register'); // Naviga alla pagina di registrazione
                      },
                      child: const Text(
                        'Non sei ancora registrato? Registrati ora!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
