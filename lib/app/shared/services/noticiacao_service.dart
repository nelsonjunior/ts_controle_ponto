import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class NotificacaoService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificacaoService() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future agendarNotificacao(String conteudo, DateTime horario) async {
    print('Agendar Notificação: $conteudo para às: $horario!!!');

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'tscontroleponto',
        'TS Controle de Ponto',
        'Agendamentos de Notificacoes do aplicativo TS Controle de Ponto');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    NotificationDetails platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        0,
        'Lembrete Marcação Ponto para às ${formatarHora.format(horario)}',
        conteudo,
        horario.subtract(Duration(minutes: 5)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true);

    await flutterLocalNotificationsPlugin.schedule(
        1,
        "Lembrete Marcação Ponto para às ${formatarHora.format(horario)}",
        "Foi adicionar lembre do ponto para às ${formatarHora.format(horario)}",
        DateTime.now().add(Duration(seconds: 15)),
        platformChannelSpecifics);
  }

  Future cancelarNotificacoes() async {
    print('Cancelando notificações!!!');
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> angendamentos() {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
