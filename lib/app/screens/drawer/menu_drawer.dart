import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_controle_ponto/app/app_module.dart';
import 'package:ts_controle_ponto/app/screens/configuracao/configuracao_screen.dart';
import 'package:ts_controle_ponto/app/shared/blocs/login_bloc.dart';
import 'package:ts_controle_ponto/app/shared/components/circular_image.dart';
import 'package:ts_controle_ponto/app/shared/components/zoom_scaffold.dart';
import 'package:ts_controle_ponto/app/shared/models/usuario_model.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';

class MenuScreen extends StatelessWidget {
  final List<MenuItem> options = [
    MenuItem(Icons.format_list_bulleted, 'Histórico'),
    MenuItem(Icons.assignment, 'Relatórios'),
    MenuItem(Icons.assessment, 'Gráficos'),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        //on swiping left
        if (details.delta.dx < -6) {
          Provider.of<MenuController>(context, listen: true).toggle();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
            top: 62,
            left: 32,
            bottom: 8,
            right: MediaQuery.of(context).size.width / 2.9),
        color: corPrincipal1,
        child: Column(
          children: <Widget>[
            StreamBuilder<UsuarioModel>(
                stream: AppModule.to.bloc<LoginBloc>().usuarioStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: IconButton(
                        onPressed: () {
                          AppModule.to.bloc<LoginBloc>().sigInGoogle();
                        },
                        icon: Icon(Icons.account_circle,
                            color: Colors.white, size: 80),
                      ),
                    );
                  } else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        {
                          return Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: CircularImage(
                                  NetworkImage(snapshot.data.fotoURL),
                                ),
                              ),
                              Text(
                                snapshot.data.nome,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )
                            ],
                          );
                        }
                    }
                  }
                }),
            SizedBox(height: 40.0),
            Column(
              children: options.map((item) {
                return ListTile(
                  leading: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                );
              }).toList(),
            ),
            Spacer(),
            ListTile(
              onTap: () {
                Provider.of<MenuController>(context, listen: true).toggle();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ConfiguracaoScreen()));
              },
              leading: Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
              title: Text('Configurações',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
            ListTile(
              onTap: () {},
              leading: Icon(
                Icons.headset_mic,
                color: Colors.white,
                size: 20,
              ),
              title: Text('Ajuda',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
            ListTile(
              onTap: () {
                AppModule.to.bloc<LoginBloc>().signOutGoogle();
                Provider.of<MenuController>(context, listen: true).toggle();
              },
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.white,
                size: 20,
              ),
              title: Text('Sair',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.icon, this.title);
}
