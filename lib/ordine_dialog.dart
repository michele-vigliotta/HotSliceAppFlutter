import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'app_colors.dart';
import 'ordini.dart'; 


class OrdineDialog extends StatefulWidget {
  final ItemOrdine ordine;
  final Function aggiorna;

  const OrdineDialog({
    required this.ordine,
    required this.aggiorna,
    Key? key,
  }) : super(key: key);

  @override
  _OrdineDialogState createState() => _OrdineDialogState();
}

class _OrdineDialogState extends State<OrdineDialog> {
  int _selectedOrderAction = 0; // 0: Accetta, 1: Rifiuta
  TimeOfDay? selectedTime;
  TextEditingController oraController = TextEditingController();

  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionSubscription;

  Stream<InternetStatus> internetStatusStream =
      InternetConnection().onStatusChange; //  Per il timepicker

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
       // Chiudi il dialog se non c'è connessione internet
  if (!isConnectedToInternet) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
  }

    return AlertDialog(
      title: Text('Gestione Ordine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Radio<int>(
                value: 0,
                groupValue: _selectedOrderAction,
                activeColor: AppColors.primaryColor,
                fillColor: MaterialStateColor.resolveWith(
                    (states) => AppColors.primaryColor),
                onChanged: (value) {
                  setState(() {
                    _selectedOrderAction = value!;
                  });
                },
              ),
              const Text('Accetta Ordine'),
            ],
          ),
          Row(
            children: [
              Radio<int>(
                value: 1,
                groupValue: _selectedOrderAction,
                activeColor: AppColors.primaryColor,
                fillColor: MaterialStateColor.resolveWith(
                    (states) => AppColors.primaryColor),
                onChanged: (value) {
                  setState(() {
                    _selectedOrderAction = value!;
                  });
                },
              ),
              const Text('Rifiuta Ordine'),
            ],
          ),
          if (_selectedOrderAction == 0 && widget.ordine.tipo == "Servizio d'Asporto")
            TextFormField(
              onTap: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                        return StreamBuilder<InternetStatus>(
                          stream: internetStatusStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data == InternetStatus.disconnected) {
                              Navigator.of(context).pop();
                              return Container();
                            }
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
                                      dialBackgroundColor:
                                          Color.fromARGB(255, 241, 241, 241),
                                    )),
                                child: child!);
                          },
                        );
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
            ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Annulla',
          style: TextStyle(color: AppColors.primaryColor),),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Conferma',
            style: TextStyle(color: AppColors.primaryColor),
          ),
          onPressed: () async {
            if (_selectedOrderAction == 0) {
              //accetta
              try {
                CollectionReference ordini =
                    FirebaseFirestore.instance.collection('ordini');
                if (widget.ordine.tipo == "Servizio d'Asporto") {
                  //asporto

                  if (oraController.text == '' ||
                      oraController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Inserisci l'orario di ritiro");
                    return null;
                  }

                  await ordini.doc(widget.ordine.id).update({
                    'stato': 'Accettato',
                    'ora': oraController.text,
                  });
                } else {
                  //tavolo
                  await ordini.doc(widget.ordine.id).update({
                    'stato': 'Accettato',
                  });
                }
                widget.aggiorna();

                Fluttertoast.showToast(msg: "Ordine Accettato");
              } catch (e) {
                Fluttertoast.showToast(
                    msg: "Errore durante l'iserimento, riprovare");
              }
            } else {
              //rifiuta
              try {
                CollectionReference ordini =
                    FirebaseFirestore.instance.collection('ordini');

                await ordini.doc(widget.ordine.id).update({
                  'stato': 'Rifiutato',
                });
                widget.aggiorna();
                Fluttertoast.showToast(msg: "Ordine Rifiutato");
              } catch (e) {
                Fluttertoast.showToast(
                    msg: "Errore durante l'iserimento, riprovare");
              }
            }

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}