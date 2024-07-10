import 'package:flutter/material.dart';
import 'carrello_model.dart';

class CarrelloProvider extends ChangeNotifier{
  List<CarrelloModel> _listaCarrello = [];
  List<CarrelloModel> get listaCarrello => _listaCarrello; //getter

  // Metodo per aggiungere un prodotto al carrello
  void addToCarrello(CarrelloModel item) {
      //Verifico se é giá presente in lista
      int index = _listaCarrello.indexWhere((element) => element.name == item.name); //lambda che restituisce l'indice del primo elemento che soddisfa la condizione
      if (index != -1) { //index é diverso da -1 se il prodotto é in lista
        _listaCarrello[index].quantity += item.quantity;
      } else {
        _listaCarrello.add(item);
      }
      notifyListeners(); // Notifica ai widget in ascolto che lo stato è cambiato
  }

  // Metodo per aggiungere un elemento al carrello
  void removeFromCarrello(CarrelloModel item) {
      //Se é giá presente diminuisco la quantitá
      int index = _listaCarrello.indexWhere((element) => element.name == item.name);
      if (index != -1) {
        _listaCarrello[index].quantity--;
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