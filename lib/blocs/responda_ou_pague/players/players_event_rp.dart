abstract class PlayersEventRP {}

class LoadPlayersRP extends PlayersEventRP {
  final String partidaId;
  LoadPlayersRP(this.partidaId);
}

class LoadRandomPlayerRP extends PlayersEventRP {
  final String partidaId;
  LoadRandomPlayerRP(this.partidaId);
}

class LoadPlayerDataRP extends PlayersEventRP {
  final String partidaId;
  final String jogadorId;
  LoadPlayerDataRP(this.partidaId, this.jogadorId);
}

class AddPlayerRP extends PlayersEventRP {
  final String partidaId;
  final String nome;
  AddPlayerRP(this.partidaId, this.nome);
}

class UpdatePlayerDataRP extends PlayersEventRP {
  final String partidaId;
  final String jogadorId;
  final int vidas;
  UpdatePlayerDataRP(this.partidaId, this.jogadorId, this.vidas);
}