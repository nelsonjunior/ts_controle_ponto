import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ts_controle_ponto/app/screens/drawer/drawer_screen.dart';

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection("iosNovo")
        .document("Teste")
        .setData({"teste": "testevalor"});

    Intl.defaultLocale = 'pt_BR';
    initializeDateFormatting();

    return MaterialApp(
      title: 'TS Controle de Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawerScreen(),
    );
  }
}
