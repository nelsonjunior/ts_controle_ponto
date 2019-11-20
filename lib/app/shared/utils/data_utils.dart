import 'package:intl/intl.dart';

var formatarDiaDaSemana = DateFormat("EEEE");

var formatarData = DateFormat("d MMM y");

var formatarDataHash = DateFormat("dd-MM-yyyy");

var formatarHora = DateFormat("HH:mm");

bool isHoje(DateTime dataReferencia) {
  var hoje = DateTime.now();
  return dataReferencia.compareTo(DateTime(hoje.year, hoje.month, hoje.day)) ==
      0;
}
