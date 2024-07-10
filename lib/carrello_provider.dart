import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hot_slice_app/ordine_model.dart';
import 'package:intl/intl.dart';
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
  void removeFromCarrello(CarrelloModel item) {
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

  double calcolaTotale() {
    double totale = 0;
    for (var element in _listaCarrello) {
      totale += (element.price * element.quantity);
    }
    return totale;
  }

  void creaOrdine(OrdineModel nuovoOrdine) async{

    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    String data = formatter.format(DateTime.now());
    String descrizione = '';
    //CarrelloModel prodotto = CarrelloModel();
    for (CarrelloModel prodotto in _listaCarrello){
      descrizione += "Nome: ${prodotto.name}, Quantità: ${prodotto.quantity};\n";
    }
    
    try{
      Map<String, dynamic> documento = {
        'data': data,
        'descrizione': descrizione,
        'nome': nuovoOrdine.nome,
        'ora': nuovoOrdine.ora,
        'stato':"in corso",
        'tavolo': nuovoOrdine.tavolo,
        'telefono': nuovoOrdine.telefono,
        'tipo': nuovoOrdine.tipo,
        'totale': calcolaTotale().toStringAsFixed(2),
      
      };

      CollectionReference ordini = FirebaseFirestore.instance.collection('ordini');
      await ordini.add(documento);
      _listaCarrello.clear();
      notifyListeners();

    }catch (e){
      print('Errore durante la creazione dell\'ordine: $e');
    }
  }
}