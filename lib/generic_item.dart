import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GenericItem extends StatelessWidget {
  final String nome;
  final double prezzo;
  final String fileName; // Nome del file nello storage
  final String descrizione;

  const GenericItem({
    Key? key,
    required this.nome,
    required this.prezzo,
    required this.fileName,
    required this.descrizione,
  }) : super(key: key);

  Future<String> get imageUrl async {
    try {
      final Reference ref = FirebaseStorage.instance.ref().child(fileName);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Errore nel recupero dell\'URL dell\'immagine: $e');
      return 'assets/images/pizza_foto.png'; // URL immagine di default
    }
  }

  factory GenericItem.fromDocument(DocumentSnapshot doc) {
    return GenericItem(
      nome: doc['nome'] ?? '',
      prezzo: (doc['prezzo'] ?? 0).toDouble(),
      fileName: doc['foto'] ?? '', // Assume che 'foto' contenga solo il nome del file
      descrizione: doc['descrizione'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrl,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 120,
            height: 100,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            width: 120,
            height: 100,
            color: Colors.grey,
            child: Icon(Icons.error, color: Colors.red),
          );
        }
        final url = snapshot.data ?? 'assets/images/pizza_foto.png';
        return Card(
          child: ListTile(
            leading: Image.network(url, width: 50, height: 50, fit: BoxFit.cover),
            title: Text(nome),
            subtitle: Text(descrizione),
            trailing: Text('€$prezzo'),
          ),
        );
      },
    );
  }
}
