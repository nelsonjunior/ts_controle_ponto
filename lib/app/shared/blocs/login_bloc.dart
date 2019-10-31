import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/sincronizacao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/parametro_app_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';

class LoginBloc extends BlocBase {
  final _repository = Repository();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  UsuarioModel _usuarioModel;

  bool _iniciarTutorial = true;

  GoogleSignInAccount _googleAccount;

  UsuarioModel get usuarioAtual => _usuarioModel;

  GoogleSignInAccount get googleAccount => _googleAccount;

  bool get iniciarTutorial => _iniciarTutorial;

  BehaviorSubject<UsuarioModel> _usario;

  Stream<UsuarioModel> get usuarioStream => _usario.stream;

  LoginBloc() {
    _usario = BehaviorSubject<UsuarioModel>();
  }

  void verificarUsuarioLogado() async {
    print('verificarUsuarioLogado');

    ParametroAppModel paramUsuarioLogado =
        await _repository.recuperarParametro(USUARIO_LOGADO);

    if (paramUsuarioLogado != null) {
      _usuarioModel =
          await _repository.recuperarUsuario(paramUsuarioLogado.valorParametro);

      ParametroAppModel paramIniciarTutorial =
          await _repository.recuperarParametro(INICIAR_TUTORIAL);
      _iniciarTutorial =
          paramIniciarTutorial.valorParametro == "true" ? true : false;
      _usario.sink.add(_usuarioModel);
      AppModule.to.bloc<ConfiguracaoBloc>().recuperarConfiguracao();
      AppModule.to.bloc<SincronizacaoBloc>().iniciarSincronizacao();
      HomeModule.to.bloc<PontoBloc>().obterPontoLogin();
    } else {
      signInGoogleSilently();
    }
  }

  sigInGoogle() async {
    _googleSignIn.signIn().then((GoogleSignInAccount account) async {
      print('sigInGoogle $account');

      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _googleAccount = account;

        UsuarioModel usuario =
            await _repository.recuperarUsuario(account.email);
        
        _usario.sink.add(_usuarioModel);
        
        AppModule.to.bloc<ConfiguracaoBloc>().recuperarConfiguracao();

        if (usuario == null) {
          print('Inclusao usuario $_usuarioModel');

          _repository.incluirUsuario(_usuarioModel);
          _repository.incluirOuAlterarParametro(
              ParametroAppModel(USUARIO_LOGADO, _usuarioModel.email));

          ParametroAppModel paramIniciarTutorial =
              await _repository.recuperarParametro(INICIAR_TUTORIAL);
          if (paramIniciarTutorial == null) {
            _repository.incluirOuAlterarParametro(
                ParametroAppModel(INICIAR_TUTORIAL, true.toString()));
          }
          AppModule.to
              .bloc<SincronizacaoBloc>()
              .iniciarSincronizacaoInicial(_usuarioModel.email);
        } else {
          HomeModule.to.bloc<PontoBloc>().obterPontoLogin();
        }
      }
    });
  }

  signInGoogleSilently() async {
    _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
      print('signInGoogleSilently $account');

      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _usario.sink.add(_usuarioModel);
        _googleAccount = account;

        AppModule.to.bloc<ConfiguracaoBloc>().recuperarConfiguracao();
      }
    });
  }

  signOutGoogle() async {
    _googleSignIn.signOut().then((_) async {
      print('Realizando sign out google');
      if (_usuarioModel != null) {
        _repository.excluirUsuarioLogado(_usuarioModel.email);
      }
      _usuarioModel = null;
      _googleAccount = null;
      _usario.sink.add(_usuarioModel);

      HomeModule.to.bloc<PontoBloc>().limparPonto();
    });
  }

  void marcarTutorialConcluido() {
    _repository.incluirOuAlterarParametro(
        ParametroAppModel(INICIAR_TUTORIAL, false.toString()));
  }

  @override
  void dispose() {
    _usario.close();
    super.dispose();
  }
}
