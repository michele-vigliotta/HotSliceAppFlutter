import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_slice_app/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NewOfferDialog extends StatefulWidget {
  final Function onOfferAdded;

  NewOfferDialog({required this.onOfferAdded});

  @override
  _NewOfferDialogState createState() => _NewOfferDialogState();
}

class _NewOfferDialogState extends State<NewOfferDialog> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _prezzoController = TextEditingController();

  final FocusNode _nomeFocusNode = FocusNode();
  final FocusNode _descrizioneFocusNode = FocusNode();
  final FocusNode _prezzoFocusNode = FocusNode();

  File? _imageFile;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  bool isConnectedToInternet = true;
  StreamSubscription? _internetConnectionSubscription;

  final _formKey = GlobalKey<FormState>();

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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage(); // Carica l'immagine subito dopo averla selezionata
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });
      Fluttertoast.showToast(msg: 'Immagine caricata con successo');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      Fluttertoast.showToast(msg: 'Immagine caricata con successo');
    }
  }

  Future<void> _addOffer() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  String nome = _nomeController.text;
  String descrizione = _descrizioneController.text;
  String prezzo = _prezzoController.text;

  double prezzoNum = double.parse(prezzo);

  // Check if offer with the same name already exists
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('offerte')
      .where('nome', isEqualTo: nome)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    // Offer with the same name already exists
    Fluttertoast.showToast(msg: 'Offerta già esistente');
    return;
  }

  // Proceed to add the new offer
  Map<String, dynamic> newOffer = {
    'nome': nome,
    'prezzo': prezzoNum,
    'descrizione': descrizione,
    'foto': _uploadedImageUrl,
  };

  await FirebaseFirestore.instance.collection('offerte').add(newOffer);

  widget.onOfferAdded();

  Navigator.of(context).pop();
}

  @override
  Widget build(BuildContext context) {
    // Chiudi il dialogo se non c'è connessione internet
  if (!isConnectedToInternet) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
  }

    return AlertDialog(
      title: Center(
        child: Text(
          'Nuova Offerta',
          style: TextStyle(color: AppColors.primaryColor),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                focusNode: _nomeFocusNode,
                decoration: InputDecoration(labelText: 'Nome',
                labelStyle: TextStyle(color: AppColors.myGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descrizioneFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              TextFormField(
                  controller: _descrizioneController,
                  focusNode: _descrizioneFocusNode,
                  decoration: InputDecoration(labelText: 'Descrizione',
                  labelStyle: TextStyle(color: AppColors.myGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_prezzoFocusNode);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una descrizione';
                    }
                    return null;
                  }),
              TextFormField(
                controller: _prezzoController,
                focusNode: _prezzoFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un prezzo';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Prezzo',
                labelStyle: TextStyle(color: AppColors.myGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _imageFile == null
                  ? Text('Nessuna immagine selezionata'
                  )
                  : Image.file(_imageFile!, height: 150),
              SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                onPressed: _isUploading ? null : _pickImage,
                child: Text('Seleziona Immagine',
                style: TextStyle(color: Colors.black)),
              ),
              _isUploading ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      actions: [
        Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 18.0),
            ),
          ),
          TextButton(
            onPressed: _isUploading ? null : _addOffer,
            child: Text(
              'Aggiorna',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 18.0),
            ),
          ),
        ]))
      ],
    );
  }
}
