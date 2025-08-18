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

  // Super Anônimo - modo e campos
// mode: 'toResults' (pergunta+resposta vai para resultados) ou 'toPlayer' (enviar pergunta para jogador)
  String superAnonimoMode = 'toResults';
  final TextEditingController perguntaParaJogadorController = TextEditingController();
  String? selectedSuperAnonimoPlayer;

// Inbox Super Anônimo (perguntas recebidas que devem ser respondidas)
  final Map<String, TextEditingController> saInboxAnswerControllers = {};
  List<Map<String, dynamic>> _pendingSAQuestions = [];

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
      perguntaParaJogadorController.clear();
      selectedSuperAnonimoPlayer = null;
      superAnonimoMode = 'toResults';
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
    perguntaParaJogadorController.clear();
    selectedSuperAnonimoPlayer = null;
    superAnonimoActive = false;
    superAnonimoMode = 'toResults';
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
    perguntaParaJogadorController.clear();
    mensagemDirectController.clear();
    chooseNo = false;
    superAnonimoActive = false;
    superAnonimoMode = 'toResults';
    directActive = false;
    selectedDirectPlayer = null;
    selectedSuperAnonimoPlayer = null;
    _notifyStateChanged();
  }

  void dispose() {
    pinController.dispose();
    respostaController.dispose();
    perguntaSuperAnonimoController.dispose();
    respostaSuperAnonimoController.dispose();
    mensagemDirectController.dispose();
    perguntaParaJogadorController.dispose();
    for (var c in saInboxAnswerControllers.values) {
      c.dispose();
    }
  }

  void setSuperAnonimoMode(String mode) {
    superAnonimoMode = mode;
    _notifyStateChanged();
  }

  void setSelectedSuperAnonimoPlayer(String? value) {
    selectedSuperAnonimoPlayer = value;
    _notifyStateChanged();
  }

  TextEditingController getSAInboxAnswerController(String questionId) {
    return saInboxAnswerControllers.putIfAbsent(questionId, () => TextEditingController());
  }

  void setPendingSAQuestions(List<Map<String, dynamic>> questions) {
    _pendingSAQuestions = questions;
    // Garante controladores para todas
    for (final q in questions) {
      final qid = q['id'] as String;
      saInboxAnswerControllers.putIfAbsent(qid, () => TextEditingController());
    }
    _notifyStateChanged();
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

    // Super Anônimo ativo
    if (superAnonimoActive) {
      if (superAnonimoMode == 'toResults') {
        if (perguntaSuperAnonimoController.text.trim().isEmpty ||
            respostaSuperAnonimoController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Preencha pergunta e resposta do Super Anônimo (Resultados) ou desabilite a opção")),
          );
          return false;
        }
      } else if (superAnonimoMode == 'toPlayer') {
        if (selectedSuperAnonimoPlayer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Selecione um jogador para enviar a pergunta (Super Anônimo)")),
          );
          return false;
        }
        if (perguntaParaJogadorController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Digite a pergunta para o jogador selecionado (Super Anônimo)")),
          );
          return false;
        }
      }
    }

    // Direct ativo
    if (directActive) {
      if (selectedDirectPlayer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selecione um jogador para enviar a mensagem ou desabilite o Direct")),
        );
        return false;
      }
      if (mensagemDirectController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Digite a mensagem que será enviada para $selectedDirectPlayer ou desabilite o Direct")),
        );
        return false;
      }
    }

    // Perguntas de Super Anônimo recebidas (inbox) devem ser respondidas
    if (_pendingSAQuestions.isNotEmpty) {
      for (final q in _pendingSAQuestions) {
        final qid = q['id'] as String;
        final ctrl = saInboxAnswerControllers[qid];
        if (ctrl == null || ctrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Responda a(s) pergunta(s) do Super Anônimo recebida(s)")),
          );
          return false;
        }
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

  String getPerguntaParaJogador() => perguntaParaJogadorController.text;
  String? getSelectedSuperAnonimoPlayer() => selectedSuperAnonimoPlayer;

  Map<String, String> getSAInboxAnswers() {
    final map = <String, String>{};
    for (final entry in saInboxAnswerControllers.entries) {
      map[entry.key] = entry.value.text;
    }
    return map;
  }
}