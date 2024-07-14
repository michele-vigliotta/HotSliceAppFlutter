import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_slice_app/modifica_offerta_dialog.dart';
import 'package:hot_slice_app/no_internet_scaffold.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'app_colors.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'package:provider/provider.dart';

class DettagliProdotto extends StatefulWidget {
  late String nome;
  late double prezzo;
  late String imageUrl;
  late String descrizione;
  final VoidCallback onProductEdited;

  DettagliProdotto({
    Key? key,
    required this.nome,
    required this.prezzo,
    required this.imageUrl,
    required this.descrizione,
    required this.onProductEdited,
  }) : super(key: key);

  @override
  _DettagliProdottoState createState() => _DettagliProdottoState();
}

class _DettagliProdottoState extends State<DettagliProdotto> {
  int _quantita = 0;
  bool isStaff = false;
  bool isOfferta = false;
  final TextEditingController _controller = TextEditingController();
  late Future<void> _initializeDataFuture;

  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionSubscription;

  @override
  void initState() {
    super.initState();
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
    _controller.text = '$_quantita';
    _initializeDataFuture = _initializeData();
  }

  @override
  void dispose() {
    _internetConnectionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _checkRuolo();
    await _checkDocInOfferte();
  }

  Future<void> _checkRuolo() async {
    try {
      String userUid = FirebaseAuth.instance.currentUser!.uid;
      String path = 'users/$userUid';
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc(path).get();
      if (snapshot.exists) {
        if (snapshot.get('role') == 'staff') {
          setState(() {
            isStaff = true;
          });
        }
      }
    } catch (e) {
      print('Errore durante il recupero del ruolo dell\'utente: $e');
    }
  }

  Future<void> _checkDocInOfferte() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('offerte')
          .where('nome', isEqualTo: widget.nome)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          isOfferta = true;
        });
      }
    } catch (e) {
      print('Errore durante la verifica del documento in offerte: $e');
    }
  }

  void _incrementaQuantita() {
    setState(() {
      _quantita++;
      _controller.text = '$_quantita';
    });
  }

  void _decrementaQuantita() {
    if (_quantita > 0) {
      setState(() {
        _quantita--;
        _controller.text = '$_quantita';
      });
    }
  }

  void _aggiornaQuantita(String value) {
    setState(() {
      _quantita = int.tryParse(value) ?? 0;
      _controller.text = '$_quantita';
    });
  }

  void _showEliminaConfermaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<InternetStatus>(
          stream: InternetConnection().onStatusChange,
          builder: (context, snapshot) {
            if (snapshot.data == InternetStatus.disconnected) {
              // Chiudi il dialog
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
              return Container(); // Ritorna un container vuoto se disconnesso
            } else {
              return AlertDialog(
                title: const Text('Conferma Eliminazione'),
                content: const Text('Sei sicuro di voler eliminare questo prodotto?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Annulla',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _eliminaProdotto();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Prosegui',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<void> _eliminaProdotto() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('offerte')
          .where('nome', isEqualTo: widget.nome)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('offerte')
              .doc(doc.id)
              .delete();
        }
        widget.onProductEdited(); // Chiamo la callback
        Navigator.of(context).pop(); // Chiudo vista dettagli
        Fluttertoast.showToast(msg: 'Prodotto eliminato con successo');
      }
    } catch (e) {
      print('Errore durante la verifica del documento in offerte: $e');
      Fluttertoast.showToast(
          msg: 'Si é verificato un errore, si prega di riprovare');
    }
  }

  void _showModificaOffertaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ModificaOffertaDialog(
        nome: widget.nome,
        descrizione: widget.descrizione,
        prezzo: widget.prezzo,
        imageUrl: widget.imageUrl,
        onOfferEdited: _onOfferEdited,
      ),
    );
  }

  void _onOfferEdited() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('offerte')
          .where('nome', isEqualTo: widget.nome)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        setState(() {
          widget.nome = doc['nome'];
          widget.prezzo = doc['prezzo'];
          widget.descrizione = doc['descrizione'];
          widget.imageUrl = doc['foto'];
        });

        Fluttertoast.showToast(msg: 'Offerta aggiornata con successo');
      } else {
        Fluttertoast.showToast(msg: 'Nessuna offerta trovata');
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento dell\'offerta: $e');
      Fluttertoast.showToast(
          msg: 'Si è verificato un errore, si prega di riprovare');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget DettagliScaffold = Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Errore durante il caricamento dei dati.'),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              widget.nome,
                              style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor),
                                ),
                                Image.network(
                                  widget.imageUrl,
                                  height: 200.0,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'images/pizza_foto.png',
                                      height: 200.0,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Text(
                            widget.descrizione,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 220.0),
                          if (isStaff) // Prezzo in fondo per lo staff
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  '${widget.prezzo.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isStaff) // Prezzo sopra il contatore per i non staff
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '${widget.prezzo.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _decrementaQuantita,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('-'),
                            ),
                            const SizedBox(width: 8.0),
                            Container(
                              width: 120.0,
                              height: 52.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _controller,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 15),
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16.0),
                                  onChanged: _aggiornaQuantita,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: _incrementaQuantita,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('+'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<CarrelloProvider>(context, listen: false)
                                .addToCarrello(
                              CarrelloModel(
                                name: widget.nome,
                                price: widget.prezzo,
                                quantity: _quantita,
                                image: widget.imageUrl,
                                description: widget.descrizione,
                              ),
                              quantity: _quantita,
                            );
                            _aggiornaQuantita('0');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aggiunto al carrello'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                          ),
                          child: const Text(
                            'Aggiungi al carrello',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isStaff && isOfferta) // Azioni per lo staff
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showModificaOffertaDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            fixedSize: const Size(220.0, 50.0),
                          ),
                          child: const Text(
                            'Modifica prodotto',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          onPressed: () {
                            _showEliminaConfermaDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            fixedSize: const Size(220.0, 50.0),
                          ),
                          child: const Text(
                            'Elimina prodotto',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20.0), // Spazio dal basso
              ],
            );
          }
        },
      ),
    );

    return isConnectedToInternet ? DettagliScaffold : NoInternetScaffold();
  }
}
