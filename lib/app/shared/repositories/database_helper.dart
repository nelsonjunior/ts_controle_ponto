import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final pontoTABLE = 'PONTO';
final marcacaoTABLE = 'MARCACAO';
final usuarioTABLE = 'USUARIO';
final configuracaoTABLE = 'CONFIGURACAO';
final sincronizacaoTABLE = 'SINCRONIZACAO';
final parametrosAPPTABLE = 'PARAMETROSAPP';

class DatabaseHelper {
  static final DatabaseHelper dbHelper = DatabaseHelper();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TSControlePonto.db");

    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade);
    return database;
  }

  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }

  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $parametrosAPPTABLE ("
        "identParametro TEXT PRIMARY KEY, "
        "valorParametro TEXT "
        ")");
        
    await database.execute("CREATE TABLE $configuracaoTABLE ("
        "identUsuario TEXT PRIMARY KEY, "
        "intervalorPadraoHoras INTEGER, "
        "intervalorPadraoMinutos INTEGER, "
        "jornadaPadraoHoras INTEGER, "
        "jornadaPadraoMintos INTEGER "
        ")");

    await database.execute("CREATE TABLE $usuarioTABLE ("
        "email TEXT PRIMARY KEY, "
        "fotoURL TEXT, "
        "nome TEXT, "
        "nomeCompleto INTEGER "
        ")");

    await database.execute("CREATE TABLE $pontoTABLE ("
        "ident TEXT PRIMARY KEY, "
        "identUsuario TEXT, "
        "horasTrabalhadas TEXT, "
        "intervaloHoras INTEGER, "
        "intervaloMinutos INTEGER, "
        "jornadaHoras INTEGER, "
        "jornadaMinutos INTEGER, "
        "percentualJornada INTEGER "
        ")");

    await database.execute("CREATE TABLE $marcacaoTABLE ("
        "ident Integer PRIMARY KEY AUTOINCREMENT, "
        "descricao TEXT, "
        "identPonto TEXT, "
        "identUsuario TEXT, "
        "marcacao TEXT, "
        "tipo TEXT, "
        "imagem TEXT "
        ")");

    await database.execute("CREATE TABLE $sincronizacaoTABLE ("
        "ident Integer PRIMARY KEY AUTOINCREMENT, "
        "documentID TEXT, "
        "document TEXT, "
        "data TEXT, "
        "acao TEXT "
        ")");
  }
}
