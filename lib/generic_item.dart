import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GenericItem extends StatelessWidget {
  final String nome;
  final double prezzo;
  final String imageUrl;
  final String descrizione;

  const GenericItem({
    super.key,
    required this.nome,
    required this.prezzo,
    required this.imageUrl,
    required this.descrizione,
  });

  factory GenericItem.fromDocument(DocumentSnapshot doc) {
    return GenericItem(
      nome: doc['nome'] ?? '',
      prezzo: (doc['prezzo'] ?? 0).toDouble(),
      imageUrl: doc['foto'] ?? '',
      descrizione: doc['descrizione'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'prezzo': prezzo,
      'foto': imageUrl,
      'descrizione': descrizione,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : Container(width: 50, height: 50, color: Colors.grey),
        title: Text(nome),
        subtitle: Text(descrizione),
        trailing: Text('€$prezzo'),
      ),
    );
  }
}