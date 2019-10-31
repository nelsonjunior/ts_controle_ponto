import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';

import 'database_helper.dart';

class MarcacaoDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<MarcacaoPontoModel> incluirMarcacao(
      MarcacaoPontoModel marcacaoModel) async {
    final db = await dbHelper.database;
    int id = await db.insert(marcacaoTABLE, marcacaoModel.toMap());
    marcacaoModel.ident = id.toString();
    return marcacaoModel;
  }

  Future<List<MarcacaoPontoModel>> recuperarMarcacoes(
      String identUsuario, String identPonto) async {
    
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(marcacaoTABLE,
        where: 'identUsuario = ? and identPonto = ?',
        whereArgs: [identUsuario, identPonto]);
    return result.isNotEmpty
        ? List.generate(
            result.length, (index) => MarcacaoPontoModel.fromMap(result[index]))
        : [];
  }

  Future<void> alterarMarcacao(MarcacaoPontoModel marcacaoModel) async {
    final db = await dbHelper.database;
    await db.update(marcacaoTABLE, marcacaoModel.toMap(),
        where: 'ident = ?', whereArgs: [marcacaoModel.ident]);
  }

  Future<void> removerMarcacao(MarcacaoPontoModel marcacaoModel) async {
    final db = await dbHelper.database;
    await db.delete(marcacaoTABLE,
        where: 'ident = ?', whereArgs: [marcacaoModel.ident]);
  }

  Future<void> removerMarcacoesPorUsuario(String identUsuario) async {
    final db = await dbHelper.database;
    await db.delete(marcacaoTABLE,
        where: 'identUsuario = ?', whereArgs: [identUsuario]);
  }
}
