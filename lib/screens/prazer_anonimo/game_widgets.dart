import 'package:flutter/material.dart';
import 'form_controllers.dart';

class GameWidgets {
  static String capitalize(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static Widget buildPlayerHeader({
    required String playerName,
    required bool hasDirectMessages,
    required bool pinValidated,
    required VoidCallback onDirectMessagesPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jogador:',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('images/espiao.jpg'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                capitalize(playerName),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (hasDirectMessages && pinValidated)
              IconButton(
                onPressed: onDirectMessagesPressed,
                icon: const Badge(
                  child: Icon(Icons.message, color: Colors.blue, size: 30),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static Widget buildValidatePinButton({
    required bool isProcessing,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white70,
          foregroundColor: Colors.black,
        ),
        child: const Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility, size: 24),
              SizedBox(width: 15),
              Text('Ver Pergunta', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildQuestionForm({
    required String question,
    required FormControllers formControllers,
    required bool isProcessing,
    required List<Map<String, dynamic>> players,
    required String currentPlayerId,
  }) {
    ValueNotifier<bool> radioEnabled = ValueNotifier<bool>(true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: formControllers.respostaController,
            enabled: !isProcessing,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            onTap: () {
              if (formControllers.chooseNo) {
                formControllers.setChooseNo(false);
              }
            },
            onChanged: (value) {
              radioEnabled.value = value.trim().isEmpty;
            },
            decoration: const InputDecoration(
              labelText: "Sua resposta",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
            ),
            cursorColor: Colors.green,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<bool>(
            valueListenable: radioEnabled,
            builder: (context, isEnabled, child) {
              return Row(
                children: [
                  Radio<bool>(
                    value: true,
                    activeColor: Colors.white,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey;
                      } else if (states.contains(WidgetState.selected)) {
                        return Colors.green;
                      }
                      return Colors.white;
                    }),
                    overlayColor: WidgetStateProperty.all(
                      Colors.lightGreenAccent.withOpacity(0.2),
                    ),
                    groupValue: formControllers.chooseNo ? true : null,
                    onChanged: isEnabled
                        ? (value) => formControllers.setChooseNo(value ?? false)
                        : null,
                  ),
                  const Text("Não", style: TextStyle(color: Colors.white)),
                ],
              );
            },
          ),

          buildSuperAnonimoSection(formControllers),
          const SizedBox(height: 20),
          buildDirectSection(formControllers, players, currentPlayerId),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static Widget buildSuperAnonimoSection(FormControllers formControllers) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Responder como Super Anônimo", style: TextStyle(color: Colors.white)),
          value: formControllers.superAnonimoActive,
          activeColor: Colors.lightGreen,
          onChanged: (value) {
            formControllers.setSuperAnonimoActive(value);
          },
        ),
        if (formControllers.superAnonimoActive) ...[
          const SizedBox(height: 10),
          TextField(
            controller: formControllers.perguntaSuperAnonimoController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Digite sua pergunta - Super Anônimo",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
            ),
            cursorColor: Colors.green,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: formControllers.respostaSuperAnonimoController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              labelText: "Sua resposta - Super Anônimo",
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightGreen),
              ),
            ),
            cursorColor: Colors.green,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ],
    );
  }

  static Widget buildDirectSection(FormControllers formControllers, List<Map<String, dynamic>> players, String currentPlayerId) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Enviar Direct", style: TextStyle(color: Colors.white)),
          value: formControllers.directActive,
          onChanged: (value) {
            formControllers.setDirectActive(value);
          },
        ),
        if (formControllers.directActive) ...[
          const SizedBox(height: 10),
          Column(
            children: [
              const Text("Mandar direct para:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: formControllers.selectedDirectPlayer,
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.black,
                hint: const Text("Selecione um jogador", style: TextStyle(color: Colors.white)),
                items: players.where((p) => p['id'] != currentPlayerId).map<DropdownMenuItem<String>>((p) {
                  return DropdownMenuItem<String>(
                    value: p['id'],
                    child: Text(p['nome']),
                  );
                }).toList(),
                onChanged: (value) {
                  formControllers.setSelectedDirectPlayer(value);
                },
              ),
              if (formControllers.selectedDirectPlayer != null) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: formControllers.mensagemDirectController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: "Digite sua mensagem - Direct",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen),
                    ),
                  ),
                  cursorColor: Colors.green,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  static Widget buildSaveButton({
    required bool isProcessing,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.black.withOpacity(0.5),
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        child: isProcessing
            ? const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text("Salvando..."),
          ],
        )
            : const Text("Salvar"),
      ),
    );
  }

  static Widget buildRoundResults({
    required List<Map<String, dynamic>> roundResults,
    required VoidCallback onContinue,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("Resultados da rodada",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: roundResults.length,
              itemBuilder: (context, index) {
                final item = roundResults[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jogador: ${item['jogadorNome']}",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("Pergunta: ${item['pergunta']}"),
                        const SizedBox(height: 6),
                        Text("Resposta: ${item['resposta']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Continuar"),
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }

  static Widget buildDrinkingInterface({
    required int noResponseCount,
    required int drinkingCount,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required VoidCallback onDrawPlayers,
    required List<String> sortedPlayers,
    required bool hasDrawnPlayers,
    required VoidCallback onNewRound,
  }) {
    return Column(
      children: [
        const SizedBox(height: 50),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ALTERAÇÃO AQUI - Verificar se noResponseCount é 0
                Text(
                  noResponseCount == 0
                      ? "Todos os jogadores responderam as perguntas!"
                      : "$noResponseCount ${noResponseCount == 1 ? 'jogador escolheu' : 'jogadores escolheram'} não responder",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // CONDIÇÃO PARA MOSTRAR INTERFACE APENAS SE noResponseCount > 0
                if (noResponseCount > 0) ...[
                  if (!hasDrawnPlayers) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (drinkingCount > noResponseCount)
                          IconButton(
                            onPressed: onDecrease,
                            icon: const Icon(Icons.remove, color: Colors.white, size: 30),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            drinkingCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: onIncrease,
                          icon: const Icon(Icons.add, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.shuffle),
                      label: const Text("Sortear jogadores"),
                      onPressed: onDrawPlayers,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ] else ...[
                    Card(
                      color: Colors.red.withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "${sortedPlayers.join(', ')} ${noResponseCount == 1 ? 'deve' : 'devem'} beber!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  // CASO noResponseCount == 0, mostrar mensagem "Ninguém deve beber!"
                  Card(
                    color: Colors.green.withOpacity(0.8),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Ninguém deve beber!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Jogar nova rodada"),
                  onPressed: onNewRound,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildGameOverScreen({
    required VoidCallback onNewGame,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Acabaram todas as perguntas!", style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onNewGame,
            child: const Text("Iniciar novo jogo"),
          )
        ],
      ),
    );
  }

  static Widget buildNoQuestionsAvailable({
    required VoidCallback onNextPlayer,
  }) {
    return Column(
      children: [
        const Text("Você já respondeu todas as perguntas disponíveis!", style: TextStyle(color: Colors.white)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onNextPlayer,
          child: const Text("Próximo Jogador"),
        ),
      ],
    );
  }
}