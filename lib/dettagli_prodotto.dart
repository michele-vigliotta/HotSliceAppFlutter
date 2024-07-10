import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'carrello_model.dart';
import 'carrello_provider.dart';
import 'colors.dart';

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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _quantita.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateQuantita(int x) {
    setState(() {
      _quantita = (_quantita + x).clamp(0, 100);
      _controller.text = _quantita.toString();
    });
  }

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
                    widget.nome,
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
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor),
                        ),
                      ),
                      Center(
                        child: Image.network(
                          widget.imageUrl,
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
                    '€${widget.prezzo.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.descrizione,
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
                          if (_quantita > 0) {
                            _updateQuantita(-1);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('-'),
                      ),
                      const SizedBox(width: 8.0),
                      SizedBox(
                        width: 52.0,
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: _controller,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          // Implement plus button functionality
                          _updateQuantita(1);
                        },
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
                  Checkbox(
                    value: false,
                    onChanged: (bool? value) {
                      // Implement favorite button functionality
                    },
                    shape: const CircleBorder(),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Implement add to cart functionality
                      Provider.of<CarrelloProvider>(context, listen: false)
                          .addToCarrello(
                        CarrelloModel(
                          name: '${widget.nome}',
                          price: widget.prezzo,
                          quantity: _quantita,
                          image: "",
                          description: "${widget.descrizione}",
                        ),
                        quantity: _quantita,
                      );
                      _updateQuantita(-_quantita);
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
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
