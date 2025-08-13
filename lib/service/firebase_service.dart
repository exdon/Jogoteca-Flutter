import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String gameId = '1001';

  // ---------- PERGUNTAS ----------
  Future<List<Map<String, dynamic>>> loadQuestions() async {
    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('perguntas')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<void> addQuestions(String pergunta, String respostaChatgpt) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('perguntas')
        .add({
      'pergunta': pergunta,
      'resposta_chatgpt': respostaChatgpt,
    });
  }

  Future<void> editQuestion(String perguntaId, String novaPergunta, String novaResposta) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('perguntas')
        .doc(perguntaId)
        .update({
      'pergunta': novaPergunta,
      'resposta_chatgpt': novaResposta,
    });
  }

  Future<void> deleteQuestion(String perguntaId) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('perguntas')
        .doc(perguntaId)
        .delete();
  }

  // ---------- JOGADORES ----------

  CollectionReference<Map<String, dynamic>> _jogadoresRef(String partidaId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores');
  }

  Future<List<Map<String, dynamic>>> loadPlayers(String partidaId) async {
    final snapshot = await _jogadoresRef(partidaId).get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<void> addPlayer(String partidaId, String nome, int pin, int indice) async {
    await _jogadoresRef(partidaId)
        .add({'nome': nome, 'pin': pin, 'indice': indice});
  }

  Future<void> addPlayerData(
      String partidaId,
      String jogadorId,
      String pergunta,
      String resposta,
      bool superAnonimo,
      String? perguntaSuperAnonimo,
      String? respostaSuperAnonimo
      ) async {
    final respostaData = {
      'pergunta': pergunta,
      'resposta': resposta,
      'superAnonimo': superAnonimo,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Adiciona campos do super anônimo apenas se for válido
    if (superAnonimo && perguntaSuperAnonimo != null && respostaSuperAnonimo != null) {
      respostaData['pergunta_superAnonimo'] = perguntaSuperAnonimo;
      respostaData['resposta_superAnonimo'] = respostaSuperAnonimo;
    }

    await _jogadoresRef(partidaId)
        .doc(jogadorId)
        .collection('respostas')
        .add(respostaData);
  }

  Future<List<Map<String, dynamic>>> loadResultsOptimized(String partidaId) async {
    // Primeiro, pega todos os jogadores da partida
    final jogadoresSnapshot = await _jogadoresRef(partidaId).get();

    // Cria uma lista de Futures para buscar as respostas de todos os jogadores em paralelo
    List<Future<List<Map<String, dynamic>>>> futures = jogadoresSnapshot.docs.map((jogadorDoc) async {
      String jogadorId = jogadorDoc.id;
      String jogadorNome = jogadorDoc.data()['nome'] ?? 'Jogador';

      // Busca as respostas deste jogador
      final respostasSnapshot = await _jogadoresRef(partidaId)
          .doc(jogadorId)
          .collection('respostas')
          .orderBy('timestamp')
          .get();

      // Retorna lista de perguntas e respostas deste jogador
      List<Map<String, dynamic>> respostasJogador = [];

      for (var respostaDoc in respostasSnapshot.docs) {
        Map<String, dynamic> respostaData = respostaDoc.data();

        // Sempre adiciona a resposta normal
        respostasJogador.add({
          'jogadorId': jogadorId,
          'jogadorNome': jogadorNome,
          'pergunta': respostaData['pergunta'] ?? '',
          'resposta': respostaData['resposta'] ?? '',
          'tipo': 'normal',
        });

        // Se for super anônimo e tiver os campos, adiciona outro objeto com a resposta super anônima
        if (respostaData['superAnonimo'] == true &&
            respostaData['pergunta_superAnonimo'] != null &&
            respostaData['resposta_superAnonimo'] != null) {
          respostasJogador.add({
            'jogadorId': 'superanonimo',
            'jogadorNome': 'Super Anônimo',
            'pergunta': respostaData['pergunta_superAnonimo'] ?? '',
            'resposta': respostaData['resposta_superAnonimo'] ?? '',
            'tipo': 'superanonimo',
          });
        }
      }

      return respostasJogador;
    }).toList();

    // Executa todas as consultas em paralelo
    List<List<Map<String, dynamic>>> resultadosPorJogador = await Future.wait(futures);

    // Junta todas as respostas em uma única lista
    List<Map<String, dynamic>> todasRespostas = [];
    for (var respostasJogador in resultadosPorJogador) {
      todasRespostas.addAll(respostasJogador);
    }

    return todasRespostas;
  }

  Future<void> sendDirectMessage(
      String partidaId,
      String remetenteId,
      String destinatarioId,
      String mensagem,
      String remetenteNome
      ) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('partidas')
          .doc(partidaId)
          .collection('jogadores')
          .doc(destinatarioId)
          .collection('directs')
          .add({
        'remetenteId': remetenteId,
        'remetenteNome': remetenteNome,
        'mensagem': mensagem,
        'lida': false,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao enviar mensagem direta: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadDirectMessages(String partidaId, String jogadorId) async {
    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores')
        .doc(jogadorId)
        .collection('directs')
        .where('lida', isEqualTo: false)
        .orderBy('criadoEm')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<void> markMessageAsRead(String partidaId, String jogadorId, String messageId) async {
    try {
      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('partidas')
          .doc(partidaId)
          .collection('jogadores')
          .doc(jogadorId)
          .collection('directs')
          .doc(messageId)
          .update({'lida': true});
    } catch (e) {
      throw Exception('Erro ao marcar mensagem como lida: $e');
    }
  }

  Future<void> markAllMessagesAsRead(String partidaId, String jogadorId) async {
    try {
      final snapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('partidas')
          .doc(partidaId)
          .collection('jogadores')
          .doc(jogadorId)
          .collection('directs')
          .where('lida', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'lida': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao marcar mensagens como lidas: $e');
    }
  }

  Future<void> removePlayer(String partidaId, String jogadorId) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores')
        .doc(jogadorId)
        .delete();
  }
}