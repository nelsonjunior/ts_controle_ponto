import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_widget.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';

class AppModule extends ModuleWidget {
  @override
  List<Bloc<BlocBase>> get blocs => [
        Bloc((i) => AppBloc()),
        Bloc((i) => LoginBloc()),
      ];

  @override
  List<Dependency> get dependencies => [];

  @override
  Widget get view => AppWidget();

  static Inject get to => Inject<AppModule>.of();
}
