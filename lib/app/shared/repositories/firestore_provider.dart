import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class FirestoreProvider {
  Firestore _firestore = Firestore.instance;

  Future<void> incluirUsuario(UsuarioModel usuario) async {
    return _firestore
        .collection("usuarios")
        .document(usuario.email)
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
      PontoModel pontoModel = new PontoModel.fromDocument(document);

      pontoModel.marcacoes =
          await recuperarMarcacoes(idUsuario, pontoModel.ident);

      return pontoModel;
    }
    return null;
  }

  Future<List<PontoModel>> recuperarPontos(String idUsuario) async {
    List<PontoModel> pontos = [];

    QuerySnapshot snapshots = await _firestore
        .collection("usuarios")
        .document(idUsuario)
        .collection("pontos")
        .getDocuments();

    if (snapshots != null) {
      pontos = snapshots.documents
          .map((doc) => PontoModel.fromDocument(doc))
          .toList();
    }
    return pontos;
  }

  Future<MarcacaoPontoModel> incluirMarcacao(
      MarcacaoPontoModel marcacao) async {
    _firestore
        .collection("usuarios")
        .document(marcacao.identUsuario)
        .collection("pontos")
        .document(marcacao.identPonto)
        .collection("marcacoes")
        .add(marcacao.toMap())
        .then((DocumentReference doc) {
      marcacao.ident = doc.documentID;
    });
    return marcacao;
  }

  Future<void> removerMarcacao(MarcacaoPontoModel marcacao) async {
    _firestore
        .collection("usuarios")
        .document(marcacao.identUsuario)
        .collection("pontos")
        .document(marcacao.identPonto)
        .collection("marcacoes")
        .document(marcacao.ident)
        .delete();
  }

  Future<void> alterarMarcacao(MarcacaoPontoModel marcacao) async {
    _firestore
        .collection("usuarios")
        .document(marcacao.identUsuario)
        .collection("pontos")
        .document(marcacao.identPonto)
        .collection("marcacoes")
        .document(marcacao.ident)
        .setData(marcacao.toMap());
  }

  Future<List<MarcacaoPontoModel>> recuperarMarcacoes(
      String identUsuario, String identPonto) async {
    List<MarcacaoPontoModel> marcacoes = [];

    QuerySnapshot snapshots = await _firestore
        .collection("usuarios")
        .document(identUsuario)
        .collection("pontos")
        .document(identPonto)
        .collection("marcacoes")
        .getDocuments();

    if (snapshots != null) {
      marcacoes = snapshots.documents
          .map((doc) => MarcacaoPontoModel.fromDocument(doc))
          .toList();
    }
    return marcacoes;
  }

  Future<void> salvarConfiguracao(ConfiguracaoModel configuracaoModel) {
    return _firestore
        .collection("configuracoes")
        .document(configuracaoModel.identUsuario)
        .setData(configuracaoModel.toMap());
  }

  Future<ConfiguracaoModel> recuperarConfiguracao(String idUsuario) async {
    DocumentSnapshot doc =
        await _firestore.collection("configuracoes").document(idUsuario).get();

    return ConfiguracaoModel.fromDocument(doc);
  }
}
