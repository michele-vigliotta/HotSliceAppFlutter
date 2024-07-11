import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'package:provider/provider.dart';

class DettagliProdotto extends StatefulWidget {
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
  _DettagliProdottoState createState() => _DettagliProdottoState();
}

class _DettagliProdottoState extends State<DettagliProdotto> {
  int _quantita = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = '$_quantita';
  }

  void _incrementaQuantita() {
    setState(() {
      _quantita++;
      _controller.text = '$_quantita';
    });
  }

  void _decrementaQuantita() {
    if (_quantita > 0) {
      setState(() {
        _quantita--;
        _controller.text = '$_quantita';
      });
    }
  }

  void _aggiornaQuantita(String value) {
    setState(() {
      _quantita = int.tryParse(value) ?? 0;
      _controller.text = '$_quantita';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.nome,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor),
                          ),
                          Image.network(
                            widget.imageUrl,
                            height: 200.0,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error,
                                  color: AppColors.primaryColor);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    Text(
                      widget.descrizione,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '€${widget.prezzo.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _decrementaQuantita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('-'),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      width: 120.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: AppColors.primaryColor,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.0),
                          onChanged: _aggiornaQuantita,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _incrementaQuantita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text('+'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Aggiunge l'articolo al carrello
                    Provider.of<CarrelloProvider>(context, listen: false)
                        .addToCarrello(
                      CarrelloModel(
                        name: widget.nome,
                        price: widget.prezzo,
                        quantity: _quantita,
                        image: widget.imageUrl,
                        description: widget.descrizione,
                      ),
                      quantity: _quantita,
                    );
                    _aggiornaQuantita('0');
                    
                    // Mostra il messaggio "aggiunto al carrello"
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aggiunto al carrello'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                  ),
                  child: const Text(
                    'Aggiungi al carrello',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
