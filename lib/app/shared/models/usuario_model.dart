import 'package:google_sign_in/google_sign_in.dart';

class UsuarioModel {
  String id;
  String nome;
  String nomeCompleto;
  String email;
  String fotoURL;

  UsuarioModel.from(GoogleSignInAccount account) {
    this.id = account.id;
    this.nome =
        account.displayName.substring(0, account.displayName.indexOf(' '));
    this.nomeCompleto = account.displayName;
    this.email = account.email;
    this.fotoURL = account.photoUrl;
  }
}
