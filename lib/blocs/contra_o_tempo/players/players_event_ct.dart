abstract class PlayersEventCT {}

class LoadPlayersCT extends PlayersEventCT {
  final String partidaId;
  LoadPlayersCT(this.partidaId);
}

class AddPlayerCT extends PlayersEventCT {
  final String partidaId;
  final String nome;
  final int indice;
  AddPlayerCT(this.partidaId, this.nome, this.indice);
}