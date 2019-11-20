import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/target_position.dart';

void initTargets(
    List<TargetFocus> targets,
    GlobalKey keyBtnMarcarPonto,
    GlobalKey keyUltimaMarcacoes,
    GlobalKey keyTempoTrabalho,
    GlobalKey keyBtnConfiguracao) {
  targets.add(TargetFocus(
    identify: "Marcar Ponto",
    keyTarget: keyBtnMarcarPonto,
    contents: [
      ContentTarget(
          align: AlignContent.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Registrar Ponto ficou fácil",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Primeiro escolha sua conta do google para podermos salvar suas marcações na nuvem! Com um toque uma nova marcação é registrada automáticamente. Um toque longo você pode definir qual o horário da marcação.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ],
    shape: ShapeLightFocus.Circle,
  ));
  targets.add(TargetFocus(
    identify: "Ultimas Marcacoes",
    keyTarget: keyUltimaMarcacoes,
    contents: [
      ContentTarget(
          align: AlignContent.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Últimas marcações",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Suas últimas marcações serão mostradas nesse espaço, através delas será feito o cálculo do tempo trabalho.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ],
    shape: ShapeLightFocus.Circle,
  ));
  targets.add(TargetFocus(
    identify: "Tempo Trabalhado",
    keyTarget: keyTempoTrabalho,
    contents: [
      ContentTarget(
          align: AlignContent.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tempo Trabalho",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "O tempo trabalho será cálculado através da difereça das marcações de entrada e saída. Será mostrado tempo restando para o termino da sua jornada.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ],
    shape: ShapeLightFocus.Circle,
  ));
  targets.add(TargetFocus(
    identify: "Alterar Jornada",
    keyTarget: keyBtnConfiguracao,
    contents: [
      ContentTarget(
          align: AlignContent.top,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Alterar Jornada",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Você poderá alterar aquantidade de horas da sua jornada e tempo padrão de intervalo através do menu de configurações.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ],
    shape: ShapeLightFocus.Circle,
  ));
  targets.add(TargetFocus(
    identify: "Barra Navegacao",
    targetPosition: TargetPosition(Size(60.0, 60.0), Offset(20.0, 20.0)),
    contents: [
      ContentTarget(
          align: AlignContent.bottom,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Alterar Data",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Você consultar ou realizar as marcações em dias diferentes navegando para datas anteriores ou futuras.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ))
    ],
    shape: ShapeLightFocus.Circle,
  ));
}
