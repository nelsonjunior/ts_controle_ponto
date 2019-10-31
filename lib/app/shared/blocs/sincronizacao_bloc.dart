import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_provider.dart';

class SincronizacaoBloc extends BlocBase {
  final _sincronizacaoProvider = SincronizacaoProvider();

  BehaviorSubject<bool> _sincronizacaoEmAndamento;

  Stream<bool> get sincronizacaoStreem => _sincronizacaoEmAndamento.stream;

  SincronizacaoBloc() {
    _sincronizacaoEmAndamento = BehaviorSubject<bool>.seeded(false);
  }

  void iniciarSincronizacao() {
    _sincronizacaoEmAndamento.sink.add(true);
    _sincronizacaoProvider.sincronizarTodos().whenComplete(() {
      _sincronizacaoEmAndamento.sink.add(false);
    });
  }

  void iniciarSincronizacaoInicial(String identUsuario) {
    _sincronizacaoEmAndamento.sink.add(true);
    _sincronizacaoProvider.carregar(identUsuario);
    HomeModule.to.bloc<PontoBloc>().loading = true;
    Future.delayed(Duration(seconds: 2)).then((_) {
      _sincronizacaoEmAndamento.sink.add(false);
      print('Sincronizacao Inicial Concluida!!!');
      HomeModule.to.bloc<PontoBloc>().obterPontoLogin();
    });
  }

  void alternarSincronizacao() {
    _sincronizacaoEmAndamento.sink.add(!_sincronizacaoEmAndamento.value);
  }

  @override
  void dispose() {
    _sincronizacaoEmAndamento.close();
    super.dispose();
  }
}
