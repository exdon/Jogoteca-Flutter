import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogoteca/shared/shared_functions.dart';

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

    List<Map<String, dynamic>> questions = snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();

    questions.shuffle(); // randomiza as perguntas
    return questions;
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
    final snapshot = await _jogadoresRef(partidaId)
        .orderBy('indice')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<void> addPlayer(String partidaId, String nome, int pin, int indice) async {
    await _jogadoresRef(partidaId)
        .add({'nome': SharedFunctions.capitalize(nome), 'pin': pin, 'indice': indice});
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

    // RANDOMIZA A ORDEM DOS RESULTADOS
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

  // ---------- SUPER ANÔNIMO (PERGUNTAS PARA JOGADORES) ----------

  Future<void> sendSuperAnonimoQuestion(
      String partidaId,
      String remetenteId,
      String destinatarioId,
      String pergunta,
      String remetenteNome,
      ) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores')
        .doc(destinatarioId)
        .collection('superAnonimoQuestion')
        .add({
      'remetenteId': remetenteId,
      'remetenteNome': remetenteNome,
      'pergunta': pergunta,
      'resposta': '',
      'respondida': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> loadSuperAnonimoQuestions(String partidaId, String jogadorId) async {
    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores')
        .doc(jogadorId)
        .collection('superAnonimoQuestion')
        .where('respondida', isEqualTo: false)
        .orderBy('criadoEm')
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<void> answerSuperAnonimoQuestion(
      String partidaId,
      String jogadorId,
      String questionId,
      String resposta,
      ) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('jogadores')
        .doc(jogadorId)
        .collection('superAnonimoQuestion')
        .doc(questionId)
        .update({
      'resposta': resposta,
      'respondida': true,
    });
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

  // ---------- PARTIDA ATIVA ----------
  Future<void> setPartidaAtiva(String partidaId, bool ativa) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .set({
      'ativa': ativa,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> isPartidaAtiva(String partidaId) async {
    try {
      final snapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('partidas')
          .doc(partidaId)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['ativa'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deletePartida(String partidaId) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .delete();
  }

// ---------- SOLICITAÇÕES DE ENTRADA ----------
  Future<String> sendJoinRequest(String partidaId, String nomeJogador, int pin) async {
    final ref = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .add({
      'nomeJogador': nomeJogador,
      'pin': pin,
      'status': 'pending', // pending, approved, rejected
      'timestamp': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<List<Map<String, dynamic>>> getJoinRequestsStream(String partidaId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList());
  }

  Future<bool> partidaExists(String partidaId) async {
    final snap = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .get();
    return snap.exists;
  }

  Stream<Map<String, dynamic>?> listenJoinRequestStatus(String partidaId, String requestId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .doc(requestId)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<void> respondToJoinRequest(String partidaId, String requestId, bool approved) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .doc(requestId)
        .update({
      'status': approved ? 'approved' : 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelJoinRequest(String partidaId, String nomeJogador) async {
    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .where('nomeJogador', isEqualTo: nomeJogador)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> cancelJoinRequestById(String partidaId, String requestId) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .doc(requestId)
        .update({
      'status': 'cancelled',
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<String?> getJoinRequestStatus(String partidaId, String nomeJogador) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .collection('joinRequests')
        .where('nomeJogador', isEqualTo: nomeJogador)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data()['status'] as String?;
    });
  }

  Stream<List<Map<String, dynamic>>> playersStream(String partidaId) {
    return _jogadoresRef(partidaId)
        .orderBy('indice')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList());
  }

  Future<void> setTurnIndex(String partidaId, int turnIndex) async {
    await _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .set({
      'turnIndex': turnIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<int?> listenTurnIndex(String partidaId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .snapshots()
        .map((doc) => doc.data()?['turnIndex'] as int?);
  }

  Future<int> getNextPlayerIndex(String partidaId) async {
    final snapshot = await _jogadoresRef(partidaId).get();
    if (snapshot.docs.isEmpty) return 1;

    int maxIndex = 0;
    for (final doc in snapshot.docs) {
      final indice = doc.data()['indice'] as int? ?? 0;
      if (indice > maxIndex) maxIndex = indice;
    }
    return maxIndex + 1;
  }
}