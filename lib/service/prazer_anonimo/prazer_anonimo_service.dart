import 'package:jogoteca/shared/shared_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrazerAnonimoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String gameId = '1001';

  // ---------- PERGUNTAS ----------
  Future<List<Map<String, dynamic>>> loadQuestions() async {
    final response = await _supabase
        .from('pa_questions')
        .select('*')
        .eq('game_id', gameId);

    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(response);
    questions.shuffle();
    return questions;
  }

  // ---------- JOGADORES ----------
  Future<List<Map<String, dynamic>>> loadPlayers(String partidaId) async {
    final response = await _supabase
        .from('pa_players')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .order('indice');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addPlayer(String partidaId, String nome, int pin, int indice) async {
    await _supabase
        .from('pa_players')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'nome': SharedFunctions.capitalize(nome),
      'pin': pin,
      'indice': indice,
    });
  }

  Future<void> addPlayerData(
      String partidaId,
      String jogadorId,
      String pergunta,
      String resposta,
      bool superAnonimo,
      String? perguntaSuperAnonimo,
      String? respostaSuperAnonimo,
      String? detalhesSuperAnonimo
      ) async {
    final respostaData = {
      'game_id': gameId,
      'partida_id': partidaId,
      'jogador_id': jogadorId,
      'pergunta': pergunta,
      'resposta': resposta,
      'super_anonimo': superAnonimo,
      'created_at': DateTime.now().toIso8601String(),
    };

    if (superAnonimo && perguntaSuperAnonimo != null && respostaSuperAnonimo != null) {
      respostaData['pergunta_super_anonimo'] = perguntaSuperAnonimo;
      respostaData['resposta_super_anonimo'] = respostaSuperAnonimo;
    }

    if (superAnonimo && detalhesSuperAnonimo != null) {
      respostaData['detalhes_super_anonimo'] = detalhesSuperAnonimo;
    }

    await _supabase
        .from('pa_player_responses')
        .insert(respostaData);
  }

  Future<List<Map<String, dynamic>>> loadResultsOptimized(String partidaId) async {
    // Carrega jogadores
    final playersResponse = await _supabase
        .from('pa_players')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId);

    final players = List<Map<String, dynamic>>.from(playersResponse);

    // Carrega respostas dos jogadores
    final responsesResponse = await _supabase
        .from('pa_player_responses')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .order('created_at');

    final responses = List<Map<String, dynamic>>.from(responsesResponse);

    // Carrega perguntas SA respondidas
    final saQuestionsResponse = await _supabase
        .from('pa_super_anonimo_questions')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('respondida', true);

    final saQuestions = List<Map<String, dynamic>>.from(saQuestionsResponse);

    // Carrega desafios SA
    final challengesResponse = await _supabase
        .from('pa_super_anonimo_challenges')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId);

    final challenges = List<Map<String, dynamic>>.from(challengesResponse);

    List<Map<String, dynamic>> todasRespostas = [];

    // Processa respostas normais e super anonimo
    for (var response in responses) {
      final jogador = players.firstWhere((p) => p['id'] == response['jogador_id']);

      // Adiciona resposta normal
      todasRespostas.add({
        'jogadorId': response['jogador_id'],
        'jogadorNome': jogador['nome'],
        'pergunta': response['pergunta'] ?? '',
        'resposta': response['resposta'] ?? '',
        'tipo': 'normal',
      });

      // Se for super anônimo modo 'resultados'
      if (response['super_anonimo'] == true &&
          response['pergunta_super_anonimo'] != null &&
          response['resposta_super_anonimo'] != null &&
          response['detalhes_super_anonimo'] == null &&
          response['pergunta_super_anonimo'].toString().trim().isNotEmpty &&
          response['resposta_super_anonimo'].toString().trim().isNotEmpty) {
        todasRespostas.add({
          'jogadorId': 'superanonimo',
          'jogadorNome': 'Super Anônimo',
          'pergunta': response['pergunta_super_anonimo'] ?? '',
          'resposta': response['resposta_super_anonimo'] ?? '',
          'tipo': 'superanonimo',
        });
      }
    }

    // Processa perguntas SA respondidas
    for (var saQuestion in saQuestions) {
      final jogador = players.firstWhere((p) => p['id'] == saQuestion['destinatario_id']);
      todasRespostas.add({
        'jogadorId': saQuestion['destinatario_id'],
        'jogadorNome': jogador['nome'],
        'pergunta': saQuestion['pergunta'] ?? '',
        'resposta': saQuestion['resposta'] ?? '',
        'tipo': 'sa_question_answered',
      });
    }

    // Processa desafios SA
    for (var challenge in challenges) {
      final jogador = players.firstWhere((p) => p['id'] == challenge['destinatario_id']);
      todasRespostas.add({
        'jogadorId': 'desafio',
        'jogadorNome': 'Desafio para: ${jogador['nome']}',
        'pergunta': '',
        'resposta': challenge['desafio'] ?? '',
        'tipo': 'challenge',
        'isChallenge': true,
      });
    }

    todasRespostas.shuffle();
    return todasRespostas;
  }

  Future<void> sendDirectMessage(
      String partidaId,
      String remetenteId,
      String destinatarioId,
      String mensagem,
      String remetenteNome
      ) async {
    await _supabase
        .from('pa_direct_messages')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'remetente_id': remetenteId,
      'destinatario_id': destinatarioId,
      'remetente_nome': remetenteNome,
      'mensagem': mensagem,
      'lida': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadDirectMessages(String partidaId, String jogadorId) async {
    final response = await _supabase
        .from('pa_direct_messages')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('destinatario_id', jogadorId)
        .eq('lida', false)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markMessageAsRead(String partidaId, String jogadorId, String messageId) async {
    await _supabase
        .from('pa_direct_messages')
        .update({'lida': true})
        .eq('id', messageId);
  }

  Future<void> markAllMessagesAsRead(String partidaId, String jogadorId) async {
    await _supabase
        .from('pa_direct_messages')
        .update({'lida': true})
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('destinatario_id', jogadorId)
        .eq('lida', false);
  }

  // ---------- SUPER ANÔNIMO (PERGUNTAS PARA JOGADORES) ----------
  Future<void> sendSuperAnonimoQuestion(
      String partidaId,
      String remetenteId,
      String destinatarioId,
      String pergunta,
      String remetenteNome,
      ) async {
    await _supabase
        .from('pa_super_anonimo_questions')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'remetente_id': remetenteId,
      'destinatario_id': destinatarioId,
      'remetente_nome': remetenteNome,
      'pergunta': pergunta,
      'resposta': '',
      'respondida': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadSuperAnonimoQuestions(String partidaId, String jogadorId) async {
    final response = await _supabase
        .from('pa_super_anonimo_questions')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('destinatario_id', jogadorId)
        .eq('respondida', false)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> answerSuperAnonimoQuestion(
      String partidaId,
      String jogadorId,
      String questionId,
      String resposta,
      ) async {
    await _supabase
        .from('pa_super_anonimo_questions')
        .update({
      'resposta': resposta,
      'respondida': true,
    })
        .eq('id', questionId);
  }

  Future<void> sendSuperAnonimoChallenge(
      String partidaId,
      String remetenteId,
      String destinatarioId,
      String desafio,
      String remetenteNome,
      String desafioPara,
      ) async {
    await _supabase
        .from('pa_super_anonimo_challenges')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'remetente_id': remetenteId,
      'destinatario_id': destinatarioId,
      'remetente_nome': remetenteNome,
      'desafio': desafio,
      'challenge_to': desafioPara,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadSuperAnonimoChallenges(String partidaId, String jogadorId) async {
    final response = await _supabase
        .from('pa_super_anonimo_challenges')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('destinatario_id', jogadorId)
        // .eq('respondida', false)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markChallengeAsCompleted(
      String partidaId,
      String jogadorId,
      String challengeId,
      ) async {
    await _supabase
        .from('pa_super_anonimo_challenges')
        .update({'respondida': true})
        .eq('id', challengeId);
  }

  Future<void> removePlayer(String partidaId, String jogadorId) async {
    await _supabase
        .from('pa_players')
        .delete()
        .eq('id', jogadorId);
  }

  // ---------- SOLICITAÇÕES DE ENTRADA ----------
  // Future<String> sendJoinRequest(String partidaId, String nomeJogador, int pin) async {
  //   final response = await _supabase
  //       .from('join_requests')
  //       .insert({
  //     'game_id': gameId,
  //     'partida_id': partidaId,
  //     'nome_jogador': nomeJogador,
  //     'pin': pin,
  //     'status': 'pending',
  //     'created_at': DateTime.now().toIso8601String(),
  //   })
  //       .select('id')
  //       .single();
  //
  //   return response['id'];
  // }

  // Stream<List<Map<String, dynamic>>> getJoinRequestsStream(String partidaId) {
  //   return _supabase
  //       .from('join_requests')
  //       .stream(primaryKey: ['id'])
  //       .eq('game_id', gameId)
  //       .eq('partida_id', partidaId)
  //       .eq('status', 'pending')
  //       .map((data) => List<Map<String, dynamic>>.from(data));
  // }

  Future<bool> partidaExists(String partidaId) async {
    try {
      await _supabase
          .from('pa_partidas')
          .select('id')
          .eq('id', partidaId)
          .eq('game_id', gameId)
          .single();
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<Map<String, dynamic>?> listenJoinRequestStatus(String partidaId, String requestId) {
    return _supabase
        .from('pa_join_requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  Future<void> respondToJoinRequest(String partidaId, String requestId, bool approved) async {
    await _supabase
        .from('pa_join_requests')
        .update({
      'status': approved ? 'approved' : 'rejected',
      'responded_at': DateTime.now().toIso8601String(),
    })
        .eq('id', requestId);
  }

  Future<void> cancelJoinRequest(String partidaId, String nomeJogador) async {
    await _supabase
        .from('pa_join_requests')
        .update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
    })
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .eq('nome_jogador', nomeJogador)
        .eq('status', 'pending');
  }

  Future<void> cancelJoinRequestById(String partidaId, String requestId) async {
    await _supabase
        .from('pa_join_requests')
        .update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
    })
        .eq('id', requestId);
  }

  // Stream<String?> getJoinRequestStatus(String partidaId, String nomeJogador) {
  //   return _supabase
  //       .from('join_requests')
  //       .stream(primaryKey: ['id'])
  //       .eq('game_id', gameId)
  //       .eq('partida_id', partidaId)
  //       .eq('nome_jogador', nomeJogador)
  //       .order('created_at', ascending: false)
  //       .limit(1)
  //       .map((data) => data.isNotEmpty ? data.first['status'] as String? : null);
  // }

  // Stream<List<Map<String, dynamic>>> playersStream(String partidaId) {
  //   return _supabase
  //       .from('players')
  //       .stream(primaryKey: ['id'])
  //       .eq('game_id', gameId)
  //       .eq('partida_id', partidaId)
  //       .order('indice')
  //       .map((data) => List<Map<String, dynamic>>.from(data));
  // }

  Future<void> setTurnIndex(String partidaId, int turnIndex) async {
    await _supabase
        .from('pa_partidas')
        .upsert({
      'id': partidaId,
      'game_id': gameId,
      'turn_index': turnIndex,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Stream<int?> listenTurnIndex(String partidaId) {
  //   return _supabase
  //       .from('partidas')
  //       .stream(primaryKey: ['id'])
  //       .eq('id', partidaId)
  //       .eq('game_id', gameId)
  //       .map((data) => data.isNotEmpty ? data.first['turn_index'] as int? : null);
  // }

  Future<int> getNextPlayerIndex(String partidaId) async {
    final response = await _supabase
        .from('pa_players')
        .select('indice')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .order('indice', ascending: false)
        .limit(1);

    if (response.isEmpty) return 1;

    final maxIndex = response.first['indice'] as int? ?? 0;
    return maxIndex + 1;
  }

}