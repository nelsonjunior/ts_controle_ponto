import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/sincronizacao_dao.dart';

final withIndent = "    ";

enum AcaoSincronizacao { incluir, alterar, remover }

abstract class SincronizacaoBase<T> {
  final _sincronizacaoDao = SincronizacaoDao();

  SincronizacaoModel toSincronizacaoModel(T model, AcaoSincronizacao acao);

  String document();

  Future<void> sincronizar(SincronizacaoModel sincronizacaoModel);

  Future<void> carregar(String identUsuario);

  Future<SincronizacaoModel> alterar(T model) {
    SincronizacaoModel sinc =
        toSincronizacaoModel(model, AcaoSincronizacao.alterar);
    print(sinc);
    return _sincronizacaoDao.incluir(sinc);
  }

  Future<SincronizacaoModel> incluir(T model) {
    SincronizacaoModel sinc =
        toSincronizacaoModel(model, AcaoSincronizacao.incluir);
    print(sinc);
    return _sincronizacaoDao.incluir(sinc);
  }

  Future<SincronizacaoModel> remover(T model) {
    SincronizacaoModel sinc =
        toSincronizacaoModel(model, AcaoSincronizacao.remover);
    print(sinc);
    return _sincronizacaoDao.incluir(sinc);
  }
}
