import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_provider.dart';

class SincronizacaoBloc extends BlocBase {
  final _sincronizacaoProvider = SincronizacaoProvider();

  BehaviorSubject<bool> _sincronizacaoEmAndamento;

  Stream<bool> get sincronizacaoStreem => _sincronizacaoEmAndamento.stream;

  SincronizacaoBloc() {
    _sincronizacaoEmAndamento = BehaviorSubject<bool>.seeded(true);

    _sincronizacaoProvider.sincronizarTodos().whenComplete(() {
      _sincronizacaoEmAndamento.sink.add(false);
    });

    // Future.delayed(Duration(seconds: 5)).then((_) {
    //   _sincronizacaoEmAndamento.sink.add(false);
    // });
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
