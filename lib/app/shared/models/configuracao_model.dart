import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConfiguracaoModel {
  String identUsuario;
  TimeOfDay jornadaPadrao;
  TimeOfDay intervalorPadrao;

  ConfiguracaoModel(
      this.identUsuario, this.jornadaPadrao, this.intervalorPadrao);

  ConfiguracaoModel.empty() {
    this.jornadaPadrao = TimeOfDay(hour: 8, minute: 0);
    this.intervalorPadrao = TimeOfDay(hour: 1, minute: 0);
  }

  ConfiguracaoModel.fromDocument(DocumentSnapshot document) {
    if (document.data != null) {
      this.identUsuario = document.data['identUsuario'];
      this.jornadaPadrao = TimeOfDay(
          hour: document.data['jornadaPadraoHoras'],
          minute: document.data['jornadaPadraoMintos']);
      this.intervalorPadrao = TimeOfDay(
          hour: document.data['intervalorPadraoHoras'],
          minute: document.data['intervalorPadraoMinutos']);
    } else {
      this.jornadaPadrao = TimeOfDay(hour: 8, minute: 0);
      this.intervalorPadrao = TimeOfDay(hour: 1, minute: 0);
    }
  }

  ConfiguracaoModel.fromMap(Map<String, dynamic> data) {
    if (data != null) {
      this.identUsuario = data['identUsuario'];
      this.jornadaPadrao = TimeOfDay(
          hour: data['jornadaPadraoHoras'],
          minute: data['jornadaPadraoMintos']);
      this.intervalorPadrao = TimeOfDay(
          hour: data['intervalorPadraoHoras'],
          minute: data['intervalorPadraoMinutos']);
    } else {
      this.jornadaPadrao = TimeOfDay(hour: 8, minute: 0);
      this.intervalorPadrao = TimeOfDay(hour: 1, minute: 0);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'identUsuario': this.identUsuario,
      'jornadaPadraoHoras': this.jornadaPadrao.hour,
      'jornadaPadraoMintos': this.jornadaPadrao.minute,
      'intervalorPadraoHoras': this.intervalorPadrao.hour,
      'intervalorPadraoMinutos': this.intervalorPadrao.minute
    };
  }
}
