import 'dart:convert';

import 'package:ts_controle_ponto/app/shared/contantes.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/firestore_provider.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';

final marcacaoDocument = "Marcacao";

class SincronizacaoMarcacao with SincronizacaoBase<MarcacaoPontoModel> {
  final _firestoreProvider = FirestoreProvider();

  @override
  SincronizacaoModel toSincronizacaoModel(
      MarcacaoPontoModel model, AcaoSincronizacao acao) {
    SincronizacaoModel sinc = SincronizacaoModel(
        model.ident,
        marcacaoDocument,
        JsonEncoder.withIndent(withIndent).convert(model.toMap()),
        acao.toString());
    return sinc;
  }

  @override
  Future<void> carregar(String identUsuario) {
    return Future.value();
  }

  @override
  Future<void> sincronizar(SincronizacaoModel sincronizacaoModel) async {
    print(sincronizacaoModel.data);
    var marcacao = MarcacaoPontoModel.fromMap(
        JsonDecoder().convert(sincronizacaoModel.data));
    if (sincronizacaoModel.acao == AcaoSincronizacao.incluir.toString()) {
      await _firestoreProvider.incluirMarcacao(marcacao);
    } else if (sincronizacaoModel.acao ==
        AcaoSincronizacao.alterar.toString()) {
      await _firestoreProvider.alterarMarcacao(marcacao);
    } else if (sincronizacaoModel.acao ==
        AcaoSincronizacao.remover.toString()) {
      await _firestoreProvider.removerMarcacao(marcacao);
    }
    return Future.value();
  }

  @override
  String document() {
    return marcacaoDocument;
  }
}
