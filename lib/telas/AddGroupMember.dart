import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/GroupModel.dart';
import '../model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddGroupMember extends StatefulWidget {
  Group grupo;
  AddGroupMember(this.grupo);
  @override
  _AddGroupMemberState createState() => _AddGroupMemberState();
}

class _AddGroupMemberState extends State<AddGroupMember> {
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["email"] == _emailUsuarioLogado) {
        Usuario adm = Usuario();
        adm.idUsuario = item.documentID;
        adm.email = dados["email"];
        adm.nome = dados["nome"];
        adm.urlImagem = dados["urlImagem"];
        widget.grupo.Membros.add(adm);
        continue;
      }

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  _insereUsuarioGrupo(Usuario usuario) async {
    widget.grupo.Membros.add(usuario);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adicionar Membros"),
        elevation: Platform.isIOS ? 0 : 4,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                widget.grupo.save();
              },
              child: Icon(
                Icons.check,
                size: 26.0,
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Usuario>>(
        future: _recuperarContatos(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando contatos"),
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
                    List<Usuario> listaItens = snapshot.data;
                    Usuario usuario = listaItens[indice];
                    return Material(
                      child: ListTile(
                        onTap: () {
                          _insereUsuarioGrupo(usuario);
                        },
                        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                        leading: CircleAvatar(
                            maxRadius: 30,
                            backgroundColor: Colors.grey,
                            backgroundImage: usuario.urlImagem != null
                                ? NetworkImage(usuario.urlImagem)
                                : null),
                        title: Text(
                          usuario.nome == null ? "" : usuario.nome,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    );
                  });
              break;
          }
        },
      ),
    );
  }
}
