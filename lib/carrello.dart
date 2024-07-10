import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'colors.dart';

class Carrello extends StatelessWidget {
  const Carrello({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrello'),
      ),
      body: Consumer<CarrelloProvider>(
        builder: (context, carrelloProvider, child) {
          List<CarrelloModel> listaCarrello = carrelloProvider.listaCarrello;

          return ListView.builder(
            itemCount: listaCarrello.length,
            itemBuilder: (context, index) {
              final item = listaCarrello[index];
              return Card(
                elevation: 4.0,
                margin: const EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        child: Stack(
                          children: [
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                              ),
                            ),
                            Center(
                              child: item.image.isNotEmpty
                                  ? Image.network(
                                      item.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.fitHeight,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.error, color: AppColors.primaryColor);
                                      },
                                    )
                                  : Icon(Icons.error, color: AppColors.primaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.myGrey,
                              ),
                            ),
                            Text(
                              '€${item.price.toStringAsFixed(2)}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: AppColors.myGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          carrelloProvider.removeFromCarrello(item);
                        },
                      ),
                      Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          carrelloProvider.addToCarrello(item);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Esempio di aggiunta di un nuovo elemento al carrello
          Provider.of<CarrelloProvider>(context, listen: false).addToCarrello(
            CarrelloModel(
              name: 'Nuovo Elemento',
              price: 10.0,
              quantity: 1,
              image: "",
              description: "",
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}