import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'app_colors.dart';
import 'package:hot_slice_app/ordine_model.dart';
import 'package:provider/provider.dart';
import 'carrello_provider.dart';

class CreaOrdineDialog extends StatefulWidget {
  const CreaOrdineDialog({super.key});

  @override
  State<CreaOrdineDialog> createState() => _CreaOrdineDialogState();
}

class _CreaOrdineDialogState extends State<CreaOrdineDialog> {
  String _servizioSelezionato = '';
  bool _mostraCampi = false;
  final _formKey = GlobalKey<FormState>(); // GlobalKey per la Form
  TimeOfDay? initialTime;
  TimeOfDay? selectedTime;

  TextEditingController tavoloController = TextEditingController();
  TextEditingController oraController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionSubscription;

  @override
  void initState() {
    super.initState();
    _internetConnectionSubscription =
        InternetConnection().onStatusChange.listen((event) {
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    _internetConnectionSubscription?.cancel();
    tavoloController.dispose();
    oraController.dispose();
    nomeController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    tavoloController.clear();
    oraController.clear();
    nomeController.clear();
    telefonoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Chiudi il dialogo se non c'è connessione internet
    if (!isConnectedToInternet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }

    // Accesso al provider
    final carrelloProvider =
        Provider.of<CarrelloProvider>(context, listen: false);

    return AlertDialog(
      title: const Text(
        'Scegli la modalità di ritiro',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Servizio al Tavolo"),
                value: "Servizio al Tavolo",
                groupValue: _servizioSelezionato,
                onChanged: (value) {
                  setState(() {
                    _servizioSelezionato = value!;
                    _mostraCampi = true;
                    _resetForm();
                  });
                },
                activeColor: AppColors.primaryColor,
                fillColor: MaterialStateColor.resolveWith(
                    (states) => AppColors.primaryColor),
              ),
              RadioListTile<String>(
                title: const Text("Servizio d'asporto"),
                value: "Servizio d'asporto",
                groupValue: _servizioSelezionato,
                onChanged: (value) {
                  setState(() {
                    _servizioSelezionato = value!;
                    _mostraCampi = true;
                    _resetForm();
                  });
                },
                activeColor: AppColors.primaryColor,
                fillColor: MaterialStateColor.resolveWith(
                    (states) => AppColors.primaryColor),
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: _mostraCampi,
                child: _buildCampiDinamici(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
        TextButton(
          onPressed: () {
            // Validatore per i radio button
            if (_servizioSelezionato.isEmpty) {
              Fluttertoast.showToast(msg: 'Seleziona una modalità di ritiro');
              return;
            }
            // Se la form è valida
            if (_formKey.currentState!.validate()) {
              String numeroTavolo = tavoloController.text;
              String oraRitiro = oraController.text;
              String nomeCliente = nomeController.text;
              String telefonoCliente = telefonoController.text;

              // Crea un nuovo ordine
              OrdineModel nuovoOrdine = OrdineModel(
                tavolo: numeroTavolo,
                ora: oraRitiro,
                nome: nomeCliente,
                telefono: telefonoCliente,
                tipo: _servizioSelezionato,
              );
              carrelloProvider.creaOrdine(nuovoOrdine);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ordine effettuato'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text(
            'OK',
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCampiDinamici() {
    if (_servizioSelezionato == 'Servizio al Tavolo') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inserisci il numero del tavolo',
            style: TextStyle(
              color: AppColors.myGrey,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: tavoloController,
            decoration: const InputDecoration(
              labelText: 'Numero del Tavolo',
              labelStyle: TextStyle(color: AppColors.myGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Inserisci il numero del tavolo';
              }
              return null;
            },
          ),
        ],
      );
    } else if (_servizioSelezionato == "Servizio d'asporto") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Inserisci l'orario di ritiro, il nome e il numero di telefono",
            style: TextStyle(color: AppColors.myGrey),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());

              // Inizializza il time picker a 30 minuti dopo l'ora corrente
              final now = DateTime.now();
              final in30Minutes = now.add(Duration(minutes: 30));
              initialTime = TimeOfDay(hour: in30Minutes.hour, minute: in30Minutes.minute);

              selectedTime = await showTimePicker(
                initialTime: initialTime!,
                context: context,
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primaryColor,
                        onSurface: AppColors.secondaryColor,
                      ),
                      buttonTheme: const ButtonThemeData(
                        colorScheme: ColorScheme.light(
                          primary: AppColors.primaryColor,
                        ),
                      ),
                      timePickerTheme: const TimePickerThemeData(
                        dialBackgroundColor: Color.fromARGB(255, 241, 241, 241),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedTime != null) {
                oraController.text = selectedTime!.format(context);
                // Trigger validation after selecting time
                _formKey.currentState?.validate();
              }
            },
            controller: oraController,
            decoration: const InputDecoration(
              labelText: 'Ora',
              labelStyle: TextStyle(color: AppColors.myGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Inserisci l'orario di ritiro";
              }
              if (selectedTime == null) {
                return "Seleziona un orario valido";
              }
              final now = DateTime.now();
              final in30Minutes = now.add(Duration(minutes: 30));
              final selectedDateTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              if (selectedDateTime.isBefore(in30Minutes)) {
                return "Seleziona un orario almeno 30 minuti da ora";
              }
              if (selectedDateTime.hour < 19) {
                return "Seleziona un orario tra le 19:00 e le 24:00";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              labelStyle: TextStyle(color: AppColors.myGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Inserisci il nome";
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: telefonoController,
            decoration: const InputDecoration(
              labelText: 'Telefono',
              labelStyle: TextStyle(color: AppColors.myGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  telefonoController.text.length != 10) {
                return "Inserire un numero di telefono valido";
              }
              return null;
            },
            maxLength: 10,
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}