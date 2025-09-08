import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jogoteca/screens/prazer_anonimo/form_controllers_pa.dart';
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
          '// Jogador da vez:',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.w400,
            fontSize: 15,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage('images/espiao.jpg'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                capitalize(playerName),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (hasDirectMessages && pinValidated)
              Stack(
                children: [
                  IconButton(
                    onPressed: onDirectMessagesPressed,
                    tooltip: 'Você tem mensagens no Direct. Clique para vê-las',
                    icon: Icon(Icons.message, color: Colors.cyanAccent, size: 35),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  )
                ],
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
          backgroundColor: Colors.green.withOpacity(0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.greenAccent),
          ),
          shadowColor: Colors.greenAccent,
          elevation: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.visibility_off_outlined, size: 24),
              const SizedBox(width: 15),
              const Text(
                'Acessar Pergunta',
                style: TextStyle(fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildQuestionForm({
    required String question,
    required FormControllersPA formControllers,
    required bool isProcessing,
    required List<Map<String, dynamic>> players,
    required String currentPlayerId,
    required List<Map<String, dynamic>> saQuestions, // NOVO
  }) {
    ValueNotifier<bool> radioEnabled = ValueNotifier<bool>(true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 4), // Reduzido padding lateral
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              height: 1.4, // Melhora a legibilidade
            ),
          ),
          const SizedBox(height: 20),
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
            decoration: InputDecoration(
              labelText: "Sua resposta...",
              labelStyle: const TextStyle(color: Colors.green, fontFamily: 'monospace'),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green.withOpacity(0.7)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
              ),
              filled: true,
              fillColor: Colors.black.withOpacity(0.3),
            ),
            cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<bool>(
            valueListenable: radioEnabled,
            builder: (context, isEnabled, child) {
              return Row(
                children: [
                  Radio<bool>(
                    value: true,
                    activeColor: Colors.cyanAccent,
                    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey.withOpacity(0.5);
                      } else if (states.contains(WidgetState.selected)) {
                        return Colors.cyanAccent;
                      }
                      return Colors.green;
                    }),
                    overlayColor: WidgetStateProperty.all(
                      Colors.cyanAccent.withOpacity(0.2),
                    ),
                    groupValue: formControllers.chooseNo ? true : null,
                    onChanged: isEnabled
                        ? (value) => formControllers.setChooseNo(value ?? false)
                        : null,
                  ),
                  const Text("Não", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace')),
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
    FormControllersPA formControllers,
    List<Map<String, dynamic>> players,
    String currentPlayerId,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: formControllers.superAnonimoActive ? Colors.yellow.withOpacity(0.6) : Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SwitchListTile(
            title: const Text(
              "Ativar modo Super Anônimo",
              style: TextStyle(color: Colors.yellow, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Envie perguntas, desafios ou respostas anônimas.",
              style: TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
            ),
            value: formControllers.superAnonimoActive,
            activeColor: Colors.yellow,
            onChanged: (value) {
              formControllers.setSuperAnonimoActive(value);
            },
          ),
          if (formControllers.superAnonimoActive) ...[
            const Divider(color: Colors.yellow),
            const SizedBox(height: 15),
            const Text("Modo:", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                selectedForegroundColor: Colors.black,
                selectedBackgroundColor: Colors.yellow,
              ),
              segments: const [
                ButtonSegment(
                  value: 'toResults',
                  label: Text('Resultados', style: TextStyle(fontFamily: 'monospace')),
                  icon: Icon(Icons.assessment_outlined),
                ),
                ButtonSegment(
                  value: 'toPlayer',
                  label: Text('Jogador', style: TextStyle(fontFamily: 'monospace')),
                  icon: Icon(Icons.person_search),
                ),
                ButtonSegment(
                  value: 'toChallenge',
                  label: Text('Desafios', style: TextStyle(fontFamily: 'monospace')),
                  icon: Icon(Icons.military_tech_outlined),
                ),
              ],
              selected: {formControllers.superAnonimoMode},
              onSelectionChanged: (newSelection) {
                if (newSelection.isNotEmpty) {
                  formControllers.setSuperAnonimoMode(newSelection.first);
                }
              },
            ),
            const SizedBox(height: 20),
            if (formControllers.superAnonimoMode == 'toResults') ...[
              TextField(
                controller: formControllers.perguntaSuperAnonimoController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Pergunta (Resultados)",
                  labelStyle: TextStyle(color: Colors.yellow, fontFamily: 'monospace'),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 2)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                cursorColor: Colors.amberAccent,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: formControllers.respostaSuperAnonimoController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Resposta (Resultados)",
                  labelStyle: TextStyle(color: Colors.yellow, fontFamily: 'monospace'),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 2)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                cursorColor: Colors.amberAccent,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ] else if (formControllers.superAnonimoMode == 'toChallenge') ...[
              const Text("Desafiar:", style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'monospace')),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  selectedForegroundColor: Colors.black,
                  selectedBackgroundColor: Colors.yellow,
                ),
                segments: const [
                  ButtonSegment(value: 'one', label: Text('1 jogador', style: TextStyle(fontFamily: 'monospace'))),
                  ButtonSegment(value: 'two', label: Text('2 jogadores', style: TextStyle(fontFamily: 'monospace'))),
                  ButtonSegment(value: 'all', label: Text('Todos', style: TextStyle(fontFamily: 'monospace'))),
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
                _buildPlayerDropdown(
                  value: formControllers.selectedChallengePlayer1,
                  hint: "Jogador 1",
                  players: players,
                  currentPlayerId: currentPlayerId,
                  onChanged: (value) => formControllers.setSelectedChallengePlayer1(value),
                ),
              ],
              if (formControllers.challengeTarget == 'two') ...[
                const SizedBox(height: 8),
                _buildPlayerDropdown(
                  value: formControllers.selectedChallengePlayer2,
                  hint: "Jogador 2",
                  players: players.where((p) => p['id'] != formControllers.selectedChallengePlayer1).toList(),
                  currentPlayerId: currentPlayerId,
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
                  labelStyle: TextStyle(color: Colors.yellow, fontFamily: 'monospace'),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 2)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                cursorColor: Colors.amberAccent,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ] else ...[
              const Text("Enviar para:", style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'monospace')),
              const SizedBox(height: 8),
              _buildPlayerDropdown(
                value: formControllers.selectedSuperAnonimoPlayer,
                hint: "Selecione um jogador",
                players: players,
                currentPlayerId: currentPlayerId,
                onChanged: (value) => formControllers.setSelectedSuperAnonimoPlayer(value),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: formControllers.perguntaParaJogadorController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: "Pergunta para o jogador",
                  labelStyle: TextStyle(color: Colors.yellow, fontFamily: 'monospace'),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amberAccent, width: 2)),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                cursorColor: Colors.amberAccent,
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static Widget buildDirectSection(FormControllersPA formControllers, List<Map<String, dynamic>> players, String currentPlayerId) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: formControllers.directActive ? Colors.cyan.withOpacity(0.6) : Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black.withOpacity(0.2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text(
              "Enviar Direct",
              style: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              "Envie uma mensagem privada para outro jogador.",
              style: TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
            ),
            value: formControllers.directActive,
            activeColor: Colors.cyanAccent,
            onChanged: (value) {
              formControllers.setDirectActive(value);
            },
          ),
          if (formControllers.directActive) ...[
            const Divider(color: Colors.cyanAccent),
            const SizedBox(height: 10),
            Column(
              children: [
                const Text("Mandar direct para:", style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'monospace')),
                const SizedBox(height: 10),
                _buildPlayerDropdown(
                  value: formControllers.selectedDirectPlayer,
                  hint: "Selecione um jogador",
                  players: players,
                  currentPlayerId: currentPlayerId,
                  onChanged: (value) => formControllers.setSelectedDirectPlayer(value),
                  isDirect: true,
                ),
                if (formControllers.selectedDirectPlayer != null) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: formControllers.mensagemDirectController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: "Digite sua mensagem - Direct",
                      labelStyle: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace'),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.black12,
                    ),
                    cursorColor: Colors.cyanAccent,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildPlayerDropdown({
    required String? value,
    required String hint,
    required List<Map<String, dynamic>> players,
    required String currentPlayerId,
    required ValueChanged<String?> onChanged,
    bool isDirect = false,
  }) {
    final hintColor = isDirect ? Colors.cyanAccent : Colors.yellow;
    final dropdownColor = isDirect ? Colors.cyanAccent : Colors.yellow;

    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dropdownColor.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dropdownColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
      ),
      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
      dropdownColor: const Color(0xFF0d1a0f),
      hint: Text(hint, style: TextStyle(color: hintColor, fontFamily: 'monospace')),
      items: players.where((p) => p['id'] != currentPlayerId).map<DropdownMenuItem<String>>((p) {
        return DropdownMenuItem<String>(
          value: p['id'],
          child: Text(p['nome']),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildSAInboxSection({
    required List<Map<String, dynamic>> saQuestions,
    required FormControllersPA formControllers,
  }) {
    if (saQuestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.inbox, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text(
              "Caixa de Entrada: Super Anônimo",
              style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ExpansionPanelList.radio(
          elevation: 0,
          dividerColor: Colors.transparent,
          children: saQuestions.map<ExpansionPanelRadio>((q) {
            final qid = q['id'] as String;
            final pergunta = q['pergunta']?.toString() ?? '';
            final ctrl = formControllers.getSAInboxAnswerController(qid);

            return ExpansionPanelRadio(
              backgroundColor: Color(0xFF214F1B).withOpacity(0.5),
              canTapOnHeader: true,
              splashColor: Color(0xFF214F1B),
              value: qid,
              headerBuilder: (context, isExpanded) => ListTile(
                title: const Text(
                  'Pergunta recebida. Clique para responder.',
                  style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
                ),
                subtitle: const Text(
                  'Responder é obrigatório',
                  style: TextStyle(color: Colors.redAccent, fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pergunta,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ctrl,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: "Sua resposta (obrigatória)",
                        labelStyle: TextStyle(color: Colors.orangeAccent, fontFamily: 'monospace'),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber, width: 2)),
                        filled: true,
                        fillColor: Colors.black12,
                      ),
                      cursorColor: Colors.amber,
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 20, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shadowColor: Colors.cyanAccent,
          elevation: 10,
        ),
        child: isProcessing
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
                  ),
                  SizedBox(width: 12),
                  Text("Salvando..."),
                ],
              )
            : const Text("Salvar e Avançar"),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Resultados da Rodada",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.analytics_outlined, color: Colors.green, size: 30),
                ],
              ),
              const Divider(color: Colors.green),
              Expanded(
                child: ListView.builder(
                  itemCount: roundResults.length,
                  itemBuilder: (context, index) {
                    final item = roundResults[index];
                    final isChallenge = item['isChallenge'] == true;
                    final isSuperAnonimo = item['jogadorId'] == 'superanonimo';

                    Color cardColor = Colors.black.withOpacity(0.4);
                    BorderSide borderSide = BorderSide(color: Colors.grey.withOpacity(0.3));

                    if (isChallenge) {
                      cardColor = Colors.orange.withOpacity(0.2);
                      borderSide = const BorderSide(color: Colors.orange);
                    }

                    final String displayName = (isChallenge || isSuperAnonimo) ? item['jogadorNome'] : item['jogadorNome'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: cardColor,
                      shape: RoundedRectangleBorder(
                        side: borderSide,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isChallenge)
                                  const Icon(Icons.military_tech, color: Colors.orange, size: 24)
                                else
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundImage: AssetImage('images/espiao.jpg'),
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: isChallenge
                                          ? Colors.orange
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (item['pergunta'].toString().isNotEmpty) ...[
                              Text(
                                "\"${item['pergunta']}\"",
                                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontFamily: 'monospace'),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              item['resposta'],
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80), // Espaço para o botão flutuante
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            foregroundColor: Colors.black,
            backgroundColor: Colors.cyanAccent,
            onPressed: onContinue,
            tooltip: 'Continuar',
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
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              hasDrawnPlayers
                  ? const ClinkingGlassesEffect(colorLeft: Colors.orange, colorRight: Colors.yellow)
                  : noResponseCount == 0
                      ? const ConfettiEffect()
                      : const BrokenHeartEffect(),
              const SizedBox(height: 10),
              if (!hasDrawnPlayers)
                Text(
                  noResponseCount == 0
                      ? "Todos os jogadores responderam!"
                      : "$noResponseCount ${noResponseCount == 1 ? 'jogador escolheu' : 'jogadores escolheram'} não responder.",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              if (noResponseCount > 0) ...[
                if (!hasDrawnPlayers) ...[
                  const Text(
                    "Sorteio de penalidade:",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: onDecrease,
                        icon: const Icon(Icons.remove, color: Colors.redAccent, size: 30),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          drinkingCount.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        onPressed: onIncrease,
                        icon: const Icon(Icons.add, color: Colors.greenAccent, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: onDrawPlayers,
                    icon: const Icon(Icons.casino_outlined, color: Colors.black),
                    label: const Text('Sortear Jogadores', style: TextStyle(color: Colors.black, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      textStyle: const TextStyle(fontSize: 18),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ] else ...[
                  const Text(
                    "Penalidade para:",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    color: Colors.red.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "${formatNames(sortedPlayers)} ${drinkingCount == 1 ? 'deve' : 'devem'} beber!",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ] else ...[
                Card(
                  color: Colors.green.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Ninguém bebe nesta rodada!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onNewRound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(FontAwesomeIcons.dice),
                  label: const Text('Jogar Nova Rodada', style: TextStyle(fontSize: 18, fontFamily: 'monospace')),
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
          const Icon(Icons.gamepad_outlined, color: Colors.white, size: 50),
          const SizedBox(height: 16),
          const Text(
            "Fim de Jogo!",
            style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
          const Text(
            "Todas as perguntas foram respondidas.",
            style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: onNewGame,
            icon: const Icon(Icons.refresh),
            label: const Text("Iniciar Novo Jogo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  static Widget buildNoQuestionsAvailable({
    required VoidCallback onNextPlayer,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.hourglass_empty, color: Colors.white, size: 40),
        const SizedBox(height: 16),
        const Text(
          "Você já respondeu todas as perguntas disponíveis para esta rodada!",
          style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onNextPlayer,
          icon: const Icon(Icons.skip_next),
          label: const Text("Próximo Jogador"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
