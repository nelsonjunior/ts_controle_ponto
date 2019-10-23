import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ts_controle_ponto/app/shared/models/entrada_saida_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:ts_controle_ponto/app/shared/utils/list_utils.dart';
import 'package:ts_controle_ponto/app/shared/utils/time_of_day_utils.dart';

class PontoModel {
  String ident;
  String identUsuario;
  DateTime dataReferencia;
  List<MarcacaoPontoModel> marcacoes;

  DateTime horasTrabalhadas;
  TimeOfDay duracaoJornada;
  TimeOfDay duracaoIntervalo;
  int percentualJornada;

  PontoModel(this.dataReferencia, {this.marcacoes, this.duracaoJornada});

  bool get jornadaCompleta =>
      Duration(hours: horasTrabalhadas.hour, minutes: horasTrabalhadas.minute)
          .compareTo(TimeOfDayUtils.duration(duracaoJornada)) >
      0;

  bool get intervalorRealizado {
    bool iRealizado = false;
    var chunk = ListUtils.chunk(marcacoesAgrupadas, 2);
    for (List lista in chunk) {
      if (lista.length == 2) {
        EntradaSaidaModel es1 = lista[0];
        EntradaSaidaModel es2 = lista[1];

        Duration direfenca = es2.entrada.difference(es1.saida);

        if (direfenca.inMinutes >
            TimeOfDayUtils.duration(duracaoIntervalo).inMinutes) {
          iRealizado = true;
          break;
        }
      }
    }
    return iRealizado;
  }

  Duration get horasIntervalo => intervalorRealizado
      ? Duration(minutes: 0)
      : TimeOfDayUtils.duration(duracaoIntervalo);

  DateTime get horasRestantes => DateTime(
          this.horasTrabalhadas.year,
          this.horasTrabalhadas.month,
          this.horasTrabalhadas.day,
          duracaoJornada.hour,
          duracaoJornada.minute)
      .add(horasIntervalo)
      .subtract(Duration(
          hours: horasTrabalhadas.hour, minutes: horasTrabalhadas.minute));

  DateTime get saidaEstimada {
    DateTime estimativa = DateTime.now();
    if (marcacoes != null && marcacoes.isNotEmpty) {
      estimativa = marcacoes.last.marcacao;
    }
    DateTime hr = horasRestantes;
    return estimativa.add(Duration(hours: hr.hour, minutes: hr.minute));
  }

  List<EntradaSaidaModel> get marcacoesAgrupadas {
    List<EntradaSaidaModel> marcacoesAgrupadas = [];

    if (marcacoes != null && marcacoes.isNotEmpty) {
      marcacoes.sort((a, b) => a.marcacao.compareTo(b.marcacao));

      var chunk = ListUtils.chunk(marcacoes, 2);

      for (List lista in chunk) {
        EntradaSaidaModel esm = new EntradaSaidaModel(lista[0].marcacao);

        if (lista.length == 2) {
          esm.saida = lista[1].marcacao;
        }
        marcacoesAgrupadas.add(esm);
      }
    }
    return marcacoesAgrupadas;
  }

  PontoModel.empty(this.dataReferencia) {
    this.ident = formatarDataHash.format(this.dataReferencia);
    this.dataReferencia = this.dataReferencia;
    this.horasTrabalhadas = DateTime(this.dataReferencia.year,
        this.dataReferencia.month, this.dataReferencia.day);
    this.marcacoes = [];
    this.percentualJornada = 0;
    this.duracaoJornada = TimeOfDay(hour: 8, minute: 0);
    this.duracaoIntervalo = TimeOfDay(hour: 1, minute: 0);
  }

  PontoModel.fromDocument(DocumentSnapshot document) {
    this.ident = document.data['ident'];
    this.identUsuario = document.data['identUsuario'];

    this.dataReferencia = formatarDataHash.parse(document.documentID);

    DateTime horasTrab = formatarHora.parse(document.data['horasTrabalhadas']);

    this.horasTrabalhadas = DateTime(
        this.dataReferencia.year,
        this.dataReferencia.month,
        this.dataReferencia.day,
        horasTrab.hour,
        horasTrab.minute);

    if (document.data.containsKey('jornadaHoras') &&
        document.data.containsKey('jornadaMinutos')) {
      this.duracaoJornada = TimeOfDay(
          hour: document.data['jornadaHoras'],
          minute: document.data['jornadaMinutos']);
    } else {
      this.duracaoJornada = TimeOfDay(hour: 8, minute: 0);
    }

    if (document.data.containsKey('intervaloHoras') &&
        document.data.containsKey('intervaloMinutos')) {
      this.duracaoIntervalo = TimeOfDay(
          hour: document.data['intervaloHoras'],
          minute: document.data['intervaloMinutos']);
    } else {
      this.duracaoIntervalo = TimeOfDay(hour: 1, minute: 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'ident': ident,
      'identUsuario': identUsuario,
      'horasTrabalhadas': formatarHora.format(horasTrabalhadas),
      'jornadaHoras': duracaoJornada.hour,
      'jornadaMinutos': duracaoJornada.minute,
      'intervaloHoras': duracaoIntervalo.hour,
      'intervaloMinutos': duracaoIntervalo.minute,
      'percentualJornada': percentualJornada
    };
  }

  @override
  String toString() {
    return "Ident $ident IDUsuario $identUsuario Data Referência: $dataReferencia, horasTrabalhadas: $horasTrabalhadas, jornada: $duracaoJornada, percentualJornal: $percentualJornada";
  }
}
