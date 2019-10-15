import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart';
import 'package:ts_controle_ponto/app/app_bloc.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/components/zoom_scaffold.dart';
import 'package:ts_controle_ponto/app/shared/models/marcacao_ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

import 'components/barra_principal.dart';
import 'components/indicador_jornada.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _iconAnimationController;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Duration animationDurationPadrao = Duration(milliseconds: 600);

  int currentPage = 1;

  @override
  void initState() {
    _iconAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    super.initState();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  void onIconPressed() {
    if (!animationStatus) {
      _iconAnimationController.forward();

      showInfoFlushbar(_scaffoldKey.currentContext);

      HomeModule.to.bloc<PontoBloc>().registrarMarcacao();

      Future.delayed(animationDurationPadrao).then((_) {
        _iconAnimationController.reverse();
      });
    }
  }

  void showInfoFlushbar(BuildContext context) {
    Flushbar(
        message: "Marcação Registrada!",
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: corPrincipal1,
        ),
        animationDuration: animationDurationPadrao,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 100.0),
        borderRadius: 8,
        backgroundGradient: LinearGradient(
          colors: [corPrincipal, corPrincipal1],
        ))
      ..show(context);
  }

  void _alterarMarcacao(MarcacaoPontoModel marcacao) {
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
                    children: <Widget>[
                      Text(
                        "Horário:",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "${marcacao.tipo ?? 'Entrada'} às ${formatarHora.format(marcacao.marcacao)}",
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
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
                backgroundColor: Colors.red,
                elevation: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 4.0)),
                  child: StreamBuilder(
                      stream: AppModule.to.bloc<LoginBloc>().googleAccount,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return StreamBuilder<PontoModel>(
                              stream:
                                  HomeModule.to.bloc<PontoBloc>().pontoStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    HomeModule.to.bloc<PontoBloc>().loading) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else {
                                  return IconButton(
                                      icon: AnimatedIcon(
                                          icon: AnimatedIcons.add_event,
                                          color: Colors.white,
                                          progress:
                                              _iconAnimationController.view),
                                      onPressed: () {
                                        onIconPressed();
                                      });
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
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
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
            StreamBuilder<PontoModel>(
                stream: HomeModule.to.bloc<PontoBloc>().pontoStream,
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
                  if (!HomeModule.to.bloc<PontoBloc>().loading) {
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
                            return MaterialButton(
                              padding: EdgeInsets.all(0.0),
                              onPressed: () {
                                _alterarMarcacao(
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
          ],
        ));
  }
}
