import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;
  bool _isUploading = false;
  String? _uploadedImageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

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
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(_imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Immagine caricata con successo')));
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante il caricamento dell\'immagine')));
    }
  }

  Future<void> _addOffer() async {
    String nome = _nomeController.text;
    String descrizione = _descrizioneController.text;
    String prezzo = _prezzoController.text;

    if (nome.isEmpty || descrizione.isEmpty || prezzo.isEmpty || _uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Compilare tutti i campi')));
      return;
    }

    double prezzoNum = double.parse(prezzo);

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
    return AlertDialog(
      title: Text('Nuova Offerta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
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
                ? Text('Nessuna immagine selezionata')
                : Image.file(_imageFile!),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isUploading ? null : _pickImage,
              child: Text('Seleziona Immagine'),
            ),
            _isUploading
                ? CircularProgressIndicator()
                : SizedBox.shrink(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _addOffer,
          child: Text('Aggiungi'),
        ),
      ],
    );
  }
}
