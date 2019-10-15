import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';

class AppBloc extends BlocBase {
  DateTime dataSelecionada = DateTime.now();

  bool modoTeste = false;

  BehaviorSubject<DateTime> _dataSelecionadaAtual;

  BehaviorSubject<bool> _modoTeste;

  AppBloc() {
    _dataSelecionadaAtual =
        new BehaviorSubject<DateTime>.seeded(this.dataSelecionada);
    _modoTeste = new BehaviorSubject<bool>.seeded(false);
  }

  Stream<DateTime> get dataStream => _dataSelecionadaAtual.stream;

  Stream<bool> get modoTesteSream => _modoTeste.stream;

  void alterarModoTeste() {
    modoTeste = !modoTeste;
    _modoTeste.sink.add(modoTeste);
  }

  void dataAnterior() {
    if (HomeModule.to.bloc<PontoBloc>().loading) {
      return;
    }
    dataSelecionada = dataSelecionada.subtract(Duration(days: 1));
    _dataSelecionadaAtual.sink.add(dataSelecionada);
  }

  void proximaData() {
    if (HomeModule.to.bloc<PontoBloc>().loading) {
      return;
    }
    dataSelecionada = dataSelecionada.add(Duration(days: 1));
    _dataSelecionadaAtual.sink.add(dataSelecionada);
  }

  @override
  void dispose() {
    _dataSelecionadaAtual.close();
    _modoTeste.close();
    super.dispose();
  }
}
