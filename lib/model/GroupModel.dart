import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Group{

  //Atributs
  String _Id = Uuid().v4();
  String _Name;
  File _Image;
  String _ImageURL;
  String _Owner;

  //Initialize
  Group();

  Group.IfId (String id){
    this._Id = id;
  }

  //Mapping for serialization
  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id" : this.Id,
      "name" : this.Name,
      "image" : this._ImageURL,
      "owner" : this.Owner
    };

    return map;
  }

  save() {
    Firestore db = Firestore.instance;
    db.collection("groups")
        .document( this.Id )
        .setData( this.toMap() );

    _uploadImagem();

    return;
  }

  Future _uploadImagem() async {

    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("groups")
        .child(this.Id + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile(this._Image);
    task.onComplete.then((StorageTaskSnapshot snapshot){
      _updateImageURL(snapshot);
    });
  }

  Future _updateImageURL(StorageTaskSnapshot snapshot)  async {
    String url = await snapshot.ref.getDownloadURL();
    Firestore db = Firestore.instance;

    Map<String, dynamic> data = {
      "image" : url
    };

    db.collection("groups")
        .document(this.Id)
        .updateData( data );
  }

  //setters
  set Name(String value) {
    _Name = value;
  }

  set Image(File value) {
    _Image = value;
  }

  set Owner(String value) {
    _Owner = value;
  }

  set ImagePath(String value){
    _ImageURL = value;
  }

  //getters
  String get Name => _Name;
  File get Image => _ImageURL != null ? File( _ImageURL) : null ;
  String get ImagePath=> _ImageURL;
  String get Owner => _Owner;
  String get Id => _Id;

}