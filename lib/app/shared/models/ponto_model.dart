import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_controle_ponto/app/shared/models/entrada_saida_model.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:ts_controle_ponto/app/shared/utils/list_utils.dart';

class PontoModel {
  String ident;
  String identUsuario;
  DateTime dataReferencia;
  DateTime horasTrabalhadas;
  List<MarcacaoPontoModel> marcacoes;

  PontoModel(this.dataReferencia, {this.marcacoes});

  PontoModel.empty(this.dataReferencia) {
    this.ident = formatarDataHash.format(this.dataReferencia);
    this.dataReferencia = this.dataReferencia;
    this.horasTrabalhadas = DateTime(this.dataReferencia.year,
        this.dataReferencia.month, this.dataReferencia.day);
    this.marcacoes = [];
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
  }

  PontoModel.fromMap(Map<String, dynamic> data) {
    this.ident = data['ident'];
    this.identUsuario = data['identUsuario'];
    this.dataReferencia = formatarDataHash.parse(data['ident']);
    DateTime horasTrab = formatarHora.parse(data['horasTrabalhadas']);

    this.horasTrabalhadas = DateTime(
        this.dataReferencia.year,
        this.dataReferencia.month,
        this.dataReferencia.day,
        horasTrab.hour,
        horasTrab.minute);
  }

  Map<String, dynamic> toMap() {
    return {
      'ident': ident,
      'identUsuario': identUsuario,
      'horasTrabalhadas': formatarHora.format(horasTrabalhadas),
    };
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

  @override
  String toString() {
    return "Ident $ident IDUsuario $identUsuario Data Referência: $dataReferencia";
  }
}
