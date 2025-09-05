class AddPlayersVMCValidator {
  static bool isPinValid(String pin) {
    final pinReg = RegExp(r'^\d{4,6}$');
    return pinReg.hasMatch(pin);
  }

  static String? validatePlayerName(String nome) {
    if (nome.trim().isEmpty) {
      return 'Por favor, insira o nome do jogador';
    }
    return null;
  }

  static String? validatePin(String pin) {
    if (!isPinValid(pin)) {
      return 'Pin deve ter entre 4 e 6 dígitos numéricos';
    }
    return null;
  }

  static Map<String, String?> validatePlayerData(String nome) {
    return {'nome': validatePlayerName(nome),};
  }
}