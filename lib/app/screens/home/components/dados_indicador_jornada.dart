class DadosIndicadorJornada {
  DateTime horasTrabalhadas;
  double percentualJornadaInicial;
  double percentualJornada;
  String descIndicador1;
  String descIndicador2;

  DadosIndicadorJornada(this.horasTrabalhadas, this.percentualJornadaInicial,
      this.percentualJornada, this.descIndicador1, this.descIndicador2);

  DadosIndicadorJornada.empty() {
    var dataAtual = DateTime.now();

    this.horasTrabalhadas =
        DateTime(dataAtual.year, dataAtual.month, dataAtual.day, 0, 0);
    this.percentualJornadaInicial = 0.0;
    this.percentualJornada = 0.0;
    this.descIndicador1 = '';
    this.descIndicador2 = '';
  }
}
