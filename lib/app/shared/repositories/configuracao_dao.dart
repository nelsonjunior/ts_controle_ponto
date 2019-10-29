import 'package:sqflite/sqflite.dart';
import 'package:ts_controle_ponto/app/shared/models/configuracao_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/database_helper.dart';

class ConfiguracaoDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<ConfiguracaoModel> incluir(ConfiguracaoModel configuracaoModel) async {
    print('Incluir configuracao: $configuracaoModel');
    final db = await dbHelper.database;
    db.insert(configuracaoTABLE, configuracaoModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return configuracaoModel;
  }

  Future<ConfiguracaoModel> recuperar(String identUsuario) async {
    print('recuperar configuracao: $identUsuario');
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(configuracaoTABLE,
        where: 'identUsuario = ?', whereArgs: [identUsuario]);
    return result.isNotEmpty ? ConfiguracaoModel.fromMap(result.first) : null;
  }

  Future<void> alterar(ConfiguracaoModel usuarioModel) async {
    final db = await dbHelper.database;
    await db.update(configuracaoTABLE, usuarioModel.toMap(),
        where: 'identUsuario = ?', whereArgs: [usuarioModel.identUsuario]);
  }
}
