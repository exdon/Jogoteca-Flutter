class GameStateManagerPA {
  static final Map<String, Map<String, Set<String>>> _gameAnsweredQuestions = {};
  static final Map<String, String> _gameSuperAnonimoPlayer = {};
  // NOVO CAMPO APENAS PARA COMBINAÇÕES DO IA ANÔNIMO
  static final Map<String, Set<String>> _gameUsedIAnonimoCombinations = {};

  // Getters para acesso aos mapas
  static Map<String, Map<String, Set<String>>> get gameAnsweredQuestions => _gameAnsweredQuestions;
  static Map<String, String> get gameSuperAnonimoPlayer => _gameSuperAnonimoPlayer;

  // Inicializa o jogo se não existir
  static void initializeGame(String partidaId) {
    if (!_gameAnsweredQuestions.containsKey(partidaId)) {
      _gameAnsweredQuestions[partidaId] = {};
    }
  }

  // Remove dados do jogo
  static void removeGame(String partidaId) {
    _gameAnsweredQuestions.remove(partidaId);
    _gameSuperAnonimoPlayer.remove(partidaId);
    // REMOVE TAMBÉM OS DADOS DO IA ANÔNIMO
    _gameUsedIAnonimoCombinations.remove(partidaId);
  }

  // Marca pergunta como respondida por um jogador
  static void markQuestionAnswered(String partidaId, String jogadorId, String questionId) {
    _gameAnsweredQuestions.putIfAbsent(partidaId, () => {});
    _gameAnsweredQuestions[partidaId]!.putIfAbsent(jogadorId, () => <String>{});
    _gameAnsweredQuestions[partidaId]![jogadorId]!.add(questionId);
  }

  // Verifica se uma pergunta foi respondida por todos
  static bool isQuestionAnsweredByEveryone(String partidaId, String perguntaId, List<Map<String, dynamic>> players) {
    for (final player in players) {
      final answered = _gameAnsweredQuestions[partidaId]?[player['id']] ?? {};
      if (!answered.contains(perguntaId)) {
        return false;
      }
    }
    return true;
  }

  // Verifica se todas as perguntas foram respondidas por todos
  static bool areAllQuestionsAnsweredByEveryone(String partidaId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    for (final pergunta in perguntas) {
      if (!isQuestionAnsweredByEveryone(partidaId, pergunta['id'], players)) {
        return false;
      }
    }
    return true;
  }

  // Define o super anônimo da rodada
  static bool setSuperAnonimoPlayer(String partidaId, String jogadorId) {
    if (!_gameSuperAnonimoPlayer.containsKey(partidaId)) {
      _gameSuperAnonimoPlayer[partidaId] = jogadorId;
      return true;
    }
    return false;
  }

  // Remove o super anônimo da rodada
  static void removeSuperAnonimoPlayer(String partidaId) {
    _gameSuperAnonimoPlayer.remove(partidaId);
  }

  // Verifica se um jogador tem perguntas disponíveis
  static bool hasAvailableQuestionForPlayer(String partidaId, String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    final partidaAnswers = _gameAnsweredQuestions[partidaId] ?? {};
    final answeredByThisPlayer = partidaAnswers[jogadorId] ?? {};

    for (final p in perguntas) {
      final pid = p['id'];
      if (answeredByThisPlayer.contains(pid)) continue;
      if (isQuestionAnsweredByEveryone(partidaId, pid, players)) continue;
      return true;
    }
    return false;
  }

  // Busca uma nova pergunta para o jogador
  static Map<String, String>? getNewQuestionForPlayer(String partidaId, String jogadorId, List<Map<String, dynamic>> perguntas, List<Map<String, dynamic>> players) {
    final partidaAnswers = _gameAnsweredQuestions[partidaId] ?? {};
    final answered = partidaAnswers[jogadorId] ?? {};

    final questionsDisponiveis = perguntas.where((p) {
      final pid = p['id'];
      if (answered.contains(pid)) return false;
      if (isQuestionAnsweredByEveryone(partidaId, pid, players)) return false;
      return true;
    }).toList();

    if (questionsDisponiveis.isEmpty) {
      return null;
    }

    questionsDisponiveis.shuffle();
    return {
      'id': questionsDisponiveis.first['id'],
      'pergunta': questionsDisponiveis.first['pergunta']
    };
  }

  // Métodos para gerenciar IA Anônimo
  static String _createCombinationKey(String pergunta, String resposta) {
    return '$pergunta|||$resposta';
  }

  static Map<String, String>? getIAnonimoQuestionAnswer(String partidaId, List<Map<String, dynamic>> perguntas) {
    final usedCombinations = _gameUsedIAnonimoCombinations[partidaId] ?? <String>{};

    // Embaralha as perguntas para aleatoriedade
    List<Map<String, dynamic>> shuffledQuestions = List.from(perguntas);
    shuffledQuestions.shuffle();

    for (final perguntaData in shuffledQuestions) {
      final pergunta = perguntaData['pergunta'];
      final respostaChatgpt = perguntaData['resposta_chatgpt'];

      // Decide aleatoriamente se usa a resposta do ChatGPT ou "Não"
      final useNao = [true, false]..shuffle();
      final resposta = useNao.first ? 'Não' : respostaChatgpt;

      final combinationKey = _createCombinationKey(pergunta, resposta);

      // Verifica se esta combinação já foi usada
      if (!usedCombinations.contains(combinationKey)) {
        // Marca como usada
        _gameUsedIAnonimoCombinations.putIfAbsent(partidaId, () => <String>{}).add(combinationKey);

        return {
          'pergunta': pergunta,
          'resposta': resposta,
        };
      }
    }

    return null; // Não há mais combinações disponíveis
  }
}