import 'package:sqflite/sqflite.dart';
import 'package:ts_controle_ponto/app/shared/models/parametro_app_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/database_helper.dart';

class ParametroAppDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<ParametroAppModel> incluirOuAlterar(ParametroAppModel model) async {
    final db = await dbHelper.database;
    db.insert(parametrosAPPTABLE, model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return model;
  }

  Future<ParametroAppModel> recuperar(String identParametro) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(parametrosAPPTABLE,
        where: 'identParametro = ?', whereArgs: [identParametro]);
    return result.isNotEmpty ? ParametroAppModel.fromMap(result.first) : null;
  }

  Future<int> remover(String identParametro) async {
    final db = await dbHelper.database;
    var delete = db.delete(parametrosAPPTABLE,
        where: 'identParametro = ?', whereArgs: [identParametro]);
    return delete;
  }
}
