import 'package:supabase_flutter/supabase_flutter.dart';

class SharedService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String gameId;
  final String database;
  final String partidaId;

  SharedService({
    required this.gameId,
    required this.database,
    required this.partidaId
  });

  // ---------- PARTIDA ATIVA ----------
  Future<void> setPartidaAtiva(bool ativa) async {
    await _supabase
        .from(database)
        .upsert({
      'id': partidaId,
      'game_id': gameId,
      'ativa': ativa,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isPartidaAtiva() async {
    try {
      final response = await _supabase
          .from(database)
          .select('ativa')
          .eq('id', partidaId)
          .eq('game_id', gameId)
          .single();

      return response['ativa'] ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePartida() async {
    await _supabase
        .from(database)
        .delete()
        .eq('id', partidaId)
        .eq('game_id', gameId);
  }
}