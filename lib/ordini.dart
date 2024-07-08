import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Ordini extends StatefulWidget {
  @override
  _OrdiniState createState() => _OrdiniState();
}

class _OrdiniState extends State<Ordini> {
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  late List<ItemOrdine> ordiniList;
  bool isLoading = true;
  ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // button background color
  );

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    ordiniList = [];
    _loadOrdini();
  }

  void _loadOrdini() async {
    QuerySnapshot querySnapshot = await db.collection('ordini').get();
    setState(() {
      ordiniList = querySnapshot.docs.map((doc) => ItemOrdine.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordini'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: ordiniList.length,
                      itemBuilder: (context, index) {
                        final ordine = ordiniList[index];
                        return ListTile(
                          title: Text('Ordine ${ordine.data}'),
                          onTap: () {
                            // Implementa la logica per gestire il click sugli ordini
                          },
                        );
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
  String stato;
  String tipo;

  ItemOrdine({required this.id, required this.data, required this.stato, required this.tipo});

  factory ItemOrdine.fromDocument(DocumentSnapshot doc) {
    return ItemOrdine(
      id: doc.id,
      data: doc['data'],
      stato: doc['stato'],
      tipo: doc['tipo'],
    );
  }
}



/*
COME DOVREBBE ESSERE CON IL CONTROLLO SUL RUOLO:

class Ordini extends StatefulWidget {
  @override
  _OrdiniState createState() => _OrdiniState();
}

class _OrdiniState extends State<Ordini> {
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  String role = "";
  late List<ItemOrdine> ordiniList;
  bool isLoading = true;
  bool isStaff = false;
  ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // button background color
  );

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
    ordiniList = [];
    _checkUserRole();
  }

  void _checkUserRole() async {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await db.collection('users').doc(currentUser.uid).get();
      role = userDoc['role'];
      if (role == 'staff') {
        setState(() {
          isStaff = true;
        });
        _filterOrdini('Servizio al Tavolo');
      } else {
        _loadOrdini(role, currentUser.uid);
      }
    } else {
      // handle user not logged in
    }
  }

  void _loadOrdini(String role, String userId) async {
    QuerySnapshot querySnapshot;
    if (role == 'staff') {
      querySnapshot = await db.collection('ordini').get();
    } else {
      querySnapshot = await db.collection('ordini').where('userId', isEqualTo: userId).get();
    }
    setState(() {
      ordiniList = querySnapshot.docs.map((doc) => ItemOrdine.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  void _filterOrdini(String tipo) async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot = await db.collection('ordini').where('tipo', isEqualTo: tipo).get();
    setState(() {
      ordiniList = querySnapshot.docs.map((doc) => ItemOrdine.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordini'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  if (isStaff)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => _filterOrdini('Servizio al Tavolo'),
                          style: selectedButtonStyle,
                          child: Text('Al Tavolo'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _filterOrdini("D'Asporto"),
                          style: selectedButtonStyle,
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
                    child: ListView.builder(
                      itemCount: ordiniList.length,
                      itemBuilder: (context, index) {
                        final ordine = ordiniList[index];
                        return ListTile(
                          title: Text('Ordine ${ordine.data}'),
                          onTap: () {
                            // Implementa la logica per gestire il click sugli ordini
                          },
                        );
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
  String stato;
  String tipo;

  ItemOrdine({required this.id, required this.data, required this.stato, required this.tipo});

  factory ItemOrdine.fromDocument(DocumentSnapshot doc) {
    return ItemOrdine(
      id: doc.id,
      data: doc['data'],
      stato: doc['stato'],
      tipo: doc['tipo'],
    );
  }
}
*/