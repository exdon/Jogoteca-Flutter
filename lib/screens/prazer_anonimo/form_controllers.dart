import 'package:flutter/material.dart';

class FormControllers {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController respostaController = TextEditingController();
  final TextEditingController perguntaSuperAnonimoController = TextEditingController();
  final TextEditingController respostaSuperAnonimoController = TextEditingController();
  final TextEditingController mensagemDirectController = TextEditingController();

  bool chooseNo = false;
  bool superAnonimoActive = false;
  bool directActive = false;
  String? selectedDirectPlayer;

  // Callback para notificar mudanças de estado
  VoidCallback? _onStateChanged;

  void setStateChangeCallback(VoidCallback callback) {
    _onStateChanged = callback;
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  void setChooseNo(bool value) {
    chooseNo = value;
    _notifyStateChanged();
  }

  void setSuperAnonimoActive(bool value) {
    superAnonimoActive = value;
    if (!value) {
      perguntaSuperAnonimoController.clear();
      respostaSuperAnonimoController.clear();
    }
    _notifyStateChanged();
  }

  void setDirectActive(bool value) {
    directActive = value;
    if (!value) {
      mensagemDirectController.clear();
      selectedDirectPlayer = null;
    }
    _notifyStateChanged();
  }

  void setSelectedDirectPlayer(String? value) {
    selectedDirectPlayer = value;
    _notifyStateChanged();
  }

  void resetSuperAnonimoFields() {
    perguntaSuperAnonimoController.clear();
    respostaSuperAnonimoController.clear();
    superAnonimoActive = false;
    _notifyStateChanged();
  }

  void resetDirectFields() {
    mensagemDirectController.clear();
    selectedDirectPlayer = null;
    directActive = false;
    _notifyStateChanged();
  }

  void resetAllFields() {
    pinController.clear();
    respostaController.clear();
    perguntaSuperAnonimoController.clear();
    respostaSuperAnonimoController.clear();
    mensagemDirectController.clear();
    chooseNo = false;
    superAnonimoActive = false;
    directActive = false;
    selectedDirectPlayer = null;
    _notifyStateChanged();
  }

  void dispose() {
    pinController.dispose();
    respostaController.dispose();
    perguntaSuperAnonimoController.dispose();
    respostaSuperAnonimoController.dispose();
    mensagemDirectController.dispose();
  }

  bool validateFields(BuildContext context) {
    // Verifica se tem resposta ou escolheu "Não"
    bool hasAnswer = respostaController.text.trim().isNotEmpty || chooseNo;
    if (!hasAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite uma resposta ou selecione 'Não'")),
      );
      return false;
    }

    // Se super anônimo está ativo, verifica os campos
    if (superAnonimoActive) {
      if (perguntaSuperAnonimoController.text.trim().isEmpty ||
          respostaSuperAnonimoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos do Super Anônimo ou desabilite a opção")),
        );
        return false;
      }
    }

    // Se direct está ativo, verifica os campos
    if (directActive) {
      if (selectedDirectPlayer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione um jogador para enviar a mensagem ou desabilite o Direct")),
        );
        return false;
      }
      if (selectedDirectPlayer != null && mensagemDirectController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Digite a mensagem que será enviada para $selectedDirectPlayer ou desabilite o Direct")),
        );
        return false;
      }
    }

    return true;
  }

  String getAnswer() {
    return chooseNo ? "Não" : respostaController.text;
  }

  String getPerguntaSuperAnonimo() {
    return perguntaSuperAnonimoController.text;
  }

  String getSuperAnonimoAnswer() {
    return respostaSuperAnonimoController.text;
  }

  String getMensagemDirect() {
    return mensagemDirectController.text;
  }
}