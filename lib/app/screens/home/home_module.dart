import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/widgets.dart';
import 'package:ts_controle_ponto/app/screens/home/home_screen.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/services/noticiacao_service.dart';

class HomeModule extends ModuleWidget {
  @override
  List<Bloc<BlocBase>> get blocs => [
        Bloc((i) => PontoBloc(i.get())),
      ];

  @override
  List<Dependency> get dependencies => [
        Dependency((i) => NotificacaoService()),
      ];

  @override
  Widget get view => HomeScreen();

  static Inject get to => Inject<HomeModule>.of();
}
