import 'package:flutter/material.dart';
import 'carrello_model.dart';

class CarrelloProvider extends ChangeNotifier{
  List<CarrelloModel> _listaCarrello = [];
  List<CarrelloModel> get listaCarrello => _listaCarrello; //getter

  /* Metodo per aggiungere un prodotto al carrello
  quantity é facoltativo(di default = 1). In questo modo posso usare questo metodo
  sia per il carrello(il pulsante + aumenta sempre di 1), sia per dettagli che puó aumentare
  anche di numeri maggiori a 1
  */
  void addToCarrello(CarrelloModel item, {int quantity = 1}) {
      //Verifico se é giá presente in lista
      int index = _listaCarrello.indexWhere((element) => element.name == item.name); //lambda che restituisce l'indice del primo elemento che soddisfa la condizione
      if (index != -1) { //index é diverso da -1 se il prodotto é in lista
        _listaCarrello[index].quantity += quantity;
      } else {
        _listaCarrello.add(item);
      }
      notifyListeners(); // Notifica ai widget in ascolto che lo stato è cambiato
  }

  // Metodo per aggiungere un elemento al carrello
  void removeFromCarrello(CarrelloModel item, ) {
      //Se é giá presente diminuisco la quantitá
      int index = _listaCarrello.indexWhere((element) => element.name == item.name);
      if (index != -1) {
        _listaCarrello[index].quantity --;
          //Controllo la quantitá finale
          if (_listaCarrello[index].quantity < 1){
            _listaCarrello.removeAt(index);
          }
      } else {
        _listaCarrello.remove(item);
      }
    notifyListeners();
  }
}