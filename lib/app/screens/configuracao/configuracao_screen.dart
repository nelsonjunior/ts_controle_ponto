import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/configuracao/components/spinner_botton.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/blocs/sincronizacao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/services/noticiacao_service.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';

class ConfiguracaoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var configuracaoBloc = AppModule.to.bloc<ConfiguracaoBloc>();
    configuracaoBloc.recuperarConfiguracao();

    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
        backgroundColor: corPrincipal,
      ),
      floatingActionButton: Container(
        height: 75,
        width: 75,
        child: FloatingActionButton(
            backgroundColor: corPrincipal,
            onPressed: () {
              Navigator.of(context).pop();
              configuracaoBloc.salvarConfiguracao();
            },
            child: Icon(Icons.save)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Jornada Padrão",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: StreamBuilder<TimeOfDay>(
                  stream: configuracaoBloc.jornadaPadraoStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SpinnerBotton(
                        tempo: snapshot.data,
                        aumentarOnTap: () {
                          configuracaoBloc.aumentarJornadaPadrao();
                        },
                        diminuirOnTap: () {
                          configuracaoBloc.diminuirJornadaPadrao();
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Intervalo Padrão",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: StreamBuilder<TimeOfDay>(
                  stream: configuracaoBloc.intervaloPadraoStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SpinnerBotton(
                        tempo: snapshot.data,
                        aumentarOnTap: () {
                          configuracaoBloc.aumentarIntervaloPadrao();
                        },
                        diminuirOnTap: () {
                          configuracaoBloc.diminuirIntervaloPadrao();
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Sincronizar Dados",
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5),
                ),
                SizedBox(
                  width: 20.0,
                ),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.green)),
                  onPressed: () {
                    AppModule.to
                        .bloc<SincronizacaoBloc>()
                        .iniciarSincronizacao();
                  },
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text("Iniciar", style: TextStyle(fontSize: 14)),
                )
              ],
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
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Notificações Agendadas",
              style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5),
            ),
            Container(
              child: FutureBuilder(
                future: HomeModule.to
                    .getDependency<NotificacaoService>()
                    .angendamentos(),
                builder: (context, snapshot) {
                  if ((snapshot.connectionState == ConnectionState.none &&
                          snapshot.hasData == null) ||
                      snapshot.data == null) {
                    return Container(
                      child: Text("Sem Agendamentos"),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      PendingNotificationRequest agendamento =
                          snapshot.data[index];
                      return ListTile(
                        selected: false,
                        leading: Icon(Icons.timer, size: 35.0,),
                        title: Text(agendamento.title),
                        subtitle: Text(agendamento.body),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
