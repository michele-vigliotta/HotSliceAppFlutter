import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_slice_app/colors.dart';
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
  var initialTime;
  TimeOfDay? selectedTime;

  TextEditingController tavoloController = TextEditingController();
  TextEditingController oraController = TextEditingController();
  TextEditingController nomeController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  @override
  void dispose() {
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
    //accesso al provider
    final carrelloProvider =
        Provider.of<CarrelloProvider>(context, listen: false);

    return AlertDialog(
      title: const Text(
        'Scegli la modalitá di ritiro',
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
            // validatore per i radio button
            if (_servizioSelezionato.isEmpty) {
              Fluttertoast.showToast(msg: 'Seleziona una modalità di ritiro');
              return;
            }
            // Se la form é valida
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
                borderSide: BorderSide(color: Colors.yellow),
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

              //In questo modo il time picker parte da 30 min dopo l'ora corrente se sono passate le 19
              final now = DateTime.now();

              final in30Minutes = now.add(Duration(minutes: 30));
              initialTime =
                  TimeOfDay(hour: in30Minutes.hour, minute: in30Minutes.minute);

              selectedTime = await showTimePicker(
                initialTime: initialTime,
                context: context,
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                      data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors
                                .primaryColor, // Colore principale del time picker
                            onSurface: AppColors
                                .secondaryColor, // Colore dei numeri e delle etichette
                          ),
                          buttonTheme: const ButtonThemeData(
                            colorScheme: ColorScheme.light(
                              primary: AppColors
                                  .primaryColor, // Colore dei bottoni (OK e Cancel)
                            ),
                          ),
                          timePickerTheme: const TimePickerThemeData(
                            dialBackgroundColor:
                                Color.fromARGB(255, 241, 241, 241),
                          )),
                      child: child!);
                },
              );
              if (selectedTime != null) {
                oraController.text = selectedTime!.format(context);
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
              } else if (!(selectedTime!.hour >= initialTime.hour &&
                  selectedTime!.hour <= 23)) {
                return "Seleziona un orario tra le 19:00 e le 24:00,\nalmeno 30 minuti da ora";
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
