import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UsuarioModel {
  String nome;
  String nomeCompleto;
  String email;
  String fotoURL;

  UsuarioModel.from(GoogleSignInAccount account) {
    this.nome =
        account.displayName.substring(0, account.displayName.indexOf(' '));
    this.nomeCompleto = account.displayName;
    this.email = account.email;
    this.fotoURL = account.photoUrl;
  }

  UsuarioModel.fromDocument(DocumentSnapshot doc) {
    this.nome = doc.data['nome'];
    this.nomeCompleto = doc.data['nomeCompleto'];
    this.email = doc.data['email'];
    this.fotoURL = doc.data['fotoURL'];
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': this.nome,
      'nomeCompleto': this.nomeCompleto,
      'email': this.email,
      'fotoURL': this.fotoURL,
    };
  }

  @override
  String toString() {
    return 'Nome $nome Email $email';
  }
}
