class EntradaSaidaModel {
  DateTime entrada;
  DateTime saida;

  int get tempoTrabalhado {
    int minutos = 0;

    if (entrada != null && saida != null) {
      minutos = saida.difference(entrada).inMinutes;
    }

    return minutos;
  }

  EntradaSaidaModel(this.entrada, {this.saida});

  @override
  String toString() {
    return 'Entrada $entrada - Saída $saida';
  }
}
