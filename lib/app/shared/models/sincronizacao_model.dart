class SincronizacaoModel {
  int ident;
  String documentID;
  String document;
  String data;
  String acao;

  SincronizacaoModel(this.documentID, this.document, this.data, this.acao);

  SincronizacaoModel.fromMap(Map<String, dynamic> data) {
    this.ident = data['ident'];
    this.document = data['documentID'];
    this.document = data['document'];
    this.data = data['data'];
    this.acao = data['acao'];
  }

  Map<String, dynamic> toMap() {
    return {
      'ident': this.ident,
      'documentID': this.documentID,
      'document': this.document,
      'data': this.data,
      'acao': this.acao,
    };
  }

  @override
  String toString() {
    return 'SincronizacaoModel document:$document ident:$documentID acao:$acao';
  }
}
