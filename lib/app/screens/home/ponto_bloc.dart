import 'dart:async';
import 'dart:core';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:ts_controle_ponto/app/screens/home/components/dados_indicador_jornada.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/entrada_saida_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';
import 'package:ts_controle_ponto/app/shared/services/noticiacao_service.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_marcacao.dart';
import 'package:ts_controle_ponto/app/shared/sincronizacao/sincronizacao_ponto.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:ts_controle_ponto/app/shared/utils/list_utils.dart';
import 'package:ts_controle_ponto/app/shared/utils/time_of_day_utils.dart';

class PontoBloc extends BlocBase {
  // ####### Dependências injetadas #######
  final Repository _repository;
  final NotificacaoService _notificacaoService;
  final LoginBloc _loginBloc;
  final ConfiguracaoBloc _configBloc;

  final _sincronizarPonto = SincronizacaoPonto();
  final _sincronizarMarcacao = SincronizacaoMarcacao();

  Map<DateTime, PontoModel> histPontos = Map();

  PontoModel pontoSelecionado = PontoModel.empty(DateTime.now());

  bool loading = false;

  BehaviorSubject<PontoModel> _pontoAtual;

  BehaviorSubject<DadosIndicadorJornada> _dadosIndicadorJornada;

  PontoBloc(this._configBloc, this._loginBloc, this._notificacaoService,
      this._repository) {
    _pontoAtual = new BehaviorSubject<PontoModel>.seeded(this.pontoSelecionado);
    _dadosIndicadorJornada = new BehaviorSubject<DadosIndicadorJornada>.seeded(
        DadosIndicadorJornada.empty());
  }

  Stream<PontoModel> get pontoStream => _pontoAtual.stream;

  Stream<DadosIndicadorJornada> get dadosIndicadorStream =>
      _dadosIndicadorJornada.stream;

  void limparPonto() {
    pontoSelecionado = PontoModel.empty(DateTime.now());
    _definirTempoTrabalhado();
    _pontoAtual.sink.add(pontoSelecionado);
  }

  void obterPontoLogin() {
    print('Obter Ponto Login');
    pontoSelecionado = null;
    obterPonto(DateTime.now());
  }

  void obterPonto(DateTime dataReferencia) {
    loading = true;

    dataReferencia =
        DateTime(dataReferencia.year, dataReferencia.month, dataReferencia.day);

    if (pontoSelecionado != null &&
        pontoSelecionado.dataReferencia.compareTo(dataReferencia) == 0) {
      loading = false;
    } else if (_loginBloc.usuarioAtual != null) {
      print('Obter Ponto de $dataReferencia');

      _repository
          .recuperarPonto(_loginBloc.usuarioAtual.email, dataReferencia)
          .then((PontoModel ponto) {
        if (ponto != null) {
          pontoSelecionado = ponto;
        } else {
          pontoSelecionado = PontoModel.empty(dataReferencia);
          pontoSelecionado.identUsuario = _loginBloc.usuarioAtual.email;
        }
        _definirTempoTrabalhado();
        _pontoAtual.sink.add(pontoSelecionado);
        loading = false;
      });
    }
  }

