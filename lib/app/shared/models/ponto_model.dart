import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class PontoModel {
  String ident;

  DateTime dataReferencia;
  List<MarcacaoPontoModel> marcacoes;

  DateTime horasTrabalhadas;
  Duration horasJornada;
  int percentualJornada;

  PontoModel(this.dataReferencia, {this.marcacoes, this.horasJornada});

  PontoModel.empty(this.dataReferencia) {
    this.ident = formatarData.format(this.dataReferencia);
    this.dataReferencia = this.dataReferencia;
    this.horasTrabalhadas = DateTime(this.dataReferencia.year,
        this.dataReferencia.month, this.dataReferencia.day);
    this.marcacoes = [];
    this.percentualJornada = 0;
    this.horasJornada = Duration(hours: 8);
  }

  @override
  String toString() {
    return "Data Referência: $dataReferencia, horasTrabalhadas: $horasTrabalhadas, jornada: $horasJornada, percentualJornal: $percentualJornada";
  }
}
