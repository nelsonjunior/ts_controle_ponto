import 'package:flutter/material.dart';
import 'package:ts_controle_ponto/app/screens/home/home_module.dart';
import 'package:ts_controle_ponto/app/screens/home/ponto_bloc.dart';
import 'package:ts_controle_ponto/app/shared/models/ponto_model.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class IndicadorJornada extends StatefulWidget {
  final PontoModel pontoModel;

  IndicadorJornada(this.pontoModel);

  @override
  _IndicadorJornadaState createState() => _IndicadorJornadaState();
}

class _IndicadorJornadaState extends State<IndicadorJornada>
    with SingleTickerProviderStateMixin {
  final Duration fadeInDuration = Duration(milliseconds: 500);
  final Duration fillDuration = Duration(seconds: 2);

  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;

  double progressDegress = 0.0;
  double lastGoalCompleted = 0.0;

  PontoModel pontoAtual;

  @override
  void initState() {
    super.initState();

    pontoAtual = widget.pontoModel;
    lastGoalCompleted = widget.pontoModel.percentualJornada.toDouble() / 100;

    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _progressAnimation = Tween(begin: lastGoalCompleted * 360.0, end: 360.0)
        .animate(CurvedAnimation(
            parent: _radialProgressAnimationController,
            curve: Curves.easeInOutSine))
          ..addListener(() {
            setState(() {
              progressDegress = lastGoalCompleted * _progressAnimation.value;
            });
          });

    _radialProgressAnimationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _radialProgressAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_radialProgressAnimationController.isCompleted) {
      double percJornadaAtual =
          widget.pontoModel.percentualJornada.toDouble() / 100;

      bool iniciarAnimacao = false;
      if (pontoAtual.ident != widget.pontoModel.ident) {
        progressDegress = 0.0;
        lastGoalCompleted = 0.0;
        pontoAtual = widget.pontoModel;
        iniciarAnimacao = true;
      } else if (lastGoalCompleted != percJornadaAtual) {
        iniciarAnimacao = true;
      }

      if (iniciarAnimacao) {
        _progressAnimation = Tween(begin: lastGoalCompleted * 360.0, end: 360.0)
            .animate(CurvedAnimation(
                parent: _radialProgressAnimationController,
                curve: Curves.easeInOut))
              ..addStatusListener((AnimationStatus status) {
                if (status == AnimationStatus.completed) {
                  lastGoalCompleted = percJornadaAtual;
                }
              })
              ..addListener(() {
                setState(() {
                  progressDegress = percJornadaAtual * _progressAnimation.value;
                });
              });

        _radialProgressAnimationController.reset();
        _radialProgressAnimationController.forward();
      }
    }

    return CustomPaint(
      child: Container(
        height: 200.0,
        width: 200.0,
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: fadeInDuration,
          child: StreamBuilder<PontoModel>(
              stream: HomeModule.to.bloc<PontoBloc>().pontoStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    HomeModule.to.bloc<PontoBloc>().loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Text(
                        'HORAS',
                        style: TextStyle(fontSize: 24.0, letterSpacing: 1.5),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Container(
                        height: 5.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                            color: corPrincipal1,
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0))),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        formatarHora.format(snapshot.data.horasTrabalhadas),
                        style: TextStyle(
                            fontSize: 40.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Flexible(
                        child: Text(
                          snapshot.data.jornadaCompleta
                              ? 'Jornada ${snapshot.data.duracaoJornada.hour.toString().padLeft(2, "0")}:${snapshot.data.duracaoJornada.minute.toString().padLeft(2, "0")}/dia\nconcluída'
                              : 'Saída estimada \n às ${formatarHora.format(snapshot.data.saidaEstimada)}',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.blue,
                              letterSpacing: 1.5,
                              height: 1.3),
                        ),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
      painter: RadialPainter(progressDegress),
    );
  }
}

class RadialPainter extends CustomPainter {
  double progressInDegrees;

  RadialPainter(this.progressInDegrees);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);

    if (progressInDegrees > 360) {
      Paint extraProgressPaint = Paint()
        ..shader = LinearGradient(colors: [
          Colors.redAccent,
          Colors.amber,
          Colors.orangeAccent
        ]).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0;

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: size.width / 1.85),
          math.radians(-90),
          math.radians(progressInDegrees - 360),
          false,
          extraProgressPaint);
    }

    Paint progressPaint = Paint()
      ..shader = LinearGradient(
              colors: [Colors.blue, Colors.deepPurple, Colors.purpleAccent])
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(progressInDegrees),
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
