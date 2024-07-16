import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hot_slice_app/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ModificaOffertaDialog extends StatefulWidget {
  final String nome;
  final String descrizione;
  final double prezzo;
  final String imageUrl;
  final Function onOfferEdited;

  ModificaOffertaDialog({
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.imageUrl,
    required this.onOfferEdited,
  });

  @override
  _ModificaOffertaDialogState createState() => _ModificaOffertaDialogState();
}

class _ModificaOffertaDialogState extends State<ModificaOffertaDialog> {
  
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _prezzoController = TextEditingController();
  
  final FocusNode _descrizioneFocusNode = FocusNode();
  final FocusNode _prezzoFocusNode = FocusNode();

  File? _imageFile;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  String? fileName;

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
    _nomeController.text = widget.nome;
    _descrizioneController.text = widget.descrizione;
    _prezzoController.text = widget.prezzo.toString();
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
      fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref('$fileName').putFile(_imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      Fluttertoast.showToast(msg:'Immagine caricata con successo');
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      Fluttertoast.showToast(msg:'Errore durante il caricamneto dell\'immagine');
    }
  }

  Future<void> _updateOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String nome = _nomeController.text;
    String descrizione = _descrizioneController.text;
    String prezzo = _prezzoController.text;

    double prezzoNum = double.parse(prezzo);

    Map<String, dynamic> updatedOffer = {
      'nome': nome,
      'prezzo': prezzoNum,
      'descrizione': descrizione,
      'foto': fileName ??
          widget.imageUrl.split('?').first.split('/').last, // Usa l'immagine caricata o quella esistente
    };

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('offerte')
          .where('nome', isEqualTo: widget.nome)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('offerte')
              .doc(doc.id)
              .update(updatedOffer);
        }

        widget.onOfferEdited();
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento dell\'offerta: $e');
      Fluttertoast.showToast(
          msg: 'Si è verificato un errore, si prega di riprovare');
    }
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
          'Modifica Offerta',
          style: TextStyle(color: AppColors.primaryColor),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.nome,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _descrizioneController,
                focusNode: _descrizioneFocusNode,
                decoration: InputDecoration(
                  labelText: 'Descrizione',
                  labelStyle: TextStyle(color: AppColors.myGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_prezzoFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prezzoController,
                focusNode: _prezzoFocusNode,
                decoration: InputDecoration(
                  labelText: 'Prezzo',
                  labelStyle: TextStyle(color: AppColors.myGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondaryColor),
                  ),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un prezzo';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              _imageFile == null
                  ? Column(
                      children: [
                        Image.network(widget.imageUrl, height: 150), // Mostra l'immagine corrente
                        SizedBox(height: 8),
                      ],
                    )
                  : Column(
                      children: [
                        Image.file(_imageFile!, height: 150), // Mostra l'immagine selezionata
                        SizedBox(height: 8),
                      ],
                    ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
                onPressed: _isUploading ? null : _pickImage,
                child: Text(
                  'Cambia immagine',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              _isUploading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
      actions: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  'Annulla',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 18.0),
                ),
              ),
              TextButton(
                onPressed: _isUploading ? null : _updateOffer,
                child: Text(
                  'Aggiorna',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 18.0),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}