  bool registrarMarcacao({DateTime marcacao}) {
    marcacao = marcacao ?? DateTime.now();

    MarcacaoPontoModel marcacaoPontoModel = MarcacaoPontoModel(
        pontoSelecionado.identUsuario, pontoSelecionado.ident, marcacao);

    if (!_validarMarcacao(marcacaoPontoModel)) {
      return false;
    }

    pontoSelecionado.marcacoes.add(marcacaoPontoModel);
    pontoSelecionado.marcacoes.sort((a, b) => DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            a.marcacao.hour,
            a.marcacao.minute)
        .compareTo(DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            b.marcacao.hour,
            b.marcacao.minute)));

    _definirTempoTrabalhado();

    pontoSelecionado.identUsuario = _loginBloc.usuarioAtual.email;
    marcacaoPontoModel.identUsuario = _loginBloc.usuarioAtual.email;

    _repository.incluirPonto(pontoSelecionado);
    _sincronizarPonto.incluir(pontoSelecionado);

    _repository.incluirMarcacao(marcacaoPontoModel).then((marcacao) {
      marcacaoPontoModel = marcacao;
      _sincronizarMarcacao.incluir(marcacaoPontoModel);
    });

    _pontoAtual.sink.add(pontoSelecionado);

    _adicionarNotificacao();

    return true;
  }

  void removerMarcacao(MarcacaoPontoModel marcacao) {
    _repository.removerMarcacao(marcacao);
    _sincronizarMarcacao.remover(marcacao);
    pontoSelecionado.marcacoes.remove(marcacao);
    pontoSelecionado.marcacoes.sort((a, b) => DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            a.marcacao.hour,
            a.marcacao.minute)
        .compareTo(DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            b.marcacao.hour,
            b.marcacao.minute)));
    _definirTempoTrabalhado();
    _sincronizarPonto.alterar(pontoSelecionado);
    _pontoAtual.sink.add(pontoSelecionado);
    _adicionarNotificacao();
  }

  void alterarMarcacao(MarcacaoPontoModel marcacao) {
    pontoSelecionado.marcacoes.remove(marcacao);
    _repository.alterarMarcacao(marcacao);
    _sincronizarMarcacao.alterar(marcacao);
    pontoSelecionado.marcacoes.add(marcacao);
    pontoSelecionado.marcacoes.sort((a, b) => DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            a.marcacao.hour,
            a.marcacao.minute)
        .compareTo(DateTime(
            pontoSelecionado.dataReferencia.year,
            pontoSelecionado.dataReferencia.month,
            pontoSelecionado.dataReferencia.day,
            b.marcacao.hour,
            b.marcacao.minute)));
    _definirTempoTrabalhado();

    _repository.incluirPonto(pontoSelecionado);
    _sincronizarPonto.alterar(pontoSelecionado);
    _pontoAtual.sink.add(pontoSelecionado);
    _adicionarNotificacao();
  }

  void _definirTempoTrabalhado() {
    pontoSelecionado.horasTrabalhadas = DateTime(
        pontoSelecionado.dataReferencia.year,
        pontoSelecionado.dataReferencia.month,
        pontoSelecionado.dataReferencia.day);
    for (EntradaSaidaModel esm in pontoSelecionado.marcacoesAgrupadas) {
      pontoSelecionado.horasTrabalhadas = pontoSelecionado.horasTrabalhadas
          .add(Duration(minutes: esm.tempoTrabalhado));
    }
    atualizarDadosIndicador();
  }

  void atualizarDadosIndicador() {
    Duration tempoTrabalho = Duration(
        hours: pontoSelecionado.horasTrabalhadas.hour,
        minutes: pontoSelecionado.horasTrabalhadas.minute);

    double percTotal = 100.0;
    double minTotalJornada =
        TimeOfDayUtils.duration(_configBloc.configuracaoAtual.jornadaPadrao)
            .inMinutes
            .toDouble();
    double minTrabalhados = tempoTrabalho.inMinutes.toDouble();

    var dadosIndicador = _dadosIndicadorJornada.value;

    dadosIndicador.percentualJornadaInicial = dadosIndicador.percentualJornada;

    dadosIndicador.percentualJornada =
        ((percTotal / minTotalJornada) * minTrabalhados);

    dadosIndicador.horasTrabalhadas = pontoSelecionado.horasTrabalhadas;

    _definirTextoIndicadorJornada(dadosIndicador);

    _dadosIndicadorJornada.sink.add(dadosIndicador);
  }

  void _definirTextoIndicadorJornada(DadosIndicadorJornada dadosIndicador) {
    var intervaloRealizado = _verificarSeIntervaloRealizado();
    var jornadaCompleta = _verificarSeJornadaCompleta();
    TimeOfDay jornadaPadrao = _configBloc.configuracaoAtual.jornadaPadrao;

    if (!isHoje(pontoSelecionado.dataReferencia)) {
      dadosIndicador.descIndicador1 =
          'Jornada ${formatarHora.format(TimeOfDayUtils.toDateTime(jornadaPadrao))}/dia';
      dadosIndicador.descIndicador2 =
          jornadaCompleta ? 'concluída' : 'em aberto';
    } else {
      if (intervaloRealizado) {
        if (jornadaCompleta) {
          dadosIndicador.descIndicador1 =
              'Jornada ${formatarHora.format(TimeOfDayUtils.toDateTime(jornadaPadrao))}/dia';
          dadosIndicador.descIndicador2 = 'concluída';
        } else {
          DateTime dtSaidaEstimada =
              _saidaEstimada(dadosIndicador, intervaloRealizado);

          dadosIndicador.descIndicador1 = 'Saída estimada';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtSaidaEstimada)}';
          dadosIndicador.dtHoraNotificacao = dtSaidaEstimada;
        }
      } else {
        DateTime dtRetornoIntervalo = _retornoEstimativaConclusaoIntervalo();
        if (dtRetornoIntervalo != null) {
          dadosIndicador.descIndicador1 = 'Retorno intervalo';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtRetornoIntervalo)}';
          dadosIndicador.dtHoraNotificacao = dtRetornoIntervalo;
        } else {
          DateTime dtSaidaEstimada =
              _saidaEstimada(dadosIndicador, intervaloRealizado);

          dadosIndicador.descIndicador1 = 'Saída estimada';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtSaidaEstimada)}';
          dadosIndicador.dtHoraNotificacao = dtSaidaEstimada;
        }
      }
    }
  }

  bool _verificarSeJornadaCompleta() {
    return Duration(
                hours: pontoSelecionado.horasTrabalhadas.hour,
                minutes: pontoSelecionado.horasTrabalhadas.minute)
            .compareTo(TimeOfDayUtils.duration(
                _configBloc.configuracaoAtual.jornadaPadrao)) >
        0;
  }

  DateTime _saidaEstimada(
      DadosIndicadorJornada dadosIndicador, bool intervaloRealizado) {
    DateTime estimativa = DateTime.now();
    if (pontoSelecionado.marcacoes != null &&
        pontoSelecionado.marcacoes.isNotEmpty) {
      estimativa = pontoSelecionado.marcacoes.last.marcacao;
    }
    DateTime hr = _calcularHorasRestantes(dadosIndicador, intervaloRealizado);
    return estimativa.add(Duration(hours: hr.hour, minutes: hr.minute));
  }

  DateTime _retornoEstimativaConclusaoIntervalo() {
    EntradaSaidaModel ultimaEntradaSaidaCompleta;

    for (EntradaSaidaModel entradaSaida
        in pontoSelecionado.marcacoesAgrupadas) {
      ultimaEntradaSaidaCompleta = null;
      if (entradaSaida.entrada != null && entradaSaida.saida != null) {
        ultimaEntradaSaidaCompleta = entradaSaida;
      }
    }

    if (ultimaEntradaSaidaCompleta != null) {
      Duration tempoIntervaloRealizado =
          DateTime.now().difference(ultimaEntradaSaidaCompleta.saida);

      TimeOfDay intervaloRestante = TimeOfDayUtils.subtract(
          _configBloc.configuracaoAtual.intervalorPadrao,
          tempoIntervaloRealizado);

      return DateTime.now().add(TimeOfDayUtils.duration(intervaloRestante));
    }
    return null;
  }

  DateTime _calcularHorasRestantes(
      DadosIndicadorJornada dadosIndicador, bool intervaloRealizado) {
    TimeOfDay jornadaPadrao = _configBloc.configuracaoAtual.jornadaPadrao;
    Duration intervalo = intervaloRealizado
        ? Duration(minutes: 0)
        : TimeOfDayUtils.duration(
            _configBloc.configuracaoAtual.intervalorPadrao);

    DateTime tempoRestante = DateTime(
            dadosIndicador.horasTrabalhadas.year,
            dadosIndicador.horasTrabalhadas.month,
            dadosIndicador.horasTrabalhadas.day,
            jornadaPadrao.hour,
            jornadaPadrao.minute)
        .add(intervalo)
        .subtract(Duration(
            hours: dadosIndicador.horasTrabalhadas.hour,
            minutes: dadosIndicador.horasTrabalhadas.minute));

    return tempoRestante;
  }

  bool _verificarSeIntervaloRealizado() {
    bool iRealizado = false;
    var chunk = ListUtils.chunk(pontoSelecionado.marcacoesAgrupadas, 2);
    for (List lista in chunk) {
      if (lista.length == 2) {
        EntradaSaidaModel es1 = lista[0];
        EntradaSaidaModel es2 = lista[1];

        Duration direfenca = es2.entrada.difference(es1.saida);

        if (direfenca.inMinutes >
            TimeOfDayUtils.duration(
                    _configBloc.configuracaoAtual.intervalorPadrao)
                .inMinutes) {
          iRealizado = true;
          break;
        }
      }
    }
    return iRealizado;
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

  bool verificarSeExisteMarcacao(DateTime horario) {
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

  bool verificarSeExisteMarcacaoTime(TimeOfDay horario) {
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

  @override
  void dispose() {
    _pontoAtual.close();
    _dadosIndicadorJornada.close();
    super.dispose();
  }

  void _adicionarNotificacao() {
    _notificacaoService.cancelarNotificacoes();
    var dadosIndicadorJornada = _dadosIndicadorJornada.value;

    if (dadosIndicadorJornada != null) {
      String textoNotificacao =
          dadosIndicadorJornada.descIndicador1.contains("intervalo")
              ? 'Seu intervalo termina em 5 minutos'
              : "Sua jornada termina em 5 minutos";
      _notificacaoService.agendarNotificacao(
          "Não esqueça de registrar o ponto.\n $textoNotificacao",
          dadosIndicadorJornada.dtHoraNotificacao);
    }
  }
}
