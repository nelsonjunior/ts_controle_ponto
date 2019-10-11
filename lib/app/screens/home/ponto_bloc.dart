import 'dart:async';
import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:rxdart/subjects.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/shared/models/entrada_saida_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/list_utils.dart';

class PontoBloc extends BlocBase {
  var rnd = Random();

  Map<DateTime, PontoModel> histPontos = Map();

  PontoModel pontoInicial = PontoModel.empty(DateTime.now());

  BehaviorSubject<PontoModel> _pontoAtual;

  PontoBloc() {
    _pontoAtual = new BehaviorSubject<PontoModel>.seeded(this.pontoInicial);
  }

  Stream<PontoModel> get pontoStream => _pontoAtual.stream;

  void obterPonto(DateTime dataReferencia) {
    if (pontoInicial.dataReferencia.compareTo(dataReferencia) == 0) {
      return;
    }

    print('OBTER PONTO: $dataReferencia');

    if (!histPontos.containsKey(dataReferencia)) {
      histPontos[dataReferencia] = PontoModel.empty(dataReferencia);
    }

    pontoInicial = histPontos[dataReferencia];

    _pontoAtual.sink.add(pontoInicial);
  }

  void registrarMarcacao() {
    print('REGISTRANDO MARCAÇÃO');

    DateTime marcacao = DateTime.now();

    if (AppModule.to.bloc<AppBloc>().modoTeste) {
      if (pontoInicial.marcacoes.isNotEmpty) {
        marcacao = pontoInicial.marcacoes.last.marcacao;
      }
      marcacao = marcacao.add(Duration(minutes: rnd.nextInt(180) + 1));
    }

    pontoInicial.marcacoes
        .add(MarcacaoPontoModel(pontoInicial.ident, marcacao));

    ordernarMarcacoes();
    definirTempoTrabalhado();

    _pontoAtual.sink.add(pontoInicial);
  }

  void definirTempoTrabalhado() {
    var chunk = ListUtils.chunk(pontoInicial.marcacoes, 2);

    List<EntradaSaidaModel> marcacoesAgrupadas = [];
    for (List lista in chunk) {
      EntradaSaidaModel esm = new EntradaSaidaModel(lista[0].marcacao);

      if (lista.length == 2) {
        esm.saida = lista[1].marcacao;
      }

      marcacoesAgrupadas.add(esm);
    }
    print(marcacoesAgrupadas);
    pontoInicial.horasTrabalhadas = DateTime(pontoInicial.dataReferencia.year,
        pontoInicial.dataReferencia.month, pontoInicial.dataReferencia.day);
    for (EntradaSaidaModel esm in marcacoesAgrupadas) {
      pontoInicial.horasTrabalhadas = pontoInicial.horasTrabalhadas
          .add(Duration(minutes: esm.tempoTrabalhado));
    }

    Duration tempoTrabalho = Duration(
        hours: pontoInicial.horasTrabalhadas.hour,
        minutes: pontoInicial.horasTrabalhadas.minute);

    double percTotal = 100.0;
    double minTotalJornada = pontoInicial.horasJornada.inMinutes.toDouble();
    double minTrabalhados = tempoTrabalho.inMinutes.toDouble();

    pontoInicial.percentualJornada =
        ((percTotal / minTotalJornada) * minTrabalhados).toInt();
  }

  void ordernarMarcacoes() {
    pontoInicial.marcacoes.sort((a, b) => a.marcacao.compareTo(b.marcacao));
  }

  @override
  void dispose() {
    _pontoAtual.close();
    super.dispose();
  }

  void removerMarcacao(MarcacaoPontoModel marcacao) {
    pontoInicial.marcacoes.remove(marcacao);
    ordernarMarcacoes();
    definirTempoTrabalhado();
    _pontoAtual.sink.add(pontoInicial);
  }
}
