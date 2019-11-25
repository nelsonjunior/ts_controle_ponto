import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/parametro_app_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';

class AppBloc extends BlocBase {
  final Repository _repository;

  DateTime dataSelecionada = DateTime.now();

  BehaviorSubject<DateTime> _dataSelecionadaAtual;

  AppBloc(this._repository) {
    _dataSelecionadaAtual =
        new BehaviorSubject<DateTime>.seeded(this.dataSelecionada);
  }

  Stream<DateTime> get dataStream => _dataSelecionadaAtual.stream;

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

  void irParaDataAtual() {
    if (HomeModule.to.bloc<PontoBloc>().loading) {
      return;
    }
    dataSelecionada = DateTime.now();
    _dataSelecionadaAtual.sink.add(dataSelecionada);
  }

  Future<bool> exibirTutorial(String identTutorial) async {
    ParametroAppModel param =
        await _repository.recuperarParametro(identTutorial);
    await _repository.incluirOuAlterarParametro(
        ParametroAppModel(identTutorial, false.toString()));
    return (param == null || param.valorParametro == 'true') ? true : false;
  }

  void definirPularTutorial(String identTutorial) async {
    _repository.incluirOuAlterarParametro(
        ParametroAppModel(identTutorial, true.toString()));
  }

  @override
  void dispose() {
    _dataSelecionadaAtual.close();
    super.dispose();
  }
}
