import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';

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
            ordiniList = _filterOrdini('Servizio al Tavolo');
          });
        }
      } else {
        setState(() {
          ordiniList = _loadOrdini(currentUser.uid);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Devi essere loggato per visualizzare gli ordini")));
    }
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
      appBar: AppBar(
        title: Text('Ordini'),
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
                    child: Text('Al Tavolo'),
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
                    child: Text("D'Asporto"),
                  ),
                ],
              ),
            if (isStaff) ...[
              SizedBox(height: 16),
              Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              child: FutureBuilder<List<ItemOrdine>>(
                future: ordiniList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nessun ordine trovato'));
                  } else {
                    final ordini = snapshot.data!;
                    return ListView.builder(
                      itemCount: ordini.length,
                      itemBuilder: (context, index) {
                        final ordine = ordini[index];
                        return OrdineCard(ordine: ordine);
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
  String tipo;
  String totale;
  String nome;
  String telefono;

  ItemOrdine({
    required this.id,
    required this.data,
    required this.descrizione,
    required this.stato,
    required this.tipo,
    required this.totale,
    required this.nome,
    required this.telefono,
  });

  factory ItemOrdine.fromDocument(DocumentSnapshot doc) {
    return ItemOrdine(
      id: doc.id,
      data: doc['data'],
      descrizione: doc['descrizione'],
      stato: doc['stato'],
      tipo: doc['tipo'],
      totale: doc['totale'],
      nome: doc['nome'],
      telefono: doc['telefono'],
    );
  }
}

class OrdineCard extends StatelessWidget {
  final ItemOrdine ordine;

  OrdineCard({required this.ordine});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Descrizione: ${ordine.descrizione}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Totale: ${ordine.totale}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Tipo: ${ordine.tipo}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            if (ordine.tipo == 'Servizio al Tavolo')
              Text(
                'Tavolo: ${ordine.descrizione}', // Update with actual table info if available
                style: TextStyle(
                fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            if (ordine.tipo == "Servizio d'Asporto")
              Text(
                'Ora di ritiro: ${ordine.data}', // Update with actual pickup time if available
                style: TextStyle(
                fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            SizedBox(height: 8.0),
            Text(
              'Nome: ${ordine.nome}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Telefono: ${ordine.telefono}',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Stato: ${ordine.stato}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
