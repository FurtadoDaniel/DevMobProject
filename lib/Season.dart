import 'package:firebase_auth/firebase_auth.dart';

class Season {

  static getCurrentUser() {

  }

  _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    return (
      usuarioLogado.uid
    );
  }

}

