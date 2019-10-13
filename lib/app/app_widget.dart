import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ts_controle_ponto/app/screens/drawer/drawer_screen.dart';

class AppWidget extends StatelessWidget {
  
  static FirebaseAnalytics analytics = FirebaseAnalytics();

  static FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {

    Intl.defaultLocale = 'pt_BR';
    initializeDateFormatting();

    return MaterialApp(
      title: 'TS Controle de Ponto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: DrawerScreen(),
    );
  }
}
