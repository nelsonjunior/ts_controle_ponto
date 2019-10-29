const USUARIO_LOGADO = 'usuario-logado';

class ParametroAppModel {
  String identParametro;
  String valorParametro;

  ParametroAppModel(this.identParametro, this.valorParametro);

  ParametroAppModel.fromMap(Map<String, dynamic> data) {
    if (data != null) {
      this.identParametro = data['identParametro'];
      this.valorParametro = data['valorParametro'];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'identParametro': this.identParametro,
      'valorParametro': this.valorParametro
    };
  }
}
