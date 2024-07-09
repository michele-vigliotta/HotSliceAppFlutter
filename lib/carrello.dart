import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';

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
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Prezzo: ${item.price} - Quantità: ${item.quantity}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    carrelloProvider.removeFromCarrello(item);
                  },
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
        child: Icon(Icons.add),
      ),
    );
  }
}
