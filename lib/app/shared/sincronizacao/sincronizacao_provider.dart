import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/sincronizacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_base.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_configuracao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_marcacao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_ponto.dart';

class SincronizacaoProvider {
  Map<Type, SincronizacaoBase> endponts;

  final _sincronizacaoDao = SincronizacaoDao();

  SincronizacaoProvider() {
    endponts = new Map();
    endponts[PontoModel] = SincronizacaoPonto();
    endponts[MarcacaoPontoModel] = SincronizacaoMarcacao();
    endponts[ConfiguracaoModel] = SincronizacaoConfiguracao();
  }

  void carregar(String identUsuario) {
    endponts.values.forEach((SincronizacaoBase sb) async {
      print('Carredando dados $sb');
      await sb.carregar(identUsuario);
    });
  }

  void sincronizarTodos() {
    print('Sincronizando Dados');
    endponts.values.forEach((SincronizacaoBase sb) async {
      var pendentes = await _sincronizacaoDao.recuperarPendentes(sb.document());
      if (pendentes != null) {
        for (var sm in pendentes) {
          print('Sincronizando $sm');
          await sb.sincronizar(sm);
          print('Removendo $sm');
          await _sincronizacaoDao.remover(sm);
        }
      }
    });
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
