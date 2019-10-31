import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/sincronizacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_configuracao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_ponto.dart';

class SincronizacaoProvider {
  Map<Type, SincronizacaoBase> endponts;

  final _sincronizacaoDao = SincronizacaoDao();

  SincronizacaoProvider() {
    endponts = new Map();
    endponts[PontoModel] = SincronizacaoPonto();
    // endponts[MarcacaoPontoModel] = SincronizacaoMarcacao();
    endponts[ConfiguracaoModel] = SincronizacaoConfiguracao();
  }

  void carregar(String identUsuario) {
    endponts.values.forEach((SincronizacaoBase sb) {
      print('Carredando dados $sb');
      sb.carregar(identUsuario);
    });
  }

  Future<void> sincronizarTodos() {
    print('Sincronizando Dados');
    endponts.values.forEach((SincronizacaoBase sb) async {
      var pendentes = await _sincronizacaoDao.recuperarPendentes(sb.document());
      if (pendentes != null) {
        for (var sm in pendentes) {
          print('Sincronizando $sm');
          sb.sincronizar(sm).then((onValue) {
            print('Removendo $sm');
            _sincronizacaoDao.remover(sm);
          });
        }
      }
    });
    return Future.value();
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
