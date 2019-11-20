import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
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
import 'package:ts_controle_ponto/app/shared/contantes.dart';
import 'package:ts_controle_ponto/app/shared/helpers/tutorial_helper.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
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

  DateTime _horarioSelecionado;

  PontoBloc pontoBloc = HomeModule.to.bloc<PontoBloc>();

  @override
  void initState() {
    _iconAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    initTargets(targets, keyBtnMarcarPonto, keyUltimaMarcacoes,
        keyTempoTrabalho, keyBtnConfiguracao);
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

      var retorno = pontoBloc.registrarMarcacao();

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

  void _detalharMarcacao(MarcacaoPontoModel marcacao, {bolAlteracao = true}) {
    print('Detalhar Marcacao ${marcacao.marcacao}');
    _horarioSelecionado = marcacao.marcacao;
    showSlideDialog(
      context: _scaffoldKey.currentContext,
      backgroundColor: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            height:
                MediaQuery.of(_scaffoldKey.currentContext).size.height * .25,
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
            padding: EdgeInsets.only(right: 25.0, left: 25.0),
            child: TimePickerWidget(
              initDateTime: _horarioSelecionado,
              dateFormat: FORMATO_HORA_PADRAO,
              pickerTheme: DateTimePickerTheme(
                  showTitle: false,
                  itemHeight:
                      MediaQuery.of(_scaffoldKey.currentContext).size.height *
                          .05,
                  pickerHeight:
                      MediaQuery.of(_scaffoldKey.currentContext).size.height *
                          .25),
              onChange: (dateTime, selectedIndex) {
                _horarioSelecionado = dateTime;
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    side: BorderSide(color: corPrincipal)),
                onPressed: () {
                  print('Confirmar alteracao marcacao ${marcacao.marcacao}');
                  if (_horarioSelecionado.compareTo(marcacao.marcacao) == 0 &&
                      bolAlteracao) {
                    Navigator.pop(_scaffoldKey.currentContext);
                  } else if (HomeModule.to
                      .bloc<PontoBloc>()
                      .verificarSeExisteMarcacao(_horarioSelecionado)) {
                    _exibirAlerta(_scaffoldKey.currentContext,
                        "Marcação já registrada ou inválida", false);
                  } else {
                    if (bolAlteracao) {
                      marcacao.marcacao = _horarioSelecionado;
                      pontoBloc.alterarMarcacao(marcacao);
                    } else {
                      HomeModule.to
                          .bloc<PontoBloc>()
                          .registrarMarcacao(marcacao: _horarioSelecionado);
                    }
                    Navigator.pop(_scaffoldKey.currentContext);
                    _exibirAlerta(_scaffoldKey.currentContext,
                        "Marcação salva com sucesso", true);
                  }
                },
                color: corPrincipal,
                textColor: Colors.white,
                child: Text("Confirmar", style: TextStyle(fontSize: 14)),
              ),
              SizedBox(
                width: 20.0,
              ),
              bolAlteracao
                  ? RaisedButton(
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
                      child: Text("Excluir", style: TextStyle(fontSize: 14)),
                    )
                  : Container(),
            ],
          )
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
                          return StreamBuilder<PontoModel>(
                              stream: pontoBloc.pontoStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || pontoBloc.loading) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return GestureDetector(
                                    onLongPress: () {
                                      _detalharMarcacao(
                                          new MarcacaoPontoModel(
                                              snapshot.data.identUsuario,
                                              snapshot.data.ident,
                                              DateTime.now()),
                                          bolAlteracao: false);
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
              IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    AppModule.to.bloc<AppBloc>().irParaDataAtual();
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
                stream: pontoBloc.dadosIndicadorStream,
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
                stream: pontoBloc.pontoStream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (AppModule.to.bloc<LoginBloc>().usuarioAtual == null) {
                    return Center(
                      child: Text("Autenticação não realizada."),
                    );
                  } else if (!pontoBloc.loading) {
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
                                _detalharMarcacao(
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

  void _tutorialConcluido() {
    _exibindoTutorial = false;
    AppModule.to.bloc<LoginBloc>().marcarTutorialConcluido();
  }

  void _iniciarTutorial() async {
    if (AppModule.to.bloc<LoginBloc>().iniciarTutorial && !_exibindoTutorial) {
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
    _iniciarTutorial();
  }
}
