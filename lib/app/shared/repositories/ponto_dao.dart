import 'package:sqflite/sqflite.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/marcacao_dao.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

import 'database_helper.dart';

class PontoDao {
  final dbHelper = DatabaseHelper.dbHelper;
  final _marcacaoDao = MarcacaoDao();

  Future<PontoModel> incluirPonto(PontoModel pontoModel) async {
    final db = await dbHelper.database;
    db.insert(pontoTABLE, pontoModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return pontoModel;
  }

  Future<PontoModel> recuperarPontoPorData(
      String identUsuario, DateTime dataReferencia) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(pontoTABLE,
        where: 'identUsuario = ? and ident = ?',
        whereArgs: [identUsuario, formatarDataHash.format(dataReferencia)]);

    var pontoModel =
        result.isNotEmpty ? PontoModel.fromMap(result.first) : null;
    if (pontoModel != null) {
      pontoModel.marcacoes =
          await _marcacaoDao.recuperarMarcacoes(identUsuario, pontoModel.ident);
    }
    return pontoModel;
  }

  Future<PontoModel> recuperarPonto(String identPonto) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db
        .query(pontoTABLE, where: 'ident = ? ', whereArgs: [identPonto]);
    return result.isNotEmpty ? PontoModel.fromMap(result.first) : null;
  }

  Future<void> alterarPonto(PontoModel pontoModel) async {
    final db = await dbHelper.database;
    await db.update(pontoTABLE, pontoModel.toMap(),
        where: 'ident', whereArgs: [pontoModel.ident]);
  }

  Future<void> removerPontosPorUsuario(String identUsuario) async {
    final db = await dbHelper.database;
    await db.delete(pontoTABLE,
        where: 'identUsuario', whereArgs: [identUsuario]);
  }
}
