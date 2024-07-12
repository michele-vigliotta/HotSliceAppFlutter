import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.nome;
    _descrizioneController.text = widget.descrizione;
    _prezzoController.text = widget.prezzo.toString();
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

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Immagine caricata con successo')));
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Errore durante il caricamento dell\'immagine')));
    }
  }

  Future<void> _updateOffer() async {
    String nome = _nomeController.text;
    String descrizione = _descrizioneController.text;
    String prezzo = _prezzoController.text;

    if (nome.isEmpty || descrizione.isEmpty || prezzo.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Compilare tutti i campi')));
      return;
    }

    double prezzoNum = double.parse(prezzo);

    Map<String, dynamic> updatedOffer = {
      'nome': nome,
      'prezzo': prezzoNum,
      'descrizione': descrizione,
      'foto': _uploadedImageUrl ??
          widget.imageUrl, // Usa l'immagine caricata o quella esistente
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
        Fluttertoast.showToast(msg: 'Offerta aggiornata con successo');
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento dell\'offerta: $e');
      Fluttertoast.showToast(
          msg: 'Si è verificato un errore, si prega di riprovare');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifica Offerta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.nome,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold
              ),
            ),
            TextField(
              controller: _descrizioneController,
              decoration: InputDecoration(labelText: 'Descrizione'),
            ),
            TextField(
              controller: _prezzoController,
              decoration: InputDecoration(labelText: 'Prezzo'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _imageFile == null
                ? Column(
                    children: [
                      Image.network(widget.imageUrl,
                          height: 100), // Mostra l'immagine corrente
                      SizedBox(height: 8),
                    ],
                  )
                : Column(
                    children: [
                      Image.file(_imageFile!,
                          height: 100), // Mostra l'immagine selezionata
                      SizedBox(height: 8),
                    ],
                  ),
            ElevatedButton(
              onPressed: _isUploading ? null : _pickImage,
              child: Text('Cambia immagine'),
            ),
            _isUploading ? CircularProgressIndicator() : SizedBox.shrink(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _updateOffer,
          child: Text('Aggiorna'),
        ),
      ],
    );
  }
}
