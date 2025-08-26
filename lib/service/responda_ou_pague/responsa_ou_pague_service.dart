import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jogoteca/shared/shared_functions.dart';

class ResponsaOuPagueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String gameId = '1002';

  // ---------- PERGUNTAS ----------
  Future<Map<String, dynamic>> loadQuestion(String classificacao) async {
    String targetClassificacao = classificacao;

    // Se for aleatório, sorteia entre moderado e picante
    if (classificacao == 'aleatorio') {
      final opcoes = ['moderado', 'picante'];
      opcoes.shuffle();
      targetClassificacao = opcoes.first;
    }

    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('perguntas')
        .doc('classificacao')
        .collection(targetClassificacao)
        .limit(1)
        .get();

    final doc = snapshot.docs.first;
    return {
      'id': doc.id,
      ...doc.data(),
    };
  }

  // ---------- DESAFIOS ----------
  Future<Map<String, dynamic>> loadChallenge(String classificacao) async {
    String targetClassificacao = classificacao;

    // Se for aleatório, sorteia entre moderado e picante
    if (classificacao == 'aleatorio') {
      final opcoes = ['moderado', 'picante'];
      opcoes.shuffle();
      targetClassificacao = opcoes.first;
    }

    final snapshot = await _firestore
        .collection('games')
        .doc(gameId)
        .collection('desafios')
        .doc('classificacao')
        .collection(targetClassificacao)
        .limit(1)
        .get();

    final doc = snapshot.docs.first;
    return {
      'id': doc.id,
      ...doc.data(),
    };
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
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  Future<Map<String, dynamic>?> loadPlayerData(String partidaId, String jogadorId) async {
    final docSnap = await _jogadoresRef(partidaId).doc(jogadorId).get();

    return docSnap.data();
  }

  Future<void> addPlayer(String partidaId, String nome) async {
    await _jogadoresRef(partidaId)
        .add({'nome': SharedFunctions.capitalize(nome), 'vidas': 5});
  }

  Future<void> updatePlayerData(String partidaId, String jogadorId, int vidas) async {
    await _jogadoresRef(partidaId)
        .doc(jogadorId)
        .update({'vidas': vidas});
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

  // ---------- PARTIDA ----------


  Future<void> deletePartida(String partidaId) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('partidas')
        .doc(partidaId)
        .delete();
  }
}