import 'package:flutter/material.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/configuracao/components/spinner_botton.dart';
import 'package:ts_controle_ponto/app/shared/blocs/configuracao_bloc.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';

class ConfiguracaoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var configuracaoBloc = AppModule.to.bloc<ConfiguracaoBloc>();

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
            )
          ],
        ),
      ),
    );
  }
}
