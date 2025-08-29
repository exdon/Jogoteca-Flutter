import 'package:jogoteca/shared/shared_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContraOTempoService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String gameId = '1003';


  // ---------- PERGUNTAS ----------
  Future<List<Map<String, dynamic>>> loadQuestions() async {
    final response = await _supabase
        .from('ct_questions')
        .select('*')
        .eq('game_id', gameId);

    List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(response);
    questions.shuffle();
    return questions;
  }

  // ---------- JOGADORES ----------
  Future<List<Map<String, dynamic>>> loadPlayers(String partidaId) async {
    final response = await _supabase
        .from('ct_players')
        .select('*')
        .eq('game_id', gameId)
        .eq('partida_id', partidaId)
        .order('indice');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addPlayer(String partidaId, String nome, int indice) async {
    await _supabase
        .from('ct_players')
        .insert({
      'game_id': gameId,
      'partida_id': partidaId,
      'nome': SharedFunctions.capitalize(nome),
      'indice': indice,
    });
  }

}