import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    setState(() {
      _rememberMe = rememberMe;
    });

    //se le credenziali sono salvate esegue il login in automatico
    if (email != null && password != null) {
      _emailController.text = email;
      _passwordController.text = password;
      _login();
    }
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Login successful
      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        if (_rememberMe) {
          
          await prefs.setString('email', _emailController.text.trim());
          await prefs.setString('password', _passwordController.text.trim());
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('email');
          await prefs.remove('password');
          await prefs.remove('rememberMe');
        }

        if(mounted){

        Navigator.of(context).pushReplacementNamed(
            '/container'); // Naviga alla MainPage dopo il login
        }
      } else {
        if (mounted) {
        // Login fallito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email e/o password errati'),
            duration: Duration(seconds: 3),
          ),
        );
        }
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
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0), // Altezza personalizzata della AppBar
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
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
                  color: AppColors.primaryColor,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 80),
              Image.asset(
                'images/pizzalogin.png', 
                height: 186.0,
                width: 234.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 140.0),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.all(16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ), 
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
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
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.all(16.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 2.0,
                          ),
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
                          activeColor: AppColors.primaryColor,
                          side: MaterialStateBorderSide.resolveWith((states) =>
                              BorderSide(
                                  width: 2.0, color: AppColors.primaryColor)),
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
                        backgroundColor: AppColors.secondaryColor,
                        fixedSize: Size(150.0, 40.0),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'LOGIN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            '/register'); // Naviga alla pagina di registrazione
                      },
                      child:  RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Non sei ancora registrato?',
                              style: TextStyle(
                                color: AppColors.myGrey,
                                fontSize: 18,
                              )
                            ),
                            TextSpan(
                              text: ' Registrati ora!',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 18,
                              )
                            ),

                          ]
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
