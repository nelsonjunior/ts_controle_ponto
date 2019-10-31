import 'package:ts_controle_ponto/app/shared/models/sincronizacao_model.dart';

import 'database_helper.dart';

class SincronizacaoDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<SincronizacaoModel> incluir(
      SincronizacaoModel sincronizacaoModel) async {
    final db = await dbHelper.database;
    int id = await db.insert(sincronizacaoTABLE, sincronizacaoModel.toMap());
    sincronizacaoModel.ident = id;
    return sincronizacaoModel;
  }

  Future<List<SincronizacaoModel>> recuperarPendentes(String document) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(sincronizacaoTABLE,
        where: 'document = ?', whereArgs: [document]);
    return result.isNotEmpty
        ? List.generate(
            result.length, (index) => SincronizacaoModel.fromMap(result[index]))
        : null;
  }

  Future<void> remover(SincronizacaoModel sincronizacaoModel) async {
    final db = await dbHelper.database;
    await db.delete(sincronizacaoTABLE,
        where: 'ident = ?', whereArgs: [sincronizacaoModel.ident]);
  }

  Future<void> removerTodos() async {
    final db = await dbHelper.database;
    await db.delete(sincronizacaoTABLE);
  }
}
