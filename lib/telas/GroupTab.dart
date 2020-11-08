import 'dart:async';
import 'package:flutter/material.dart';
import 'package:whatsuff/telas/GroupChat.dart';
import 'package:whatsuff/telas/GroupForm.dart';
import '../model/GroupModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class GroupTab extends StatefulWidget {
  @override
  _GroupTab createState() => _GroupTab();
}

class _GroupTab extends State<GroupTab> {
  TextEditingController _OwnerController;

  _GroupTab() {
    _getCurrentUser();
  }

  Future<List<Group>> _getGroups() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot = await db.collection("groups").getDocuments();

    List<Group> groups = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;
      if (data["owner"] != this._OwnerController.text) continue;

      Group group = Group.IfId(data["id"]);
      group.ImagePath = data["image"] != null ? data["image"] : "";
      group.Name = data["name"];

      groups.add(group);
    }

    return groups;
  }

  _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    this._OwnerController = TextEditingController(text: usuarioLogado.uid);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _getGroups(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando grupos"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, indice) {
                  List<Group> listaItens = snapshot.data;
                  Group grupo = listaItens[indice];

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupChat(grupo)),
                      );
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: grupo.Image != null
                            ? NetworkImage(grupo.ImagePath)
                            : null),
                    title: Text(
                      grupo.Name == null ? "" : grupo.Name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                });
            break;
        }
      },
    );
  }
}
