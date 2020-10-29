import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Season.dart';
import '../model/GroupModel.dart';

class GroupForm extends StatefulWidget {
  @override
  _GroupForm createState() => _GroupForm();
}


class _GroupForm extends State<GroupForm> {

  _GroupForm(){
    _getCurrentUser();
  }

  //Controladores
  TextEditingController _OwnerController;
  TextEditingController _NameController = TextEditingController(text: "New group");

  _save(){

    Group group = Group();
    group.Name = _NameController.text;
    group.Owner = _OwnerController.text;
    group.save();

    Navigator.pushNamedAndRemoveUntil(
        context, "/home", (_)=>false
    );
  }

  _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    this._OwnerController = TextEditingController(text: usuarioLogado.uid);
  }

  Widget build(BuildContext context){
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
                  }
                ),
              ),


            ],
            ),
          ),
        ),
      )
    );
  }
}