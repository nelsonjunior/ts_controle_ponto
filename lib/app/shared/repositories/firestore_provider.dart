import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class FirestoreProvider {
  Firestore _firestore = Firestore.instance;

  Future<void> incluirUsuario(UsuarioModel usuario) async {
    return _firestore
        .collection("usuarios")
        .document(usuario.id)
        .setData(usuario.toMap());
  }

  Future<UsuarioModel> recuperarUsuario(String idUsuario) async {
    DocumentSnapshot document =
        await _firestore.collection("usuarios").document(idUsuario).get();
    if (document.data != null) {
      return new UsuarioModel.fromDocument(document);
    }
    return null;
  }

  Future<PontoModel> incluirPonto(PontoModel ponto) async {
    _firestore
        .collection("usuarios")
        .document(ponto.identUsuario)
        .collection("pontos")
        .document(formatarDataHash.format(ponto.dataReferencia))
        .setData(ponto.toMap());
    return ponto;
  }

  Future<PontoModel> recuperarPonto(
      String idUsuario, DateTime dataReferencia) async {
    DocumentSnapshot document = await _firestore
        .collection("usuarios")
        .document(idUsuario)
        .collection("pontos")
        .document(formatarDataHash.format(dataReferencia))
        .get();
    if (document.data != null) {
      return new PontoModel.fromDocument(document);
    }
    return null;
  }

  Future<MarcacaoPontoModel> incluirMarcacao(MarcacaoPontoModel marcacao) async {
    _firestore
        .collection("usuarios")
        .document(marcacao.identUsuario)
        .collection("pontos")
        .document(marcacao.identPonto)
        .collection("marcacoes")
        .document(formatarHora.format(marcacao.marcacao))
        .setData(marcacao.toMap());
    return marcacao;
  }

  Future<void> removerMarcacao(MarcacaoPontoModel marcacao) async {
    _firestore
        .collection("usuarios")
        .document(marcacao.identUsuario)
        .collection("pontos")
        .document(marcacao.identPonto)
        .collection("marcacoes")
        .document(formatarHora.format(marcacao.marcacao))
        .delete();
  }

  Future<List<MarcacaoPontoModel>> recuperarMarcacoes(String identUsuario, String identPonto) async {

    List<MarcacaoPontoModel> marcacoes = [];

    QuerySnapshot  snapshots = await _firestore
        .collection("usuarios")
        .document(identUsuario)
        .collection("pontos")
        .document(identPonto)
        .collection("marcacoes")
        .getDocuments();

    if(snapshots != null){
      marcacoes = snapshots.documents.map((doc) => MarcacaoPontoModel.fromDocument(doc)).toList();
    }   
    return marcacoes;
  }
}
