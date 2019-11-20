import 'dart:convert';

import 'package:ts_controle_ponto/app/shared/contantes.dart';
import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/configuracao_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/firestore_provider.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';

final configuracaoDocument = "Configuracao";

class SincronizacaoConfiguracao with SincronizacaoBase<ConfiguracaoModel> {
  final _firestoreProvider = FirestoreProvider();
  final _configuracaoDao = ConfiguracaoDao();

  @override
  Future<void> carregar(String identUsuario) async {
    var configuracao =
        await _firestoreProvider.recuperarConfiguracao(identUsuario);
    await _configuracaoDao.incluir(configuracao);
    return Future.value();
  }

  @override
  String document() {
    return configuracaoDocument;
  }

  @override
  Future<void> sincronizar(SincronizacaoModel sincronizacaoModel) async {
    if (sincronizacaoModel.acao == AcaoSincronizacao.alterar.toString()) {
      var model = ConfiguracaoModel.fromMap(
          JsonDecoder().convert(sincronizacaoModel.data));

      await _firestoreProvider.salvarConfiguracao(model);
    }
    return Future.value();
  }

  @override
  SincronizacaoModel toSincronizacaoModel(
      ConfiguracaoModel model, AcaoSincronizacao acao) {
    SincronizacaoModel sinc = SincronizacaoModel(
        model.identUsuario,
        configuracaoDocument,
        JsonEncoder.withIndent(withIndent).convert(model.toMap()),
        acao.toString());
    return sinc;
  }
}
