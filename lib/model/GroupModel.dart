import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Group{

  //Atributs
  String _Id = Uuid().v4();
  String _Name;
  String _Image;
  String _Owner;

  //Initialize
  Group();

  //Mapping for serialization
  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "id" : this.Id,
      "name" : this.Name,
      "image" : this.Image,
      "owner" : this.Owner
    };

    return map;
  }

  save() {
    Firestore db = Firestore.instance;
    db.collection("groups")
        .document( this.Id )
        .setData( this.toMap() );

    return;
  }


  //setters
  set Name(String value) {
    _Name = value;
  }

  set Image(String value) {
    _Image = value;
  }

  set Owner(String value) {
    _Owner = value;
  }

  //getters
  String get Name => _Name;
  String get Image => _Image;
  String get Owner => _Owner;
  String get Id => _Id;

}