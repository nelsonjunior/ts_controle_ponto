import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/parametro_app_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_provider.dart';

class LoginBloc extends BlocBase {
  final _repository = Repository();

  final _sincronizacao = SincronizacaoProvider();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  UsuarioModel _usuarioModel;

  GoogleSignInAccount _googleAccount;

  UsuarioModel get usuarioAtual => _usuarioModel;

  GoogleSignInAccount get googleAccount => _googleAccount;

  BehaviorSubject<UsuarioModel> _usario;

  Stream<UsuarioModel> get usuarioStream => _usario.stream;

  LoginBloc() {
    _usario = BehaviorSubject<UsuarioModel>();

    _repository
        .recuperarParametro(USUARIO_LOGADO)
        .then((ParametroAppModel param) {
      if (param != null) {
        _repository
            .recuperarUsuario(param.valorParametro)
            .then((UsuarioModel usuario) {
          _usuarioModel = usuario;
          _usario.sink.add(_usuarioModel);
          HomeModule.to.bloc<PontoBloc>().obterPonto(DateTime.now());
        });
      } else {
        signInGoogleSilently();
      }
    });
  }

  sigInGoogle() async {
    _googleSignIn.signIn().then((GoogleSignInAccount account) async {
      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _usario.sink.add(_usuarioModel);
        _googleAccount = account;

        UsuarioModel usuario =
            await _repository.recuperarUsuario(account.email);

        if (usuario == null) {
          _repository.incluirUsuario(_usuarioModel);
          _repository.incluirOuAlterarParametro(
              ParametroAppModel(USUARIO_LOGADO, _usuarioModel.email));

          _sincronizacao.carregar(_usuarioModel.email);
        } else {
          _sincronizacao.sincronizarTodos();
        }
        HomeModule.to.bloc<PontoBloc>().obterPonto(DateTime.now());
        AppModule.to.bloc<ConfiguracaoBloc>().recuperarConfiguracao();
      }
    });
  }

  signInGoogleSilently() async {
    _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _usario.sink.add(_usuarioModel);
        _googleAccount = account;

        _repository.incluirOuAlterarParametro(
            ParametroAppModel(USUARIO_LOGADO, _usuarioModel.email));
        
        AppModule.to.bloc<ConfiguracaoBloc>().recuperarConfiguracao();
      }
    });
  }

  signOutGoogle() async {
    _googleSignIn.signOut().then((_) async {
      _usuarioModel = null;
      _googleAccount = null;
      _usario.sink.add(_usuarioModel);

      HomeModule.to.bloc<PontoBloc>().limparPonto();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('monstrarTutorial', false);

      _repository.removerParametro(USUARIO_LOGADO);
    });
  }

  @override
  void dispose() {
    _usario.close();
    super.dispose();
  }
}
