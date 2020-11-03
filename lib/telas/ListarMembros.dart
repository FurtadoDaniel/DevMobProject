import 'package:flutter/material.dart';
import '../model/Conversa.dart';
import '../model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../model/GroupModel.dart';

class ListarMembros extends StatefulWidget {
  @override
  _ListarMembros createState() => _ListarMembros();
}

class _ListarMembros extends State<ListarMembros> {
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;
      
    QuerySnapshot querySnapshot =
        await db.collection("usuarios").getDocuments();

    List<Usuario> listaUsuarios = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;
      if (dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.documentID;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
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
        title: Text("Membros do Grupo X"),
      ),
      body: Container(
        child: Center(
          child: FutureBuilder<List<Usuario>>(
            future: _recuperarContatos(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: Column(
                      children: <Widget>[
                        Text("Carregando Membros"),
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

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                              ),
                              left: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: ListTile(
                            /*onTap: () {
                            Navigator.pushNamed(context, "/mensagens",
                                arguments: usuario);
                          },
                          */
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
        ),
      ),
    );
  }
}
