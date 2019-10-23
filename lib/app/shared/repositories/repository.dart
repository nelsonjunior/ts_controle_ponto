import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/firestore_provider.dart';

class Repository {
  final _firestoreProvider = FirestoreProvider();

  Future<void> incluirUsuario(UsuarioModel usuarioModel) =>
      _firestoreProvider.incluirUsuario(usuarioModel);

  Future<UsuarioModel> recuperarUsuario(String idUsuario) =>
      _firestoreProvider.recuperarUsuario(idUsuario);

  Future<PontoModel> incluirPonto(PontoModel ponto) =>
      _firestoreProvider.incluirPonto(ponto);

  Future<PontoModel> recuperarPonto(
          String idUsuario, DateTime dataReferencia) =>
      _firestoreProvider.recuperarPonto(idUsuario, dataReferencia);

  Future<MarcacaoPontoModel> incluirMarcacao(MarcacaoPontoModel marcacao) =>
      _firestoreProvider.incluirMarcacao(marcacao);

  Future<void> removerMarcacao(MarcacaoPontoModel marcacao) =>
      _firestoreProvider.removerMarcacao(marcacao);

  Future<void> alterarMarcacao(MarcacaoPontoModel marcacao) =>
      _firestoreProvider.alterarMarcacao(marcacao);

  Future<List<MarcacaoPontoModel>> recuperarMarcacoes(
          String identUsuario, String identPonto) =>
      _firestoreProvider.recuperarMarcacoes(identUsuario, identPonto);

  Future<void> salvarConfiguracao(ConfiguracaoModel configuracaoModel) =>
      _firestoreProvider.salvarConfiguracao(configuracaoModel);

  Future<ConfiguracaoModel> recuperarConfiguracao(String identUsuario) =>
      _firestoreProvider.recuperarConfiguracao(identUsuario);
}
