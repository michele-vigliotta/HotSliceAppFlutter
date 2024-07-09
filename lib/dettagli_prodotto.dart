import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'colors.dart';

class DettagliProdotto extends StatelessWidget {
  final String nome;
  final double prezzo;
  final String imageUrl;
  final String descrizione;

  const DettagliProdotto({
    Key? key,
    required this.nome,
    required this.prezzo,
    required this.imageUrl,
    required this.descrizione,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25.0),
                  Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                      Center(
                        child: Image.network(
                          imageUrl,
                          height: 200.0,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error,
                                color: AppColors.primaryColor);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30.0),
                  Text(
                    '€${prezzo.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    descrizione,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Implement minus button functionality
                          Provider.of<CarrelloProvider>(context, listen: false)
                              .removeFromCarrello(
                            CarrelloModel(
                              name: 'Nuovo Elemento',
                              price: 10.0,
                              quantity: 1,
                              image: "",
                              description: "",
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Text('-'),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        width: 52.0,
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: '0'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          // Implement plus button functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Text('+'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Checkbox(
                    value: false,
                    onChanged: (bool? value) {
                      // Implement favorite button functionality
                    },
                    shape: CircleBorder(),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Implement add to cart functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text(
                      'Aggiungi al carrello',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  /*const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Implement modify product functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    child: const Text(
                      'Modifica Prodotto',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
