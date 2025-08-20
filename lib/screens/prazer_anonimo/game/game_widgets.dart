import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jogoteca/screens/prazer_anonimo/form_controllers.dart';
import 'package:jogoteca/widget/clinking_glasses_effect.dart';
import 'package:jogoteca/widget/confetti_effect.dart';
import 'package:jogoteca/widget/broken_heart_effect.dart';

class GameWidgets {
  static String capitalize(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static String formatNames(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} e ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} e ${names.last}';
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
                tooltip: 'Você tem mensagens no Direct. Clique para vê-las',
                icon: const Badge(
                  child: Icon(Icons.message, color: Colors.greenAccent, size: 35),
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
    required List<Map<String, dynamic>> saQuestions, // NOVO
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
                  const Text("Não", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          ),
          // Inbox de perguntas do Super Anônimo (obrigatórias)
          buildSAInboxSection(
            saQuestions: saQuestions,
            formControllers: formControllers,
          ),
          const SizedBox(height: 20),
          // Super Anônimo (modos)
          buildSuperAnonimoSection(formControllers, players, currentPlayerId),
          const SizedBox(height: 20),
          buildDirectSection(formControllers, players, currentPlayerId),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static Widget buildSuperAnonimoSection(
      FormControllers formControllers,
      List<Map<String, dynamic>> players,
      String currentPlayerId,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(height: 15),
          const Text("Modo do Super Anônimo:", style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: Colors.green,
            ),
            segments: const [
              ButtonSegment(
                value: 'toResults',
                label: Text('Resultados'),
              ),
              ButtonSegment(
                value: 'toPlayer',
                label: Text('Jogador'),
              ),
              ButtonSegment(
                value: 'toChallenge',
                label: Text('Desafios'),
              ),
            ],
            selected: {formControllers.superAnonimoMode},
            onSelectionChanged: (newSelection) {
              if (newSelection.isNotEmpty) {
                formControllers.setSuperAnonimoMode(newSelection.first);
              }
            },
          ),
          const SizedBox(height: 12),

          if (formControllers.superAnonimoMode == 'toResults') ...[
            TextField(
              controller: formControllers.perguntaSuperAnonimoController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Pergunta (Resultados)",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
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
                labelText: "Resposta (Resultados)",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
              ),
              cursorColor: Colors.green,
              style: const TextStyle(color: Colors.white),
            ),
          ] else if (formControllers.superAnonimoMode == 'toChallenge') ...[
              const Text("Desafiar:", style: TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.green,
                ),
                segments: const [
                  ButtonSegment(value: 'one', label: Text('1 jogador')),
                  ButtonSegment(value: 'two', label: Text('2 jogadores')),
                  ButtonSegment(value: 'all', label: Text('Todos')),
                ],
                selected: {formControllers.challengeTarget},
                onSelectionChanged: (newSelection) {
                  if (newSelection.isNotEmpty) {
                    formControllers.setChallengeTarget(newSelection.first);
                  }
                },
              ),
              const SizedBox(height: 10),
              if (formControllers.challengeTarget != 'all') ...[
                DropdownButton<String>(
                  value: formControllers.selectedChallengePlayer1,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                  hint: const Text("Jogador 1", style: TextStyle(color: Colors.white)),
                    items: players.where((p) => p['id'] != currentPlayerId).map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem<String>(
                      value: p['id'],
                      child: Text(p['nome'], style: TextStyle(fontSize: 16),),
                    );
                  }).toList(),
                  onChanged: (value) => formControllers.setSelectedChallengePlayer1(value),
                ),
              ],
              if (formControllers.challengeTarget == 'two') ...[
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: formControllers.selectedChallengePlayer2,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                  hint: const Text("Jogador 2", style: TextStyle(color: Colors.white, fontSize: 16)),
                  items: players.where((p) => p['id'] != currentPlayerId && p['id'] != formControllers.selectedChallengePlayer1).map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem<String>(
                      value: p['id'],
                      child: Text(p['nome'], style: TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (value) => formControllers.setSelectedChallengePlayer2(value),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: formControllers.desafioController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Digite o desafio",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
                ),
                cursorColor: Colors.green,
                style: const TextStyle(color: Colors.white),
              ),
          ] else ...[
            const Text("Enviar para:", style: TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: formControllers.selectedSuperAnonimoPlayer,
              style: const TextStyle(color: Colors.white),
              dropdownColor: Colors.black,
              hint: const Text("Selecione um jogador", style: TextStyle(color: Colors.white, fontSize: 16)),
              items: players.where((p) => p['id'] != currentPlayerId).map<DropdownMenuItem<String>>((p) {
                return DropdownMenuItem<String>(
                  value: p['id'],
                  child: Text(p['nome']),
                );
              }).toList(),
              onChanged: (value) {
                formControllers.setSelectedSuperAnonimoPlayer(value);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: formControllers.perguntaParaJogadorController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: "Pergunta para o jogador",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
              ),
              cursorColor: Colors.green,
              style: const TextStyle(color: Colors.white),
            ),
          ],
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
          activeColor: Colors.lightGreen,
          onChanged: (value) {
            formControllers.setDirectActive(value);
          },
        ),
        if (formControllers.directActive) ...[
          const SizedBox(height: 10),
          Column(
            children: [
              const Text("Mandar direct para:", style: TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: formControllers.selectedDirectPlayer,
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.black,
                hint: const Text("Selecione um jogador", style: TextStyle(color: Colors.white, fontSize: 16)),
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

  static Widget buildSAInboxSection({
    required List<Map<String, dynamic>> saQuestions,
    required FormControllers formControllers,
  }) {
    if (saQuestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Pergunta Recebida do Super Anônimo:",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ExpansionPanelList.radio(
          children: saQuestions.map<ExpansionPanelRadio>((q) {
            final qid = q['id'] as String;
            final pergunta = q['pergunta']?.toString() ?? '';
            final ctrl = formControllers.getSAInboxAnswerController(qid);

            return ExpansionPanelRadio(
              backgroundColor: Color(0xFF214F1B),
              value: qid,
              headerBuilder: (context, isExpanded) => ListTile(
                title: Text(
                  'Clique para Ver/Responder a Pergunta',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Responder é obrigatório',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pergunta,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: ctrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: "Sua resposta",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen)),
                      ),
                      cursorColor: Colors.green,
                      style: const TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey[900],
          textStyle: const TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
            : Padding(
          padding: EdgeInsetsGeometry.only(top: 15, bottom: 15),
          child: const Text("Salvar", style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  static Widget buildRoundResults({
    required List<Map<String, dynamic>> roundResults,
    required VoidCallback onContinue,
  }) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Resultados da Rodada",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.insert_chart_outlined, color: Colors.lightGreen, size: 30),
                ],
              ),
              const SizedBox(height: 12),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: roundResults.length + 1,
                  itemBuilder: (context, index) {
                    if (index == roundResults.length) {
                      return const SizedBox(height: 80);
                    }

                    final item = roundResults[index];
                    final isChallenge = item['isChallenge'] == true;
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: isChallenge ? Colors.orange.withOpacity(0.8) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isChallenge) ...[
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage('images/espiao.jpg'),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Jogador: ${item['jogadorNome']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (item['pergunta'].toString().isNotEmpty) ...[
                                Text("${item['pergunta']}", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                              ],
                              Text("${item['resposta']}"),
                            ] else ...[
                              Row(
                                children: [
                                  Icon(Icons.emoji_events, color: Colors.orange, size: 24),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${item['jogadorNome']}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${item['resposta']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Removido o botão daqui
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            foregroundColor: Colors.black,
            backgroundColor: Colors.lightGreen,
            onPressed: onContinue,
            child: const Icon(Icons.arrow_forward),
          ),
        ),
      ],
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
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ← importante para centralizar
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              hasDrawnPlayers
                  ? ClinkingGlassesEffect(colorLeft: Colors.orange, colorRight: Colors.yellow)
                  : noResponseCount == 0
                    ? ConfettiEffect()
                    : BrokenHeartEffect(),
              const SizedBox(height: 10),
              if (!hasDrawnPlayers)
                Text(
                  noResponseCount == 0
                      ? "Todos os jogadores responderam as perguntas!"
                      : "$noResponseCount ${noResponseCount == 1 ? 'jogador escolheu' : 'jogadores escolheram'} não responder",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 10),

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
                    onPressed: onDrawPlayers,
                    icon: const Icon(Icons.person_search, color: Colors.white),
                    label: const Text('Sortear jogadores', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3E8234),
                      textStyle: const TextStyle(fontSize: 18),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ] else ...[
                  Card(
                    color: Colors.red.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "${formatNames(sortedPlayers)} ${noResponseCount == 1 ? 'deve' : 'devem'} beber!",
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

              const SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onNewRound,
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF214F1B),
                  foregroundColor: Colors.white,
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(FontAwesomeIcons.dice),
                      SizedBox(width: 15),
                      Text('Jogar Nova Rodada', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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