import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'app_colors.dart';
import 'dettagli_prodotto.dart';

class GenericList extends StatelessWidget {
  final String collectionName;
  final String searchQuery;

  const GenericList({
    Key? key,
    required this.collectionName,
    required this.searchQuery,
  }) : super(key: key);

  void _showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
    );
  }

  Future<String> _getImageUrl(String imageName) async {
    try {
      final Reference ref = FirebaseStorage.instance.ref().child(imageName);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Errore nel recupero dell\'URL dell\'immagine: $e');
      return 'https://example.com/default.png'; // URL immagine di default
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          _showToast(context, '$collectionName non presente nel menù');
          return Center(child: Text('$collectionName non presente nel menù'));
        }

        final items = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = data['nome']?.toString().toLowerCase() ?? '';
          return nome.contains(searchQuery.toLowerCase());
        }).toList();

        if (items.isEmpty) {
          _showToast(context, 'Nessun prodotto corrisponde alla ricerca');
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index].data() as Map<String, dynamic>;
            final imageName = item['foto']?.toString() ?? 'assets/default.png';
            return FutureBuilder<String>(
              future: _getImageUrl(imageName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: 120.0,
                    height: 100.0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Container(
                    width: 120.0,
                    height: 100.0,
                    child: Icon(Icons.error, color: AppColors.primaryColor),
                  );
                }

                final imageUrl = snapshot.data ?? 'https://example.com/default.png';
                return GenericItem(
                  nome: item['nome'] ?? 'Unnamed Item',
                  prezzo: item['prezzo']?.toDouble() ?? 0.0,
                  imageUrl: imageUrl,
                  descrizione: item['descrizione'] ?? 'No description available',
                );
              },
            );
          },
        );
      },
    );
  }
}

class GenericItem extends StatelessWidget {
  final String nome;
  final double prezzo;
  final String imageUrl;
  final String descrizione;

  const GenericItem({
    Key? key,
    required this.nome,
    required this.prezzo,
    required this.imageUrl,
    required this.descrizione,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DettagliProdotto(
              nome: nome,
              prezzo: prezzo,
              imageUrl: imageUrl,
              descrizione: descrizione,
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
              Container(
                width: 120.0,
                height: 100.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                      Image.network(
                        imageUrl,
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
                            nome,
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
                          '€${prezzo.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15.0,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
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
