import 'package:jogoteca/shared/shared_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoceMeConheceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String gameId = '1004';

  // ---------- PERGUNTAS ----------
  Future<List<Map<String, dynamic>>> loadQuestions() async {
    final response = await _supabase
        .from('vmc_questions')
        .select('*')
        .eq('game_id', gameId);

    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(response);
    questions.shuffle();
    return questions;
  }

  Future<List<Map<String, dynamic>>> loadAvailableQuestions(String partidaId, String playerId) async {
    // Busca perguntas que o jogador ainda não respondeu
    final answeredQuestions = await _supabase
        .from('vmc_player_answered_questions')
        .select('question_id')
        .eq('partida_id', partidaId)
        .eq('jogador_id', playerId);

    final answeredIds = answeredQuestions.map((q) => q['question_id']).toList();

    PostgrestFilterBuilder query = _supabase
        .from('vmc_questions')
        .select('*')
        .eq('game_id', gameId);

    if (answeredIds.isNotEmpty) {
      query = query.not('id', 'in', answeredIds);
    }

    final response = await query;
    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(response);
    questions.shuffle();
    return questions;
  }

  // ---------- JOGADORES ----------
  Future<List<Map<String, dynamic>>> loadPlayers(String partidaId) async {
    final response = await _supabase
        .from('vmc_players')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .order('indice');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addPlayer(String partidaId, String nome, int indice) async {
    await _supabase
        .from('vmc_players')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'nome': SharedFunctions.capitalize(nome),
      'indice': indice,
      'acertos': 0,
      'erros': 0,
    });
  }

  // ---------- RESPOSTA JOGADOR ----------
  Future<void> savePlayerAnswer({
    required String partidaId,
    required String questionId,
    required String playerId,
    required String answer,
    List<String>? opcoesFalsas,
    bool? isTrue,
  }) async {
    // Salva a resposta
    await _supabase
        .from('vmc_player_answer')
        .insert({
      'game_id': int.parse(gameId),
      'partida_id': partidaId,
      'question_id': questionId,
      'jogador_respondente_id': playerId,
      'resposta': answer,
      'is_true': isTrue,
      'opcoes_falsas': opcoesFalsas != null ? opcoesFalsas : [],
    });

    // Marca a pergunta como respondida pelo jogador (usando upsert para evitar duplicatas)
    await _supabase
        .from('vmc_player_answered_questions')
        .upsert({
      'partida_id': partidaId,
      'jogador_id': playerId,
      'question_id': questionId,
    }, onConflict: 'partida_id,jogador_id,question_id');
  }

  Future<Map<String, dynamic>?> getPlayerAnswer(String partidaId, String questionId, String playerId) async {
    final response = await _supabase
        .from('vmc_player_answer')
        .select('*')
        .eq('game_id', int.parse(gameId))
        .eq('partida_id', partidaId)
        .eq('question_id', questionId)
        .eq('jogador_respondente_id', playerId)
        .maybeSingle();

    return response;
  }

  Future<List<Map<String, dynamic>>> loadPlayerAnswer(String partidaId, String questionId, String playerId) async {
    final response = await _supabase
        .from('vmc_player_answer')
        .select('*')
        .eq('game_id', int.parse(gameId))
        .eq('partida_id', partidaId)
        .eq('question_id', questionId)
        .eq('jogador_respondente_id', playerId);

    return List<Map<String, dynamic>>.from(response);
  }

  @Deprecated('Use savePlayerAnswer instead')
  Future<void> addPlayerAnswer(String partidaId, String questionId, String playerId, String answer) async {
    await savePlayerAnswer(
      partidaId: partidaId,
      questionId: questionId,
      playerId: playerId,
      answer: answer,
    );
  }

  // ---------- VOTAÇÃO ----------
  Future<void> savePlayerVote({
    required String partidaId,
    required String questionId,
    required String jogadorRespondentId,
    required String jogadorVotanteId,
    required String voto,
    required bool acertou,
  }) async {
    await _supabase
        .from('vmc_player_votes')
        .insert({
      'partida_id': partidaId,
      'question_id': questionId,
      'jogador_respondente_id': jogadorRespondentId,
      'jogador_votante_id': jogadorVotanteId,
      'voto': voto,
      'acertou': acertou,
    });
  }

  Future<List<Map<String, dynamic>>> getVotesForQuestion(String partidaId, String questionId, String jogadorRespondentId) async {
    final response = await _supabase
        .from('vmc_player_votes')
        .select('*')
        .eq('partida_id', partidaId)
        .eq('question_id', questionId)
        .eq('jogador_respondente_id', jogadorRespondentId);

    return List<Map<String, dynamic>>.from(response);
  }

  // ---------- ESTATÍSTICAS DOS JOGADORES ----------
  Future<void> updatePlayerStats(String playerId, bool isCorrect) async {
    if (isCorrect) {
      await _supabase.rpc('increment_player_acertos', params: {'player_id': playerId});
    } else {
      await _supabase.rpc('increment_player_erros', params: {'player_id': playerId});
    }
  }

  Future<void> resetPlayerStats(String playerId) async {
    await _supabase
        .from('vmc_players')
        .update({
      'acertos': 0,
      'erros': 0,
    })
        .eq('id', playerId);
  }

  Future<void> resetAllPlayersStats(String partidaId) async {
    await _supabase
        .from('vmc_players')
        .update({
      'acertos': 0,
      'erros': 0,
    })
        .eq('partida_id', partidaId);
  }

  // ---------- NOVA RODADA ----------
  Future<void> clearAnsweredQuestions(String partidaId) async {
    await _supabase
        .from('vmc_player_answered_questions')
        .delete()
        .eq('partida_id', partidaId);
  }

  Future<void> clearVotes(String partidaId) async {
    await _supabase
        .from('vmc_player_votes')
        .delete()
        .eq('partida_id', partidaId);
  }

  Future<void> clearPlayerAnswers(String partidaId) async {
    await _supabase
        .from('vmc_player_answer')
        .delete()
        .eq('partida_id', partidaId);
  }

  // ---------- RESET COMPLETO DO JOGO ----------
  Future<void> resetCompleteGame(String partidaId) async {
    // Reset completo incluindo perguntas respondidas (para começar jogo do zero)
    await Future.wait([
      clearAnsweredQuestions(partidaId),
      clearVotes(partidaId),
      clearPlayerAnswers(partidaId),
      resetAllPlayersStats(partidaId),
    ]);
  }

  Future<void> resetGame(String partidaId) async {
    // Limpa apenas votos e respostas, mas MANTÉM as perguntas respondidas
    await Future.wait([
      clearVotes(partidaId),
      clearPlayerAnswers(partidaId),
      resetAllPlayersStats(partidaId),
    ]);
  }

  // ---------- VERIFICAÇÕES ----------
  Future<bool> hasPlayerAnsweredQuestion(String partidaId, String playerId, String questionId) async {
    final response = await _supabase
        .from('vmc_player_answered_questions')
        .select('id')
        .eq('partida_id', partidaId)
        .eq('jogador_id', playerId)
        .eq('question_id', questionId)
        .maybeSingle();

    return response != null;
  }

  Future<int> getAnsweredQuestionsCount(String partidaId, String playerId) async {
    final response = await _supabase
        .from('vmc_player_answered_questions')
        .select('id')
        .eq('partida_id', partidaId)
        .eq('jogador_id', playerId);

    return response.length;
  }

  Future<List<Map<String, dynamic>>> getPlayerRanking(String partidaId) async {
    final response = await _supabase
        .from('vmc_players')
        .select('*')
        .eq('partida_id', partidaId)
        .order('acertos', ascending: false)
        .order('erros', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<bool> hasAvailableQuestions(String partidaId) async {
    // Buscar todos os jogadores
    final players = await loadPlayers(partidaId);

    // Buscar todas as perguntas
    final allQuestions = await loadQuestions();

    // Verificar se existe pelo menos um jogador que não respondeu pelo menos uma pergunta
    for (var player in players) {
      for (var question in allQuestions) {
        bool hasAnswered = await hasPlayerAnsweredQuestion(partidaId, player['id'], question['id']);
        if (!hasAnswered) {
          return true; // Ainda há perguntas disponíveis
        }
      }
    }

    return false; // Não há mais perguntas disponíveis
  }
}