import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts_controle_ponto/app/shared/components/zoom_scaffold.dart';

import 'menu_drawer.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen>
    with TickerProviderStateMixin {
  MenuController menuController;

  @override
  void initState() {
    super.initState();

    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => menuController,
      child: ZoomScaffold(
        menuScreen: MenuScreen(),
        contentScreen: Layout(
            contentBuilder: (cc) => Container(
                  color: Colors.grey[200],
                  child: Container(
                    color: Colors.grey[500],
                  ),
                )),
      ),
    );
  }
}
