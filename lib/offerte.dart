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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
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
      QuerySnapshot querySnapshot = await _firestore.collection('offerte').get();
      setState(() {
        _offerteList = querySnapshot.docs.map((doc) => GenericItem.fromDocument(doc)).toList();
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
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Offerte',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
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
                  const Center(
                    child: Text(
                      'Offerte',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
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
                                builder: (context) => DettagliProdotto(
                                  nome: offer.nome,
                                  prezzo: offer.prezzo,
                                  imageUrl: offer.imageUrl,
                                  descrizione: offer.descrizione,
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
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                          ),
                                          Image.network(
                                            offer.imageUrl,
                                            width: 120.0,
                                            height: 100.0,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 120.0,
                                                height: 100.0,
                                                child: Icon(Icons.error, color: AppColors.primaryColor),
                                              );
                                            },
                                          ),
                                        ],
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
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
