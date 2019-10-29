import 'dart:convert';

import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';

final marcacaoDocument = "Marcacao";

class SincronizacaoMarcacao with SincronizacaoBase<MarcacaoPontoModel> {
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
    return null;
  }

  @override
  Future<void> sincronizar(SincronizacaoModel sincronizacaoModel) {
    return null;
  }

  @override
  String document() {
    return marcacaoDocument;
  }
}
