import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'dettagli_prodotto.dart';


class PizzaList extends StatelessWidget {
  const PizzaList({super.key});
   
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pizze').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pizzas available'));
        }

        final pizzas = snapshot.data!.docs;

        return ListView.builder(
          itemCount: pizzas.length,
          itemBuilder: (context, index) {
            final pizza = pizzas[index].data() as Map<String, dynamic>;
            return PizzaItem(
              nome: pizza['nome'] ?? 'Unnamed Pizza',
              prezzo: pizza['prezzo']?.toDouble() ?? 0.0,
              imageUrl: pizza['foto'] ?? 'https://example.com/default.png',
              descrizione: pizza['descrizione'] ?? 'No description available',
            );
          },
        );
      },
    );
  }
}

class PizzaItem extends StatelessWidget {
  final String nome;
  final double prezzo;
  final String imageUrl;
  final String descrizione;

  const PizzaItem({
    super.key,
    required this.nome,
    required this.prezzo,
    required this.imageUrl,
    required this.descrizione,
  });

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
              SizedBox(
                width: 120.0,
                height: 100.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    Image.network(
                      imageUrl,
                      width: 120.0,
                      height: 100.0,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 120.0,
                          height: 100.0,
                          child: Icon(Icons.error, color: AppColors.primaryColor),
                        );
                      },
                    ),
                  ],
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
