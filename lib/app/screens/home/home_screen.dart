import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/home/components/dados_indicador_jornada.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/sincronizacao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/components/zoom_scaffold.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'components/barra_principal.dart';
import 'components/indicador_jornada.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<TargetFocus> targets = List();

  GlobalKey keyBtnMarcarPonto = GlobalKey();
  GlobalKey keyUltimaMarcacoes = GlobalKey();
  GlobalKey keyTempoTrabalho = GlobalKey();
  GlobalKey keyBtnConfiguracao = GlobalKey();

  AnimationController _iconAnimationController;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Duration animationDurationPadrao = Duration(milliseconds: 600);

  int currentPage = 1;

  bool _exibindoTutorial = false;

  @override
  void initState() {
    _iconAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    initTargets();
    WidgetsBinding.instance.addPostFrameCallback(_verificarUsuarioLogado);
    super.initState();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _registrarMarcacao() {
    if (!animationStatus) {
      _iconAnimationController.forward();

      var retorno = HomeModule.to.bloc<PontoBloc>().registrarMarcacao();

      _exibirAlerta(
          _scaffoldKey.currentContext,
          retorno
              ? "Marcação salva com sucesso"
              : "Marcação já registrada ou inválida",
          retorno);

      Future.delayed(animationDurationPadrao).then((_) {
        _iconAnimationController.reverse();
      });
    }
  }

  void _exibirAlerta(BuildContext context, String texto, bool isValido) {
    Flushbar(
        message: "$texto!",
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: isValido ? corPrincipal1 : Colors.white,
        ),
        animationDuration: animationDurationPadrao,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 100.0),
        borderRadius: 8,
        backgroundGradient: LinearGradient(
          colors: isValido
              ? [corPrincipal, corPrincipal1]
              : [Colors.red, Colors.redAccent],
        ))
      ..show(context);
  }

  Future<TimeOfDay> _alterarMarcacao(MarcacaoPontoModel marcacao) {
    Future<TimeOfDay> picked = showTimePicker(
        context: _scaffoldKey.currentContext,
        initialTime: TimeOfDay.fromDateTime(new DateTime(
            marcacao.marcacao.year,
            marcacao.marcacao.month,
            marcacao.marcacao.day,
            marcacao.marcacao.hour,
            marcacao.marcacao.minute)));

    picked.then((TimeOfDay time) {
      if (time != null) {
        if (HomeModule.to.bloc<PontoBloc>().verificarSeExisteMarcacao(time)) {
          _exibirAlerta(_scaffoldKey.currentContext,
              "Marcação já registrada ou inválida", false);
        } else {
          marcacao.marcacao = DateTime(
              marcacao.marcacao.year,
              marcacao.marcacao.month,
              marcacao.marcacao.day,
              time.hour,
              time.minute);

          HomeModule.to.bloc<PontoBloc>().alterarMarcacao(marcacao);

          _exibirAlerta(
              _scaffoldKey.currentContext, "Marcação salva com sucesso", true);
        }
      }
    });

    return picked;
  }

  void _detalharMarcacao(MarcacaoPontoModel marcacao) {
    showSlideDialog(
      context: _scaffoldKey.currentContext,
      backgroundColor: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            height: 180.0,
            padding: EdgeInsets.all(0.0),
            margin: EdgeInsets.all(0.0),
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  color: Colors.grey[700],
                ),
                onPressed: () {},
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: Colors.blue,
                        size: 40.0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          formatarHora.format(marcacao.marcacao),
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.0),
                        ),
                      ),
                      Spacer(),
                      MaterialButton(
                        child: Text(
                          "Alterar",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.0),
                        ),
                        onPressed: () {
                          Navigator.pop(_scaffoldKey.currentContext);
                          _alterarMarcacao(marcacao);
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        HomeModule.to
                            .bloc<PontoBloc>()
                            .removerMarcacao(marcacao);
                        Navigator.pop(_scaffoldKey.currentContext);
                      },
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text("REMOVER", style: TextStyle(fontSize: 14)),
                    ),
                  )
                ],
              )),
        ],
      ),
    );
  }

  bool get animationStatus {
    final AnimationStatus status = _iconAnimationController.status;
    return status == AnimationStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 75.0,
          width: 75.0,
          child: FittedBox(
            child: FloatingActionButton(
                key: keyBtnMarcarPonto,
                backgroundColor: Colors.red,
                elevation: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 4.0)),
                  child: StreamBuilder(
                      stream: AppModule.to.bloc<LoginBloc>().usuarioStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // _iniciarTutorial();
                          return StreamBuilder<PontoModel>(
                              stream:
                                  HomeModule.to.bloc<PontoBloc>().pontoStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    HomeModule.to.bloc<PontoBloc>().loading) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return GestureDetector(
                                    onLongPress: () {
                                      if (!animationStatus) {
                                        _iconAnimationController.forward();
                                        _alterarMarcacao(new MarcacaoPontoModel(
                                                snapshot.data.identUsuario,
                                                snapshot.data.ident,
                                                DateTime.now()))
                                            .whenComplete(() {
                                          _iconAnimationController.reverse();
                                        });
                                      }
                                    },
                                    child: IconButton(
                                        icon: AnimatedIcon(
                                            icon: AnimatedIcons.add_event,
                                            color: Colors.white,
                                            progress:
                                                _iconAnimationController.view),
                                        onPressed: () {
                                          _registrarMarcacao();
                                        }),
                                  );
                                }
                              });
                        } else {
                          return IconButton(
                              icon:
                                  Icon(Icons.account_box, color: Colors.white),
                              onPressed: () {
                                AppModule.to.bloc<LoginBloc>().sigInGoogle();
                              });
                        }
                      }),
                ),
                onPressed: () {}),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                key: keyBtnConfiguracao,
                icon: Icon(Icons.menu),
                onPressed: () {
                  Provider.of<MenuController>(context, listen: true).toggle();
                },
              ),
              StreamBuilder<bool>(
                  stream: AppModule.to.bloc<AppBloc>().modoTesteSream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return IconButton(
                          icon: Icon(
                            Icons.report_problem,
                            color:
                                snapshot.data ? Colors.yellow : Colors.black87,
                          ),
                          onPressed: () {
                            AppModule.to.bloc<AppBloc>().alterarModoTeste();
                          });
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            BarraPrincipal(),
            StreamBuilder<DadosIndicadorJornada>(
                key: keyTempoTrabalho,
                stream: HomeModule.to.bloc<PontoBloc>().dadosIndicadorStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return IndicadorJornada(snapshot.data);
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            SizedBox(
              height: 25.0,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Últimas marcações",
                key: keyUltimaMarcacoes,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
            Expanded(
              child: StreamBuilder<PontoModel>(
                stream: HomeModule.to.bloc<PontoBloc>().pontoStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (AppModule.to.bloc<LoginBloc>().usuarioAtual == null) {
                    return Center(
                      child: Text("Autenticação não realizada."),
                    );
                  } else if (!HomeModule.to.bloc<PontoBloc>().loading) {
                    return GridView.builder(
                      padding: EdgeInsets.all(16.0),
                      scrollDirection: Axis.vertical,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 4.0,
                          crossAxisSpacing: 4.0,
                          crossAxisCount: 4,
                          childAspectRatio: 3),
                      itemCount: snapshot.data.marcacoes.length,
                      itemBuilder: (BuildContext context, int index) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          default:
                            return GestureDetector(
                              onLongPress: () {
                                _alterarMarcacao(
                                    snapshot.data.marcacoes[index]);
                              },
                              child: MaterialButton(
                                padding: EdgeInsets.all(0.0),
                                onPressed: () {
                                  _detalharMarcacao(
                                      snapshot.data.marcacoes[index]);
                                },
                                child: Text(
                                  formatarHora.format(
                                      snapshot.data.marcacoes[index].marcacao),
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                            );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            StreamBuilder<bool>(
                stream:
                    AppModule.to.bloc<SincronizacaoBloc>().sincronizacaoStreem,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Sincronizando...",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: corPrincipal,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                        LinearProgressIndicator()
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
          ],
        ));
  }

  void initTargets() {
    targets.add(TargetFocus(
      identify: "Marcar Ponto",
      keyTarget: keyBtnMarcarPonto,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Registrar Ponto ficou fácil",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Primeiro escolha sua conta do google para podermos salvar suas marcações na nuvem! Com um toque uma nova marcação é registrada automáticamente. Um toque longo você pode definir qual o horário da marcação.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Ultimas Marcacoes",
      keyTarget: keyUltimaMarcacoes,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Últimas marcações",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Suas últimas marcações serão mostradas nesse espaço, através delas será feito o cálculo do tempo trabalho.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Tempo Trabalhado",
      keyTarget: keyTempoTrabalho,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Tempo Trabalho",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "O tempo trabalho será cálculado através da difereça das marcações de entrada e saída. Será mostrado tempo restando para o termino da sua jornada.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Alterar Jornada",
      keyTarget: keyBtnConfiguracao,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Alterar Jornada",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Você poderá alterar aquantidade de horas da sua jornada e tempo padrão de intervalo através do menu de configurações.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
    targets.add(TargetFocus(
      identify: "Barra Navegacao",
      targetPosition: TargetPosition(Size(60.0, 60.0), Offset(20.0, 20.0)),
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Alterar Data",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Você consultar ou realizar as marcações em dias diferentes navegando para datas anteriores ou futuras.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
    ));
  }

  void _tutorialConcluido() {
    _exibindoTutorial = false;
    AppModule.to.bloc<LoginBloc>().marcarTutorialConcluido();
  }

  void _iniciarTutorial() async {
    if (AppModule.to.bloc<LoginBloc>().iniciarTutorial &&
        !_exibindoTutorial) {
      print('_iniciarTutorial');
      
      _exibindoTutorial = true;
      TutorialCoachMark(context,
          targets: targets,
          colorShadow: Colors.black54,
          textSkip: "Pular",
          paddingFocus: 20.0,
          opacityShadow: 0.8,
          finish: _tutorialConcluido)
        ..show();
    }
  }

  void _verificarUsuarioLogado(_) {
    AppModule.to.bloc<LoginBloc>().verificarUsuarioLogado();
  }
}
