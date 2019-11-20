import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
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
  final _repository = Repository();
  final _sincronizarPonto = SincronizacaoPonto();
  final _sincronizarMarcacao = SincronizacaoMarcacao();
  final NotificacaoService _notificacaoService;

  var rnd = Random();

  Map<DateTime, PontoModel> histPontos = Map();

  PontoModel pontoSelecionado = PontoModel.empty(DateTime.now());

  LoginBloc loginBloc;
  ConfiguracaoBloc configBloc;

  bool loading = false;

  BehaviorSubject<PontoModel> _pontoAtual;

  BehaviorSubject<DadosIndicadorJornada> _dadosIndicadorJornada;

  PontoBloc(this._notificacaoService) {
    _pontoAtual = new BehaviorSubject<PontoModel>.seeded(this.pontoSelecionado);
    _dadosIndicadorJornada = new BehaviorSubject<DadosIndicadorJornada>.seeded(
        DadosIndicadorJornada.empty());

    loginBloc = AppModule.to.bloc<LoginBloc>();
    configBloc = AppModule.to.bloc<ConfiguracaoBloc>();
  }

  Stream<PontoModel> get pontoStream => _pontoAtual.stream;

  Stream<DadosIndicadorJornada> get dadosIndicadorStream =>
      _dadosIndicadorJornada.stream;

  void limparPonto() {
    pontoSelecionado = PontoModel.empty(DateTime.now());
    definirTempoTrabalhado();
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
    } else if (loginBloc.usuarioAtual != null) {
      print('Obter Ponto de $dataReferencia');

      _repository
          .recuperarPonto(loginBloc.usuarioAtual.email, dataReferencia)
          .then((PontoModel ponto) {
        if (ponto != null) {
          pontoSelecionado = ponto;
        } else {
          pontoSelecionado = PontoModel.empty(dataReferencia);
          pontoSelecionado.identUsuario = loginBloc.usuarioAtual.email;
        }
        definirTempoTrabalhado();
        _pontoAtual.sink.add(pontoSelecionado);
        loading = false;
      });
    }
  }

  bool registrarMarcacao({DateTime marcacao}) {
    marcacao = marcacao ?? DateTime.now();

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

    definirTempoTrabalhado();

    pontoSelecionado.identUsuario = loginBloc.usuarioAtual.email;
    marcacaoPontoModel.identUsuario = loginBloc.usuarioAtual.email;

    _repository.incluirPonto(pontoSelecionado);
    _sincronizarPonto.incluir(pontoSelecionado);

    _repository.incluirMarcacao(marcacaoPontoModel).then((marcacao) {
      marcacaoPontoModel = marcacao;
      _sincronizarMarcacao.incluir(marcacaoPontoModel);
    });

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
    atualizarDadosIndicador();
  }

  void atualizarDadosIndicador() {
    Duration tempoTrabalho = Duration(
        hours: pontoSelecionado.horasTrabalhadas.hour,
        minutes: pontoSelecionado.horasTrabalhadas.minute);

    double percTotal = 100.0;
    double minTotalJornada =
        TimeOfDayUtils.duration(configBloc.configuracaoAtual.jornadaPadrao)
            .inMinutes
            .toDouble();
    double minTrabalhados = tempoTrabalho.inMinutes.toDouble();

    var dadosIndicador = _dadosIndicadorJornada.value;

    dadosIndicador.percentualJornadaInicial = dadosIndicador.percentualJornada;

    dadosIndicador.percentualJornada =
        ((percTotal / minTotalJornada) * minTrabalhados);

    dadosIndicador.horasTrabalhadas = pontoSelecionado.horasTrabalhadas;

    definirTextoIndicadorJornada(dadosIndicador);

    _dadosIndicadorJornada.sink.add(dadosIndicador);
  }

  void definirTextoIndicadorJornada(DadosIndicadorJornada dadosIndicador) {
    var intervaloRealizado = verificarSeIntervaloRealizado();
    var jornadaCompleta = verificarSeJornadaCompleta();

    if (!isHoje(pontoSelecionado.dataReferencia)) {
      TimeOfDay jornadaPadrao = configBloc.configuracaoAtual.jornadaPadrao;
      dadosIndicador.descIndicador1 =
          'Jornada ${formatarHora.format(TimeOfDayUtils.toDateTime(jornadaPadrao))}/dia';
      dadosIndicador.descIndicador2 =
          jornadaCompleta ? 'concluída' : 'em aberto';
    } else {
      _notificacaoService.cancelarNotificacoes();

      if (intervaloRealizado) {
        if (jornadaCompleta) {
          TimeOfDay jornadaPadrao = configBloc.configuracaoAtual.jornadaPadrao;
          dadosIndicador.descIndicador1 =
              'Jornada ${formatarHora.format(TimeOfDayUtils.toDateTime(jornadaPadrao))}/dia';
          dadosIndicador.descIndicador2 = 'concluída';
        } else {
          DateTime dtSaidaEstimada =
              saidaEstimada(dadosIndicador, intervaloRealizado);

          dadosIndicador.descIndicador1 = 'Saída estimada';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtSaidaEstimada)}';

          _notificacaoService.agendarNotificacao(
              "Não esqueça de registrar o ponto.\nSua jornada termina em 5 minutos",
              dtSaidaEstimada);
        }
      } else {
        DateTime dtRetornoIntervalo = retornoEstimativaConclusaoIntervalo();
        if (dtRetornoIntervalo != null) {
          dadosIndicador.descIndicador1 = 'Retorno intervalo';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtRetornoIntervalo)}';

          _notificacaoService.agendarNotificacao(
              "Não esqueça de registrar o ponto.\nSeu intervalo termina em 5 minutos",
              dtRetornoIntervalo.subtract(Duration(minutes: 5)));
        } else {
          DateTime dtSaidaEstimada =
              saidaEstimada(dadosIndicador, intervaloRealizado);

          dadosIndicador.descIndicador1 = 'Saída estimada';
          dadosIndicador.descIndicador2 =
              'às ${formatarHora.format(dtSaidaEstimada)}';

          _notificacaoService.agendarNotificacao(
              "Não esqueça de registrar o ponto.\nSua jornada termina em 5 minutos",
              dtSaidaEstimada.subtract(Duration(minutes: 5)));
        }
      }
    }
  }

  bool verificarSeJornadaCompleta() {
    return Duration(
                hours: pontoSelecionado.horasTrabalhadas.hour,
                minutes: pontoSelecionado.horasTrabalhadas.minute)
            .compareTo(TimeOfDayUtils.duration(
                configBloc.configuracaoAtual.jornadaPadrao)) >
        0;
  }

  DateTime saidaEstimada(
      DadosIndicadorJornada dadosIndicador, bool intervaloRealizado) {
    DateTime estimativa = DateTime.now();
    if (pontoSelecionado.marcacoes != null &&
        pontoSelecionado.marcacoes.isNotEmpty) {
      estimativa = pontoSelecionado.marcacoes.last.marcacao;
    }
    DateTime hr = calcularHorasRestantes(dadosIndicador, intervaloRealizado);
    return estimativa.add(Duration(hours: hr.hour, minutes: hr.minute));
  }

  DateTime retornoEstimativaConclusaoIntervalo() {
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
          configBloc.configuracaoAtual.intervalorPadrao,
          tempoIntervaloRealizado);

      return DateTime.now().add(TimeOfDayUtils.duration(intervaloRestante));
    }
    return null;
  }

  DateTime calcularHorasRestantes(
      DadosIndicadorJornada dadosIndicador, bool intervaloRealizado) {
    TimeOfDay jornadaPadrao = configBloc.configuracaoAtual.jornadaPadrao;
    Duration intervalo = intervaloRealizado
        ? Duration(minutes: 0)
        : TimeOfDayUtils.duration(
            configBloc.configuracaoAtual.intervalorPadrao);

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

  bool verificarSeIntervaloRealizado() {
    bool iRealizado = false;
    var chunk = ListUtils.chunk(pontoSelecionado.marcacoesAgrupadas, 2);
    for (List lista in chunk) {
      if (lista.length == 2) {
        EntradaSaidaModel es1 = lista[0];
        EntradaSaidaModel es2 = lista[1];

        Duration direfenca = es2.entrada.difference(es1.saida);

        if (direfenca.inMinutes >
            TimeOfDayUtils.duration(
                    configBloc.configuracaoAtual.intervalorPadrao)
                .inMinutes) {
          iRealizado = true;
          break;
        }
      }
    }
    return iRealizado;
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
    definirTempoTrabalhado();
    _sincronizarPonto.alterar(pontoSelecionado);
    _pontoAtual.sink.add(pontoSelecionado);
  }

  void alterarMarcacao(MarcacaoPontoModel marcacao) {
    print('Alterar marcacao ${marcacao.marcacao}');

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
    definirTempoTrabalhado();

    _repository.incluirPonto(pontoSelecionado);
    _sincronizarPonto.alterar(pontoSelecionado);
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
}
