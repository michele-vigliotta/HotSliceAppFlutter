import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_slice_app/crea_ordine_dialog.dart';
import 'package:provider/provider.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'colors.dart';

class Carrello extends StatelessWidget {
  const Carrello({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Carrello',
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
      ),
      body: Consumer<CarrelloProvider>(
        builder: (context, carrelloProvider, child) {
          List<CarrelloModel> listaCarrello = carrelloProvider.listaCarrello;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
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
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor),
                                    ),
                                  ),
                                  Center(
                                    child: item.image.isNotEmpty
                                        ? Image.network(
                                            item.image,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.fitHeight,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.error,
                                                  color:
                                                      AppColors.primaryColor);
                                            },
                                          )
                                        : const Icon(Icons.error,
                                            color: AppColors.primaryColor),
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
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text(
                                '-',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                              onPressed: () {
                                carrelloProvider.removeFromCarrello(item);
                              },
                            ),
                            Text(
                              item.quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: AppColors.myGrey,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text(
                                '+',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                              onPressed: () {
                                carrelloProvider.addToCarrello(item);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Totale: €${carrelloProvider.calcolaTotale().toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColors.myGrey,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (carrelloProvider.listaCarrello.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Aggiungere prodotti al carrello prima di continuare'),
                        duration: Duration(seconds: 1, milliseconds: 250),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext) {
                        return const CreaOrdineDialog();
                      },
                    );
                  }
                },
                child: const Text("Procedi con l'ordine!",
                    style: TextStyle(
                      fontSize: 18,
                    )),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
