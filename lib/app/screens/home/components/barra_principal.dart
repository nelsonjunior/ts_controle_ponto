import 'package:flutter/material.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';

import '../../../app_bloc.dart';
import '../../../app_module.dart';
import 'fundo_barra_principal.dart';

class BarraPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FundoBarraPrincipal(),
        StreamBuilder<DateTime>(
            stream: AppModule.to.bloc<AppBloc>().dataStream,
            initialData: DateTime.now(),
            builder: (context, snapshot) {
              HomeModule.to.bloc<PontoBloc>().obterPonto(snapshot.data);

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          AppModule.to.bloc<AppBloc>().dataAnterior();
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Text(
                              formatarDiaDaSemana
                                  .format(snapshot.data)
                                  .toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 18.0),
                            ),
                            Text(
                              formatarData.format(snapshot.data),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.90),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.1,
                                  wordSpacing: 1.2,
                                  fontSize: 14.0),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          AppModule.to.bloc<AppBloc>().proximaData();
                        },
                      )
                    ],
                  ),
                ),
              );
            })
      ],
    );
  }
}
