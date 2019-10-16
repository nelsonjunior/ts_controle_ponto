import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class PontoModel {
  String ident;
  String identUsuario;
  DateTime dataReferencia;
  List<MarcacaoPontoModel> marcacoes;

  DateTime horasTrabalhadas;
  Duration horasJornada;
  int percentualJornada;

  PontoModel(this.dataReferencia, {this.marcacoes, this.horasJornada});

  bool get jornadaCompleta =>
      Duration(hours: horasTrabalhadas.hour, minutes: horasTrabalhadas.minute)
          .compareTo(horasJornada) >
      0;

  DateTime get horasRestantes => DateTime(
          this.horasTrabalhadas.year,
          this.horasTrabalhadas.month,
          this.horasTrabalhadas.day,
          horasJornada.inHours)
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

  PontoModel.empty(this.dataReferencia) {
    this.ident = formatarDataHash.format(this.dataReferencia);
    this.dataReferencia = this.dataReferencia;
    this.horasTrabalhadas = DateTime(this.dataReferencia.year,
        this.dataReferencia.month, this.dataReferencia.day);
    this.marcacoes = [];
    this.percentualJornada = 0;
    this.horasJornada = Duration(hours: 8);
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
    this.horasJornada = Duration(hours: document.data['horasJornada']);
    this.percentualJornada = document.data['percentualJornada'];
  }

  Map<String, dynamic> toMap() {
    return {
      'ident': ident,
      'identUsuario': identUsuario,
      'horasTrabalhadas': formatarHora.format(horasTrabalhadas),
      'horasJornada': horasJornada.inHours,
      'percentualJornada': percentualJornada
    };
  }

  @override
  String toString() {
    return "Ident $ident IDUsuario $identUsuario Data Referência: $dataReferencia, horasTrabalhadas: $horasTrabalhadas, jornada: $horasJornada, percentualJornal: $percentualJornada";
  }
}
