import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../model/Conversa.dart';
import '../model/Mensagem.dart';
import '../model/Usuario.dart';
import '../model/GroupModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class GroupChat extends StatefulWidget {
  Group grupo;
  GroupChat(this.grupo);

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  //File _imagem;
  //bool _subindoImagem = false;
  String _idUsuarioLogado;
  String _idGrupo;
  String _urlImagemRemetente = "blz2"; // Remetente eh o logado
  String _nomeRemetente = "blz2";
  static ImagePicker _imagePicker = null;

  Firestore db = Firestore.instance;
  TextEditingController _controllerGroupChat = TextEditingController();

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _MensagensState() {
    if (_imagePicker == null) _imagePicker = ImagePicker();
  }

  _enviarMensagem() {
    String textoMensagem = _controllerGroupChat.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idGrupo = _idGrupo;
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.timeStamp = Timestamp.now(); //LEK
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      //Salvar mensagem para remetente
      _salvarMensagem(_idUsuarioLogado, _idGrupo, mensagem);

      //Salvar conversa
      //_salvarConversa(mensagem);
    }
  }

  _recuperarDadosRemetente() async {
    //Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("usuarios").document(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data;

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRemetente = dados["urlImagem"];
        print("recuperou " + _urlImagemRemetente);
      });
    }
    if (dados["nome"] != null) {
      setState(() {
        _nomeRemetente = dados["nome"];
        print("recuperou " + _nomeRemetente);
      });
    }
  }

  _salvarMensagem(String idRemetente, String idGrupo, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idGrupo)
        .add(msg.toGroupMap());

    //Limpa texto
    _controllerGroupChat.clear();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerGroupChat,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32))),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _enviarMensagem,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff075E54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot.documents.length,
                    itemBuilder: (context, indice) {
                      //recupera mensagem
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      //Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if (_idUsuarioLogado != item["idUsuario"]) {
                        alinhamento = Alignment.centerLeft;
                        cor = Colors.white;
                      }

                      return Align(
                        alignment: alinhamento,
                        child: Padding(
                          padding: EdgeInsets.all(6),
                          child: Container(
                            width: larguraContainer,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: cor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: item["tipo"] == "texto"
                                ? Text(
                                    item["mensagem"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }

            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.grupo.ImagePath != null
                    ? NetworkImage(widget.grupo.ImagePath)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.grupo.Name),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              stream,
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }
}
