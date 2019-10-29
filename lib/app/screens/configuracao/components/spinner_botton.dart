import 'package:flutter/material.dart';
import 'package:ts_controle_ponto/app/shared/themes/colors.dart';

class SpinnerBotton extends StatelessWidget {
  final GestureTapCallback diminuirOnTap;
  final GestureTapCallback aumentarOnTap;
  final TimeOfDay tempo;

  SpinnerBotton(
      {@required this.tempo,
      @required this.diminuirOnTap,
      @required this.aumentarOnTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: diminuirOnTap,
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: corPrincipal1,
              borderRadius: new BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text(
              "-",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: 110.0,
          child: Text(
            "${tempo.hour.toString().padLeft(2, "0")}:${tempo.minute.toString().padLeft(2, "0")}",
            style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
          ),
        ),
        InkWell(
          onTap: aumentarOnTap,
          child: Container(
            height: 50,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: corPrincipal1,
              borderRadius: new BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Text(
              "+",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }
}
