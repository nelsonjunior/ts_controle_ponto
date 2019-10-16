import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';

class LoginBloc extends BlocBase {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  UsuarioModel _usuarioModel;

  UsuarioModel get usuarioAtual => _usuarioModel;

  final _repository = Repository();

  // StreamController
  final BehaviorSubject<GoogleSignInAccount> _google =
      BehaviorSubject<GoogleSignInAccount>();

  final BehaviorSubject<UsuarioModel> _usario = BehaviorSubject<UsuarioModel>();

  // Streams
  Stream<GoogleSignInAccount> get googleAccount => _google.stream;

  Stream<UsuarioModel> get usuarioStream => _usario.stream;

  sigInGoogle() async {
    _googleSignIn.signIn().then((GoogleSignInAccount account) async {
      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _usario.sink.add(_usuarioModel);
        _google.sink.add(account);

        UsuarioModel usuario =
            await _repository.recuperarUsuario(account.email);

        HomeModule.to.bloc<PontoBloc>().obterPonto(DateTime.now());

        if (usuario == null) {
          _repository.incluirUsuario(_usuarioModel);
        }
      }
    });
  }

  signInGoogleSilently() async {
    _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
      if (account != null) {
        _usuarioModel = UsuarioModel.from(account);
        _usario.sink.add(_usuarioModel);
        _google.sink.add(account);

        HomeModule.to.bloc<PontoBloc>().obterPonto(DateTime.now());
      }
    });
  }

  signOutGoogle() async {
    _googleSignIn.signOut().then(_google.sink.add).then((_) {
      _usuarioModel = null;
      _usario.sink.add(_usuarioModel);
      HomeModule.to.bloc<PontoBloc>().limparPonto();
    });
  }

  @override
  void dispose() {
    _google.close();
    _usario.close();
    super.dispose();
  }
}
