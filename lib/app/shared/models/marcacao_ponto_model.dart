import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ts_controle_ponto/app/shared/utils/data_utils.dart';

class MarcacaoPontoModel {
  String ident;
  String identUsuario;
  String identPonto;
  String descricao;
  String tipo;
  DateTime marcacao;

  MarcacaoPontoModel(this.identUsuario, this.identPonto, this.marcacao);

  MarcacaoPontoModel.fromDocument(DocumentSnapshot document) {
    this.ident = document.documentID;
    this.identUsuario = document.data['identUsuario'];
    this.identPonto = document.data['identPonto'];
    this.descricao = document.data['descricao'];
    this.tipo = document.data['tipo'];
    this.marcacao = formatarHora.parse(document.data['marcacao']);
  }

  Map<String, dynamic> toMap() {
    return {
      'identUsuario': this.identUsuario,
      'identPonto': this.identPonto,
      'descricao': this.descricao,
      'tipo': this.tipo,
      'marcacao': formatarHora.format(marcacao)
    };
  }
}
