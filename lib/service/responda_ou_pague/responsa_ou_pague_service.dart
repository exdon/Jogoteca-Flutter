import 'package:jogoteca/shared/shared_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResponsaOuPagueService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String gameId = '1002';

  // ---------- PERGUNTAS ----------
  Future<Map<String, dynamic>> loadQuestion(String classificacao, [List<String> answeredQuestions = const [], List<String> recentQuestions = const []]) async {
    String targetClassificacao = classificacao;

    if (classificacao == 'aleatorio') {
      final opcoes = ['moderado', 'picante'];
      opcoes.shuffle();
      targetClassificacao = opcoes.first;
    }

    var query = _supabase
        .from('rp_questions')
        .select('*')
        .eq('game_id', gameId)
        .eq('classificacao', targetClassificacao);

    // Filtra perguntas já respondidas pelo jogador
    if (answeredQuestions.isNotEmpty) {
      query = query.not('id', 'in', '(${answeredQuestions.join(',')})');
    }

    // Filtra perguntas recentes (menor prioridade)
    if (recentQuestions.isNotEmpty) {
      query = query.not('id', 'in', '(${recentQuestions.join(',')})');
    }

    final response = await query;

    if (response.isEmpty) {
      // Se não há perguntas disponíveis, tenta sem filtrar as recentes
      if (recentQuestions.isNotEmpty) {
        var fallbackQuery = _supabase
            .from('rp_questions')
            .select('*')
            .eq('game_id', gameId)
            .eq('classificacao', targetClassificacao);

        if (answeredQuestions.isNotEmpty) {
          fallbackQuery = fallbackQuery.not('id', 'in', '(${answeredQuestions.join(',')})');
        }

        final fallbackResponse = await fallbackQuery;
        if (fallbackResponse.isNotEmpty) {
          fallbackResponse.shuffle();
          return fallbackResponse.first;
        }
      }

      throw Exception('Nenhuma pergunta disponível para a classificação $targetClassificacao');
    }

    // Randomiza e retorna
    response.shuffle();
    return response.first;
  }

  // ---------- DESAFIOS ----------
  Future<Map<String, dynamic>> loadChallenge(String classificacao, [List<String> completedChallenges = const [], List<String> recentChallenges = const []]) async {
    String targetClassificacao = classificacao;

    if (classificacao == 'aleatorio') {
      final opcoes = ['moderado', 'picante'];
      opcoes.shuffle();
      targetClassificacao = opcoes.first;
    }

    var query = _supabase
        .from('rp_challenges')
        .select('*')
        .eq('game_id', gameId)
        .eq('classificacao', targetClassificacao);

    // Filtra desafios já completados pelo jogador
    if (completedChallenges.isNotEmpty) {
      query = query.not('id', 'in', '(${completedChallenges.join(',')})');
    }

    // Filtra desafios recentes
    if (recentChallenges.isNotEmpty) {
      query = query.not('id', 'in', '(${recentChallenges.join(',')})');
    }

    final response = await query;

    if (response.isEmpty) {
      // Fallback sem filtrar recentes
      if (recentChallenges.isNotEmpty) {
        var fallbackQuery = _supabase
            .from('rp_challenges')
            .select('*')
            .eq('game_id', gameId)
            .eq('classificacao', targetClassificacao);

        if (completedChallenges.isNotEmpty) {
          fallbackQuery = fallbackQuery.not('id', 'in', '(${completedChallenges.join(',')})');
        }

        final fallbackResponse = await fallbackQuery;
        if (fallbackResponse.isNotEmpty) {
          fallbackResponse.shuffle();
          return fallbackResponse.first;
        }
      }

      throw Exception('Nenhum desafio disponível para a classificação $targetClassificacao');
    }

    response.shuffle();
    return response.first;
  }

  // ---------- JOGADORES ----------
  Future<List<Map<String, dynamic>>> loadPlayers(String partidaId) async {
    final response = await _supabase
        .from('rp_players')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> loadPlayerData(String partidaId, String jogadorId) async {
    try {
      final response = await _supabase
          .from('rp_players')
          .select('*')
          .eq('id', jogadorId)
          .eq('game_id', gameId)
          .eq('partida_id', partidaId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> addPlayer(String partidaId, String nome) async {
    await _supabase
        .from('rp_players')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'nome': SharedFunctions.capitalize(nome),
      'vidas': 5,
    });
  }

  Future<void> updatePlayerData(String partidaId, String jogadorId, int vidas) async {
    await _supabase
        .from('rp_players')
        .update({'vidas': vidas})
        .eq('id', jogadorId);
  }

  Future<void> removePlayer(String partidaId, String jogadorId) async {
    await _supabase
        .from('rp_players')
        .delete()
        .eq('id', jogadorId);
  }

  // ---------- PARTIDA ----------
  Future<void> deletePartida(String partidaId) async {
    await _supabase
        .from('rp_partidas')
        .delete()
        .eq('id', partidaId)
        .eq('game_id', gameId);
  }
}