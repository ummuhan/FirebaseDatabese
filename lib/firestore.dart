import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FireStoreIslem extends StatefulWidget {
  FireStoreIslem({Key key}) : super(key: key);

  @override
  _FireStoreIslemState createState() => _FireStoreIslemState();
}

class _FireStoreIslemState extends State<FireStoreIslem> {
  final Firestore _firestore = Firestore.instance;
  File _secilenResim;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FireStore"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Kişi ekle"),
              color: Colors.orange,
              onPressed: kisiekle,
            ),
            RaisedButton(
              child: Text("Transactions ekle"),
              color: Colors.pink,
              onPressed: transactionsekle,
            ),
            RaisedButton(
              child: Text("Silme"),
              color: Colors.yellow,
              onPressed: deleteIslem,
            ),
            RaisedButton(
              child: Text("Veri oku"),
              color: Colors.blue[300],
              onPressed: veriOku,
            ),
            RaisedButton(
              child: Text("Veri sorgula"),
              color: Colors.purple[300],
              onPressed: veriSorgula,
            ),
            RaisedButton(
              child: Text("Galeriden storege'a resim yükle"),
              color: Colors.red.shade200,
              onPressed: galeriResimUpload,
            ),
            RaisedButton(
              child: Text("Kameradan storage a resim yükle"),
              color: Colors.green.shade200,
              onPressed: kameraResimUpload,
            ),
            Expanded(
              child: _secilenResim == null
                  ? Text("Resim yok")
                  : Image.file(_secilenResim),
            )
          ],
        ),
      ),
    );
  }

  void kisiekle() {
    Map<String, dynamic> kisiekle = Map();
    kisiekle["ad"] = "ummuhan oksuz";
    kisiekle["yas"] = 22;
    _firestore.collection("users").document("ummuhan").setData(kisiekle).then(
        (v) => debugPrint("Ummuhan eklendi")); //Map olarak sunmamızı ister
    _firestore.collection("users").document("furkan").setData({
      'ad': "furkan",
      'cinsiyet': 'erkek',
      'begenisayisi': FieldValue.increment(10)
    }).then((v) => debugPrint("Furkan eklendi."));
    _firestore.document('/users/gokce').setData({
      'ad': 'gökçe',
      'cinsiyet': 'kız',
      'eklenme': FieldValue.serverTimestamp()
    }).then((v) =>
        debugPrint("Gökçe eklendi.")); //Tarih kaydetmemizi sağlamaktadır.

    _firestore.document('/users/ummuhan').updateData({'ad': 'ebrar'}).then(
        (v) => debugPrint("Ümmühan güncellendi"));
  }

  void transactionsekle() {
    final DocumentReference furkanref = _firestore.document('/users/furkan');

    _firestore.runTransaction((Transaction transaction) async {
      DocumentSnapshot furkanData =
          await furkanref.get(); //Furkanın özelliklerini getirir.

      if (furkanData.exists) {
        //FurkanData var mı yok mu bu kontrol edilmektedir.
        var furkaninparasi = furkanData.data['para'];
        if (furkaninparasi > 100) {
          await transaction.update(furkanref, furkaninparasi - 100);
          await transaction.update(_firestore.document('users/gokce'),
              {'para': FieldValue.increment(100)});
        } else {
          debugPrint("Yetersiz bakiye.");
        }
      } else {
        debugPrint("Furkan dökümanı boş.");
      }
    });
  }

  void deleteIslem() {
    _firestore
        .document('/users/ummuhan')
        .delete()
        .then((v) => debugPrint("Döküman silindi."))
        .catchError((e) => debugPrint("Hata oluştu"));
    _firestore
        .document('/users/gokce')
        .updateData({'ad': FieldValue.delete()}).then(
            (v) => debugPrint("Veri başarıya silindi."));
  }

  void veriOku() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.document('/users/furkan').get();
    debugPrint("Document id" + documentSnapshot.documentID);
    debugPrint("Document içerik" +
        documentSnapshot.metadata.hasPendingWrites.toString());
    debugPrint("Document var mı?" + documentSnapshot.exists.toString());
    String a = '1'; //İşime yarar
    DocumentSnapshot snapshot =
        await _firestore.collection('sozluk').document(a).get();
    debugPrint("Document id" + snapshot.documentID);
    debugPrint("Document 1 data" + snapshot.data[a].toString()); //İşime yarar
  }

  Future<void> veriSorgula() async {
    var dokumanlar = await _firestore
        .collection('users')
        .where('email', isEqualTo: 'ummuhan@gmail.com')
        .getDocuments();
    for (var dokuman in dokumanlar.documents) {
      debugPrint("Email ummuhan olanlar" + dokuman.data.toString());
    }
    var limitligetir =
        await _firestore.collection('users').limit(4).getDocuments();
    for (var dokuman in limitligetir.documents) {
      debugPrint("limitli getir " + dokuman.data.toString());
    }
  }

  Future<void> galeriResimUpload() async {
    var resim = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _secilenResim = resim;
    });

    var ref = FirebaseStorage.instance.ref().child('users').child('ummuhan').child('profilphotos');
   StorageUploadTask uploadTask= ref.putFile(_secilenResim);
   
     var url=await(await uploadTask.onComplete).ref.getDownloadURL();
     debugPrint("Resim yüklendi"+url);
   
  }

  void kameraResimUpload() async {
    var resim = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _secilenResim = resim;
    });
     var ref = FirebaseStorage.instance.ref().child('users').child('furkan').child('profilphotos');
StorageUploadTask uploadTask= ref.putFile(_secilenResim);
   
  var url=await(await uploadTask.onComplete).ref.getDownloadURL();
  debugPrint("Resim yüklendi"+url);
  }
}
