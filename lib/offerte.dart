import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_colors.dart';
import 'generic_item.dart';
import 'new_offer_dialog.dart'; // Importa il dialog della nuova offerta
import 'dettagli_prodotto.dart';

class Offerte extends StatefulWidget {
  @override
  _OfferteState createState() => _OfferteState();
}

class _OfferteState extends State<Offerte> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? _currentUser;
  bool isStaff = false;
  bool _isLoading = true;
  String role = "";
  List<GenericItem> _offerteList = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _checkUserRole();
    _fetchDataFromFirebase();
  }

  Future<void> _checkUserRole() async {
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        role = userDoc['role'];
        if (role == 'staff') {
          setState(() {
            isStaff = true;
          });
        }
      }
    }
  }

  Future<void> _fetchDataFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('offerte').get();
      setState(() {
        _offerteList = querySnapshot.docs
            .map((doc) => GenericItem.fromDocument(doc))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _showNewOfferDialog() {
    showDialog(
      context: context,
      builder: (context) => NewOfferDialog(
        onOfferAdded: _fetchDataFromFirebase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // Sfondo bianco per l'Appbar
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.white, // Sfondo bianco per il container del titolo
            child: const Text(
              'Offerte',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _offerteList.length,
                      itemBuilder: (context, index) {
                        final offer = _offerteList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FutureBuilder<String>(
                                  future: offer.imageUrl, // Utilizza il Future<String> qui
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryColor),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                        child: Text(
                                            'Errore durante il caricamento dell\'immagine.'),
                                      );
                                    } else {
                                      // Quando il futuro è risolto, navighiamo a DettagliProdotto
                                      return DettagliProdotto(
                                        nome: offer.nome,
                                        prezzo: offer.prezzo,
                                        imageUrl: snapshot.data ?? '', // Passa l'URL risolto
                                        descrizione: offer.descrizione,
                                        onProductEdited: _fetchDataFromFirebase,
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              side: BorderSide(color: Colors.grey[300]!, width: 1.0),
                            ),
                            elevation: 2.0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120.0,
                                    height: 100.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: FutureBuilder<String>(
                                        future: offer.imageUrl,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                              ),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Icon(Icons.error, color: AppColors.primaryColor),
                                            );
                                          }
                                          final imageUrl = snapshot.data ?? ''; // Ottieni l'URL dall'oggetto Future<String>
                                          return Image.network(
                                            imageUrl,
                                            width: 120.0,
                                            height: 100.0,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(Icons.error, color: AppColors.primaryColor);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                offer.nome,
                                                style: const TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.secondaryColor,
                                                ),
                                                textAlign: TextAlign.start,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '€${offer.prezzo.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 15.0,
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          offer.descrizione,
                                          style: const TextStyle(
                                            fontSize: 15.0,
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
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: _showNewOfferDialog,
              backgroundColor: AppColors.secondaryColor,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 48.0,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}
