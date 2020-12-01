import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsuff/telas/AddGroupMember.dart';
import 'dart:io';

import '../model/GroupModel.dart';

class GroupForm extends StatefulWidget {
  @override
  _GroupForm createState() => _GroupForm();
}

class _GroupForm extends State<GroupForm> {
  _GroupForm() {
    _getCurrentUser();
    if (_imagePicker == null) _imagePicker = ImagePicker();
  }

  //Entity
  Group group = Group();

  //Controladores
  TextEditingController _OwnerController;
  TextEditingController _NameController =
      TextEditingController(text: "New group");
  File _imagem;

  //states
  bool _subindoImagem = false;
  static ImagePicker _imagePicker = null;

  _save() {
    group.Name = _NameController.text;
    group.Owner = _OwnerController.text;
    group.Image = _imagem;
    group.save();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddGroupMember(group)));
  }

  _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    this._OwnerController = TextEditingController(text: usuarioLogado.uid);
  }

  Future _recuperarImagem(String origemImagem) async {
    PickedFile imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            await _imagePicker.getImage(source: ImageSource.camera);
        break;
      case "galeria":
        imagemSelecionada =
            await _imagePicker.getImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = File(imagemSelecionada.path);
      if (_imagem != null) {
        _subindoImagem = true;
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Grupo"),
        ),
        body: Container(
          decoration: BoxDecoration(color: Color(0xff075E54)),
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey,
                      backgroundImage: this._imagem != null
                          ? FileImage(this._imagem)
                          : null),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        child: Text("Câmera"),
                        onPressed: () {
                          _recuperarImagem("camera");
                        },
                      ),
                      FlatButton(
                        child: Text("Galeria"),
                        onPressed: () {
                          _recuperarImagem("galeria");
                        },
                      )
                    ],
                  ),

                  //Field for Name
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _NameController,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                          hintText: "Nome",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32))),
                    ),
                  ),

                  //button save
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                        child: Text(
                          "Salvar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        color: Colors.green,
                        padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                        onPressed: () {
                          _save();
                        }),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
