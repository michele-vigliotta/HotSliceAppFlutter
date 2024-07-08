import 'package:flutter/material.dart';
import 'colors.dart';

class PizzaList extends StatelessWidget {
  const PizzaList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Esempio di lista fittizia, sostituisci con il recupero dati reale
    final List<Map<String, dynamic>> pizze = [
      {
        'name': 'Margherita',
        'price': '€5.00',
        'imageUrl': 'https://example.com/margherita.png', // Sostituisci con URL reale
      },
      {
        'name': 'Pepperoni',
        'price': '€6.00',
        'imageUrl': 'https://example.com/pepperoni.png', // Sostituisci con URL reale
      },
      // Aggiungi altre pizze qui
    ];

    return ListView.builder(
      itemCount: pizze.length,
      itemBuilder: (context, index) {
        return PizzaItem(
          name: pizze[index]['name']!,
          price: pizze[index]['price']!,
          imageUrl: pizze[index]['imageUrl']!,
        );
      },
    );
  }
}

class PizzaItem extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;

  const PizzaItem({
    Key? key,
    required this.name,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // FrameLayout equivalente
            Container(
              width: 120.0,
              height: 100.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ProgressBar (caricamento immagine)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                  // Immagine (visibile una volta caricata)
                  Image.network(
                    imageUrl,
                    width: 120.0,
                    height: 100.0,
                    fit: BoxFit.fitWidth,
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
            const SizedBox(width: 8.0),
            // Colonna con Nome e Prezzo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(width: 10), // Aggiunge spazio tra nome e prezzo
                      Text(
                        price,
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
    );
  }
}
