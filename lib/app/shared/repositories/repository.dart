import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/parametro_app_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/marcacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/parametro_app_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/ponto_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/sincronizacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/repositories/usuario_dao.dart';

import 'configuracao_dao.dart';

class Repository {
  // final _firestoreProvider = FirestoreProvider();

  final _usuarioDao = UsuarioDao();

  final _pontoDao = PontoDao();

  final _marcacaoDao = MarcacaoDao();

  final _configuracaoDao = ConfiguracaoDao();

  final _parametroAppDao = ParametroAppDao();

  final _sincronizacaoDao = SincronizacaoDao();

  Future<void> incluirUsuario(UsuarioModel usuarioModel) =>
      _usuarioDao.incluirUsuario(usuarioModel);

  Future<UsuarioModel> recuperarUsuario(String idUsuario) =>
      _usuarioDao.recuperarUsuario(idUsuario);

  Future<PontoModel> incluirPonto(PontoModel ponto) =>
      _pontoDao.incluirPonto(ponto);

  Future<PontoModel> recuperarPonto(
          String idUsuario, DateTime dataReferencia) =>
      _pontoDao.recuperarPontoPorData(idUsuario, dataReferencia);

  Future<MarcacaoPontoModel> incluirMarcacao(MarcacaoPontoModel marcacao) =>
      _marcacaoDao.incluirMarcacao(marcacao);

  Future<void> removerMarcacao(MarcacaoPontoModel marcacao) =>
      _marcacaoDao.removerMarcacao(marcacao);

  Future<void> alterarMarcacao(MarcacaoPontoModel marcacao) =>
      _marcacaoDao.alterarMarcacao(marcacao);

  Future<List<MarcacaoPontoModel>> recuperarMarcacoes(
          String identUsuario, String identPonto) =>
      _marcacaoDao.recuperarMarcacoes(identUsuario, identPonto);

  Future<void> salvarConfiguracao(ConfiguracaoModel configuracaoModel) =>
      _configuracaoDao.incluir(configuracaoModel);

  Future<ConfiguracaoModel> recuperarConfiguracao(String identUsuario) =>
      _configuracaoDao.recuperar(identUsuario);

  Future<ParametroAppModel> incluirOuAlterarParametro(
          ParametroAppModel model) =>
      _parametroAppDao.incluirOuAlterar(model);

  Future<ParametroAppModel> recuperarParametro(String identParametro) =>
      _parametroAppDao.recuperar(identParametro);

  Future<int> removerParametro(String identParametro) =>
      _parametroAppDao.remover(identParametro);

  Future<void> excluirUsuarioLogado(String identUsuario) async {
    print('Excluindo informacoes do usuario $identUsuario');

    removerParametro(USUARIO_LOGADO);
    removerParametro(INICIAR_TUTORIAL);
    _usuarioDao.removerUsuario(identUsuario);
    _pontoDao.removerPontosPorUsuario(identUsuario);
    _marcacaoDao.removerMarcacoesPorUsuario(identUsuario);
    _configuracaoDao.removerPorUsuario(identUsuario);
    _sincronizacaoDao.removerTodos();
    return Future.value();
  }
}
