import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_colors.dart';

class Ordini extends StatefulWidget {
  @override
  _OrdiniState createState() => _OrdiniState();
}

class _OrdiniState extends State<Ordini> {
  int _selectedButtonIndex = 0;
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  String role = "";
  late Future<List<ItemOrdine>> ordiniList;
  bool isStaff = false;
  bool isLoading = true; // Aggiunto per gestire il caricamento iniziale
  ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // button background color
  );

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    ordiniList = Future.value([]);
    _checkUserRole();
  }

  void _checkUserRole() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await db.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists) {
        role = userDoc['role'];
        if (role == 'staff') {
          setState(() {
            isStaff = true;
          });
          ordiniList = _filterOrdini('Servizio al Tavolo');
        }
      } else {
        ordiniList = _loadOrdini(currentUser.uid);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Devi essere loggato per visualizzare gli ordini")));
    }
    setState(() {
      isLoading = false;
    }); // Set isLoading to false once the user role is checked
  }

  Future<List<ItemOrdine>> _loadOrdini(String userId) async {
    QuerySnapshot querySnapshot = await db.collection('ordini').where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => ItemOrdine.fromDocument(doc)).toList();
  }

  Future<List<ItemOrdine>> _filterOrdini(String tipo) async {
    QuerySnapshot querySnapshot = await db.collection('ordini').where('tipo', isEqualTo: tipo).get();
    return querySnapshot.docs.map((doc) => ItemOrdine.fromDocument(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.white,
            child: const Text(
              'Ordini',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
                fontSize: 28.0,
              ),
            ),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            if (isStaff)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        ordiniList = _filterOrdini('Servizio al Tavolo');
                        _selectedButtonIndex = 0;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 0 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Al Tavolo'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        ordiniList = _filterOrdini("Servizio d'Asporto");
                        _selectedButtonIndex = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == 1 ? AppColors.secondaryColor : AppColors.lightYellow,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("D'Asporto"),
                  ),
                ],
              ),
            if (isStaff) ...[
              SizedBox(height: 16),
              Divider(color: Colors.grey),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Ordini nelle ultime 24 ore',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
              Divider(color: Colors.grey),
            ],
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : FutureBuilder<List<ItemOrdine>>(
                      future: ordiniList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Errore: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Nessun ordine effettuato'));
                        } else {
                          final ordini = snapshot.data!;
                          return ListView.builder(
                            itemCount: ordini.length,
                            itemBuilder: (context, index) {
                              final ordine = ordini[index];
                              return OrdineCard(ordine: ordine, isStaff: isStaff,);
                            },
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemOrdine {
  String id;
  String data;
  String descrizione;
  String stato;
  String tavolo;
  String tipo;
  String totale;
  String nome;
  String ora;
  String telefono;

  ItemOrdine({
    required this.id,
    required this.data,
    required this.descrizione,
    required this.stato,
    required this.tavolo,
    required this.tipo,
    required this.totale,
    required this.nome,
    required this.ora,
    required this.telefono,
  });

  factory ItemOrdine.fromDocument(DocumentSnapshot doc) {
    return ItemOrdine(
      id: doc.id,
      data: doc['data'],
      descrizione: doc['descrizione'],
      stato: doc['stato'],
      tavolo: doc['tavolo'],
      tipo: doc['tipo'],
      totale: doc['totale'],
      nome: doc['nome'],
      ora: doc['ora'],
      telefono: doc['telefono'],
    );
  }
}

class OrdineCard extends StatelessWidget {
  final ItemOrdine ordine;
  final bool isStaff;

  OrdineCard({required this.ordine,
  required this.isStaff});

void _showOrdineDetails(BuildContext context) {
  int _selectedOrderAction = 0; // 0: Accetta, 1: Rifiuta
  TextEditingController _pickupTimeController = TextEditingController();
  TimeOfDay? selectedTime;
  TextEditingController oraController = TextEditingController();

     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Gestione Ordine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                children: [
                  Radio<int>(
                    value: 0,
                    groupValue: _selectedOrderAction,
                    onChanged: (value) {
                      _selectedOrderAction = value!;
                      // Trigger rebuild of dialog
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  const Text('Accetta Ordine'),
                ],
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: _selectedOrderAction,
                    onChanged: (value) {
                      _selectedOrderAction = value!;
                      // Trigger rebuild of dialog
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  const Text('Rifiuta Ordine'),
                ],
              ),
              if (_selectedOrderAction == 0 && ordine.tipo == "Servizio d'Asporto")
                TextFormField(
                  onTap : () async {
                    selectedTime = await showTimePicker(
                      context: context, 
                      initialTime: TimeOfDay.now(),
                      builder: (BuildContext context, Widget? child) {
                  return Theme(
                      data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors
                                .primaryColor, // Colore principale del time picker
                            onSurface: AppColors
                                .secondaryColor, // Colore dei numeri e delle etichette
                          ),
                          buttonTheme: const ButtonThemeData(
                            colorScheme: ColorScheme.light(
                              primary: AppColors
                                  .primaryColor, // Colore dei bottoni (OK e Cancel)
                            ),
                          ),
                          timePickerTheme: const TimePickerThemeData(
                            dialBackgroundColor:
                                Color.fromARGB(255, 241, 241, 241),
                          )),
                      child: child!);
                },
                    );
                    
                  if (selectedTime != null) {
                oraController.text = selectedTime!.format(context);
              }
            },
            controller: oraController,
            decoration: const InputDecoration(
              labelText: 'Ora',
              labelStyle: TextStyle(color: AppColors.myGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            readOnly: true,
          ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Conferma'),
              onPressed: () async {
                
              
              
              if (_selectedOrderAction == 0){ //accetta
                try{
                  CollectionReference ordini = FirebaseFirestore.instance.collection('ordini');
                  if (ordine.tipo == "Servizio d'Asporto"){ //asporto
                      
                    if (oraController.text == null || oraController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Inserisci l'orario di ritiro");
                        return null;
                    } 
                
                  await ordini.doc(ordine.id).update({
                    
                  'stato': 'Accettato',
                  'ora di ritiro': oraController.text,
                  });
                  
                  }
                  else{ //tavolo
                    await ordini.doc(ordine.id).update({
                    
                  'stato': 'Accettato',});
                  }
                  Fluttertoast.showToast(msg: "Ordine Accettato");
                } catch (e) {
                  Fluttertoast.showToast(msg: "Errore durante l'iserimento, riprovare");
                }
                }else{ //rifiuta
                  try{
                  CollectionReference ordini = FirebaseFirestore.instance.collection('ordini');
                  

                
                  await ordini.doc(ordine.id).update({
                    
                  'stato': 'Rifiutato',
                  
                  });
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Errore durante l'iserimento, riprovare");
                  }
                }

                

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  


@override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isStaff) {
          _showOrdineDetails(context);
        }
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Ordine in data: ${ordine.data}',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Descrizione: ${ordine.descrizione}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Totale: ${ordine.totale} €',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Tipo: ${ordine.tipo}',
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              if (ordine.tipo == 'Servizio al Tavolo')
                Text(
                  'Tavolo: ${ordine.tavolo}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
              if (ordine.tipo != 'Servizio al Tavolo')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Ora di ritiro: ${ordine.ora}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Nome: ${ordine.nome}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Telefono: ${ordine.telefono}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
