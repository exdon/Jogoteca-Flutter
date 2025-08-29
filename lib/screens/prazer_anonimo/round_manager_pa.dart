

import 'package:jogoteca/screens/prazer_anonimo/game/game_state_manager_pa.dart';

class RoundManagerPA {
  List<int> eligiblePlayerIndices = [];
  int eligiblePointer = 0;
  List<Map<String, dynamic>> roundResults = [];
  Set<String> playersAnsweredThisRound = {};
  bool showRoundResults = false;
  bool gameOver = false;
  bool _roundPrepared = false;

  bool get roundPrepared => _roundPrepared;
  bool get isRoundComplete => eligiblePointer + 1 >= eligiblePlayerIndices.length;
  bool get hasEligiblePlayers => eligiblePlayerIndices.isNotEmpty;

  // Prepara uma nova rodada
  void prepareNewRound(String partidaId, List<Map<String, dynamic>> players, List<Map<String, dynamic>> perguntas) {
    // Reset do super anônimo para nova rodada
    GameStateManagerPA.removeSuperAnonimoPlayer(partidaId);

    final localEligible = <int>[];
    for (var i = 0; i < players.length; i++) {
      final pid = players[i]['id'];
      if (GameStateManagerPA.hasAvailableQuestionForPlayer(partidaId, pid, perguntas, players)) {
        localEligible.add(i);
      }
    }

    eligiblePlayerIndices = localEligible;
    eligiblePointer = 0;
    roundResults.clear();
    playersAnsweredThisRound.clear();
    showRoundResults = false;
    gameOver = false;
    _roundPrepared = true;
  }

  // Inicia uma nova rodada
  void startNewRound() {
    _roundPrepared = false;
    roundResults.clear();
    playersAnsweredThisRound.clear();
    showRoundResults = false;
  }

  // Adiciona resultado da rodada
  void addRoundResult(Map<String, dynamic> result) {
    roundResults.add(result);
  }

  // Adiciona resultado do super anônimo
  void addSuperAnonimoResult(String pergunta, String resposta) {
    roundResults.add({
      'jogadorId': 'superanonimo',
      'jogadorNome': 'Super Anônimo',
      'pergunta': pergunta,
      'resposta': resposta,
    });
  }

  // Marca jogador como tendo respondido nesta rodada
  void markPlayerAnswered(String jogadorId) {
    playersAnsweredThisRound.add(jogadorId);
  }

  // Avança para o próximo jogador
  void moveToNextPlayer() {
    eligiblePointer++;
  }

  // Finaliza a rodada
  void finishRound() {
    showRoundResults = true;
  }

  // Verifica se o jogo acabou
  bool checkGameOver(String partidaId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    final allDone = GameStateManagerPA.areAllQuestionsAnsweredByEveryone(partidaId, perguntas, players);
    if (allDone) {
      gameOver = true;
    }
    return allDone;
  }

  // Reset completo do jogo
  void resetGame() {
    eligiblePlayerIndices.clear();
    eligiblePointer = 0;
    roundResults.clear();
    playersAnsweredThisRound.clear();
    showRoundResults = false;
    gameOver = false;
    _roundPrepared = false;
  }

  // Obtém o índice do próximo jogador elegível
  int? getNextEligiblePlayerIndex() {
    if (eligiblePointer < eligiblePlayerIndices.length) {
      return eligiblePlayerIndices[eligiblePointer];
    }
    return null;
  }

  // Obtém o índice atual do jogador elegível
  int? getCurrentEligiblePlayerIndex() {
    if (eligiblePointer > 0 && eligiblePointer <= eligiblePlayerIndices.length) {
      return eligiblePlayerIndices[eligiblePointer - 1];
    } else if (eligiblePlayerIndices.isNotEmpty) {
      return eligiblePlayerIndices[0];
    }
    return null;
  }

  List<String> getDrinkingPlayers(List<Map<String, dynamic>> roundResults) {
    List<String> playersWithNo = [];

    for (final result in roundResults) {
      final resposta = result['resposta'].toString().trim();
      // Verifica se a resposta é exatamente "Não" (case insensitive)
      if (resposta.toLowerCase() == 'não' || resposta.toLowerCase() == 'nao') {
        final jogadorNome = result['jogadorNome'];
        if (!playersWithNo.contains(jogadorNome)) {
          playersWithNo.add(jogadorNome);
        }
      }
    }

    // Embaralha a lista para randomizar
    playersWithNo.shuffle();

    return playersWithNo;
  }

  int countNoResponses(List<Map<String, dynamic>> roundResults) {
    int count = 0;
    for (final result in roundResults) {
      final resposta = result['resposta'].toString().trim();
      if (resposta.toLowerCase() == 'não' || resposta.toLowerCase() == 'nao') {
        count++;
      }
    }
    return count;
  }

  List<String> drawRandomPlayers(List<Map<String, dynamic>> allPlayers, int count) {
    List<String> playerNames = allPlayers.map((p) => p['nome'].toString()).toList();
    playerNames.shuffle();
    return playerNames.take(count).toList();
  }
}