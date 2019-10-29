import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/repositories/database_helper.dart';

class UsuarioDao {
  final dbHelper = DatabaseHelper.dbHelper;

  Future<UsuarioModel> incluirUsuario(UsuarioModel usuarioModel) async {
    final db = await dbHelper.database;
    db.insert(usuarioTABLE, usuarioModel.toMap());
    return usuarioModel;
  }

  Future<UsuarioModel> recuperarUsuario(String identUsuario) async {
    final db = await dbHelper.database;
    List<Map<String, dynamic>> result =
        await db.query(usuarioTABLE, where: 'email = ?', whereArgs: [identUsuario]);
    return result.isNotEmpty ? UsuarioModel.fromMap(result.first) : null;
  }

  Future<void> alterarUsuario(UsuarioModel usuarioModel) async {
    final db = await dbHelper.database;
    await db.update(usuarioTABLE, usuarioModel.toMap(),
        where: 'email', whereArgs: [usuarioModel.email]);
  }
}
