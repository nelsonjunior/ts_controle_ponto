import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_widget.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/sincronizacao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/repositories/repository.dart';
import 'package:ts_controle_ponto/app/shared/services/noticiacao_service.dart';

class AppModule extends ModuleWidget {
  @override
  List<Bloc<BlocBase>> get blocs => [
        Bloc((i) => AppBloc(i.get())),
        Bloc((i) => LoginBloc()),
        Bloc((i) => ConfiguracaoBloc()),
        Bloc((i) => SincronizacaoBloc()),
      ];

  @override
  List<Dependency> get dependencies => [
        Dependency((i) => Repository()),
        Dependency((i) => NotificacaoService()),
      ];

  @override
  Widget get view => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
