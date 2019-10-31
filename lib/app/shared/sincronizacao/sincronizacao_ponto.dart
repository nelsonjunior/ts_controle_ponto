import 'dart:convert';

import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/firestore_provider.dart';
import 'package:ts_controle_ponto/app/shared/repositories/marcacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/ponto_dao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';

final pontoDocument = "Ponto";

class SincronizacaoPonto with SincronizacaoBase<PontoModel> {
  final _firestoreProvider = FirestoreProvider();
  final _pontoDao = PontoDao();
  final _marcacaoDao = MarcacaoDao();

  @override
  SincronizacaoModel toSincronizacaoModel(
      PontoModel pontoModel, AcaoSincronizacao acao) {
    SincronizacaoModel sinc = SincronizacaoModel(
        pontoModel.ident,
        pontoDocument,
        JsonEncoder.withIndent(withIndent).convert(pontoModel.toMap()),
        acao.toString());
    return sinc;
  }

  @override
  void carregar(String identUsuario) async {
    print('carregando dados ponto $identUsuario');
    var pontos = await _firestoreProvider.recuperarPontos(identUsuario);
    if (pontos.isNotEmpty) {
      pontos.forEach((ponto) async {
        print('carregando ponto $ponto');
        await _pontoDao.incluirPonto(ponto);
        var marcacoes = await _firestoreProvider.recuperarMarcacoes(
            identUsuario, ponto.ident);
        marcacoes.forEach((m) async {
          print('carregando marcacao $m');
          await _marcacaoDao.incluirMarcacao(m);
        });
      });
    }
  }

  @override
  Future<void> sincronizar(SincronizacaoModel sincronizacaoModel) {
    if (sincronizacaoModel.acao == AcaoSincronizacao.incluir.toString() ||
        sincronizacaoModel.acao == AcaoSincronizacao.alterar.toString()) {
      var pontoModel =
          PontoModel.fromMap(JsonDecoder().convert(sincronizacaoModel.data));

      _firestoreProvider.incluirPonto(pontoModel);
    }
    return Future.value();
  }

  @override
  String document() {
    return pontoDocument;
  }
}
