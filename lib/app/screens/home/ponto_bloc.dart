import 'dart:async';
import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/entrada_saida_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';
import 'package:ts_controle_ponto/app/shared/utils/time_of_day_utils.dart';

class PontoBloc extends BlocBase {
  final _repository = Repository();

  var rnd = Random();

  Map<DateTime, PontoModel> histPontos = Map();

  PontoModel pontoSelecionado = PontoModel.empty(DateTime.now());

  bool loading = false;

  BehaviorSubject<PontoModel> _pontoAtual;

  PontoBloc() {
    _pontoAtual = new BehaviorSubject<PontoModel>.seeded(this.pontoSelecionado);
  }

  Stream<PontoModel> get pontoStream => _pontoAtual.stream;

  void limparPonto() {
    pontoSelecionado = PontoModel.empty(DateTime.now());
    _pontoAtual.sink.add(pontoSelecionado);
  }

  void obterPonto(DateTime dataReferencia) {
    loading = true;

    dataReferencia =
        DateTime(dataReferencia.year, dataReferencia.month, dataReferencia.day);

    UsuarioModel usuarioAtual = AppModule.to.bloc<LoginBloc>().usuarioAtual;

    if (pontoSelecionado != null &&
        pontoSelecionado.dataReferencia.compareTo(dataReferencia) == 0) {
      loading = false;
    } else if (usuarioAtual != null) {
      var configuracaoAtual =
          AppModule.to.bloc<ConfiguracaoBloc>().configuracaoAtual;

      pontoSelecionado = PontoModel.empty(dataReferencia);
      pontoSelecionado.identUsuario = usuarioAtual.email;
      pontoSelecionado.duracaoJornada = configuracaoAtual.jornadaPadrao;
      pontoSelecionado.duracaoIntervalo = configuracaoAtual.intervalorPadrao;

      _pontoAtual.sink.add(pontoSelecionado);

      _repository
          .recuperarPonto(usuarioAtual.email, dataReferencia)
          .then((PontoModel ponto) {
        if (ponto != null) {
          pontoSelecionado = ponto;
          definirTempoTrabalhado();
        } else {
          pontoSelecionado = PontoModel.empty(dataReferencia);
          pontoSelecionado.identUsuario = usuarioAtual.email;
        }

        loading = false;
        pontoSelecionado.duracaoJornada = configuracaoAtual.jornadaPadrao;
        pontoSelecionado.duracaoIntervalo = configuracaoAtual.intervalorPadrao;
        _pontoAtual.sink.add(pontoSelecionado);
      });
    }
  }

  bool registrarMarcacao() {
    print('REGISTRANDO MARCAÇÃO');

    UsuarioModel usuarioAtual = AppModule.to.bloc<LoginBloc>().usuarioAtual;

    DateTime marcacao = DateTime.now();

    if (AppModule.to.bloc<AppBloc>().modoTeste) {
      if (pontoSelecionado.marcacoes.isNotEmpty) {
        marcacao = pontoSelecionado.marcacoes.last.marcacao;
      }
      marcacao = marcacao.add(Duration(minutes: rnd.nextInt(180) + 1));
    }

    MarcacaoPontoModel marcacaoPontoModel = MarcacaoPontoModel(
        pontoSelecionado.identUsuario, pontoSelecionado.ident, marcacao);

    if (!_validarMarcacao(marcacaoPontoModel)) {
      return false;
    }

    pontoSelecionado.marcacoes.add(marcacaoPontoModel);

    definirTempoTrabalhado();

    pontoSelecionado.identUsuario = usuarioAtual.email;
    marcacaoPontoModel.identUsuario = usuarioAtual.email;

    _repository.incluirPonto(pontoSelecionado);
    _repository.incluirMarcacao(marcacaoPontoModel);

    _pontoAtual.sink.add(pontoSelecionado);

    return true;
  }

  void definirTempoTrabalhado() {
    pontoSelecionado.horasTrabalhadas = DateTime(
        pontoSelecionado.dataReferencia.year,
        pontoSelecionado.dataReferencia.month,
        pontoSelecionado.dataReferencia.day);
    for (EntradaSaidaModel esm in pontoSelecionado.marcacoesAgrupadas) {
      pontoSelecionado.horasTrabalhadas = pontoSelecionado.horasTrabalhadas
          .add(Duration(minutes: esm.tempoTrabalhado));
    }

    Duration tempoTrabalho = Duration(
        hours: pontoSelecionado.horasTrabalhadas.hour,
        minutes: pontoSelecionado.horasTrabalhadas.minute);

    double percTotal = 100.0;
    double minTotalJornada =
        TimeOfDayUtils.duration(pontoSelecionado.duracaoJornada)
            .inMinutes
            .toDouble();
    double minTrabalhados = tempoTrabalho.inMinutes.toDouble();

    pontoSelecionado.percentualJornada =
        ((percTotal / minTotalJornada) * minTrabalhados).toInt();
  }

  @override
  void dispose() {
    _pontoAtual.close();
    super.dispose();
  }

  void removerMarcacao(MarcacaoPontoModel marcacao) {
    _repository.removerMarcacao(marcacao);
    pontoSelecionado.marcacoes.remove(marcacao);
    definirTempoTrabalhado();
    _pontoAtual.sink.add(pontoSelecionado);
  }

  void alterarMarcacao(MarcacaoPontoModel marcacao) {
    pontoSelecionado.marcacoes.remove(marcacao);
    _repository.alterarMarcacao(marcacao);
    pontoSelecionado.marcacoes.add(marcacao);
    definirTempoTrabalhado();

    _repository.incluirPonto(pontoSelecionado);
    _pontoAtual.sink.add(pontoSelecionado);
  }

  bool _validarMarcacao(MarcacaoPontoModel marcacao) {
    bool retorno = true;

    if (pontoSelecionado != null &&
        pontoSelecionado.marcacoes != null &&
        pontoSelecionado.marcacoes.indexWhere((m) =>
                (m.marcacao.hour == marcacao.marcacao.hour &&
                    m.marcacao.minute == marcacao.marcacao.minute)) >
            0) {
      retorno = false;
    }
    return retorno;
  }

  bool verificarSeExisteMarcacao(TimeOfDay horario) {
    bool retorno = false;

    if (pontoSelecionado != null &&
        pontoSelecionado.marcacoes != null &&
        pontoSelecionado.marcacoes.indexWhere((m) =>
                (m.marcacao.hour == horario.hour &&
                    m.marcacao.minute == horario.minute)) >=
            0) {
      retorno = true;
    }
    return retorno;
  }
}
