import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';
import 'package:ts_controle_ponto/app/shared/utils/time_of_day_utils.dart';

class ConfiguracaoBloc extends BlocBase {
  final _repository = Repository();

  static const Duration intervalorPadrao = Duration(minutes: 15);

  ConfiguracaoModel _configuracaoAtual;

  BehaviorSubject<ConfiguracaoModel> _dataConfiguracaoJornada;

  ConfiguracaoBloc() {
    _configuracaoAtual = ConfiguracaoModel.empty();

    _dataConfiguracaoJornada = new BehaviorSubject.seeded(_configuracaoAtual);

    var usuarioAtual = AppModule.to.bloc<LoginBloc>().usuarioAtual;

    if (usuarioAtual != null) {
      _repository
          .recuperarConfiguracao(usuarioAtual.email)
          .then((ConfiguracaoModel configuracao) {
        _configuracaoAtual = configuracao;
        _dataConfiguracaoJornada.sink.add(_configuracaoAtual);
      });
    }
  }

  ConfiguracaoModel get configuracaoAtual => _configuracaoAtual;

  Stream<ConfiguracaoModel> get configuracaoStream =>
      _dataConfiguracaoJornada.stream;

  Stream<TimeOfDay> get jornadaPadraoStream =>
      _dataConfiguracaoJornada.stream.map((config) => config.jornadaPadrao);

  Stream<TimeOfDay> get intervaloPadraoStream =>
      _dataConfiguracaoJornada.stream.map((config) => config.intervalorPadrao);

  void aumentarJornadaPadrao() {
    var configuracaoModel = _dataConfiguracaoJornada.value;

    if (configuracaoModel.jornadaPadrao.hour == 23 &&
        configuracaoModel.jornadaPadrao.minute == 45) {
      return;
    }

    configuracaoModel.jornadaPadrao =
        TimeOfDayUtils.add(configuracaoModel.jornadaPadrao, intervalorPadrao);

    _dataConfiguracaoJornada.sink.add(configuracaoModel);
  }

  void diminuirJornadaPadrao() {
    var configuracaoModel = _dataConfiguracaoJornada.value;

    if (configuracaoModel.jornadaPadrao.hour == 0 &&
        configuracaoModel.jornadaPadrao.minute == 15) {
      return;
    }

    configuracaoModel.jornadaPadrao = TimeOfDayUtils.subtract(
        configuracaoModel.jornadaPadrao, intervalorPadrao);

    _dataConfiguracaoJornada.sink.add(configuracaoModel);
  }

  void aumentarIntervaloPadrao() {
    var configuracaoModel = _dataConfiguracaoJornada.value;

    if (configuracaoModel.intervalorPadrao.hour == 23 &&
        configuracaoModel.intervalorPadrao.minute == 45) {
      return;
    }

    configuracaoModel.intervalorPadrao = TimeOfDayUtils.add(
        configuracaoModel.intervalorPadrao, intervalorPadrao);

    _dataConfiguracaoJornada.sink.add(configuracaoModel);
  }

  void diminuirIntervaloPadrao() {
    var configuracaoModel = _dataConfiguracaoJornada.value;

    if (configuracaoModel.intervalorPadrao.hour == 0 &&
        configuracaoModel.intervalorPadrao.minute == 15) {
      return;
    }

    configuracaoModel.intervalorPadrao = TimeOfDayUtils.subtract(
        configuracaoModel.intervalorPadrao, intervalorPadrao);

    _dataConfiguracaoJornada.sink.add(configuracaoModel);
  }

  void salvarConfiguracao() {
    var configuracaoModel = _dataConfiguracaoJornada.value;
    configuracaoModel.identUsuario =
        AppModule.to.bloc<LoginBloc>().usuarioAtual.email;

    _repository.salvarConfiguracao(configuracaoModel).then((data) {
      _configuracaoAtual = configuracaoModel;
    });
  }

  void recuperarConfiguracao() async {
    var usuarioAtual = AppModule.to.bloc<LoginBloc>().usuarioAtual;

    if (usuarioAtual != null) {
      _configuracaoAtual =
          await _repository.recuperarConfiguracao(usuarioAtual.email);
      _dataConfiguracaoJornada.sink.add(_configuracaoAtual);
    }
  }

  @override
  void dispose() {
    _dataConfiguracaoJornada.close();
    super.dispose();
  }
}
