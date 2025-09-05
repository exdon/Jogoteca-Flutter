import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_event_vmc.dart';
import 'package:jogoteca/blocs/voce_me_conhece/questions/questions_state_vmc.dart';
import 'package:jogoteca/service/voce_me_conhece/voce_me_conhece_service.dart';

class QuestionsBlocVMC extends Bloc<QuestionsEventVMC, QuestionsStateVMC> {
  final VoceMeConheceService service;

  QuestionsBlocVMC(this.service) : super(QuestionsInitialVMC()) {
    on<LoadQuestionsVMC>((event, emit) async {
      emit(QuestionsLoadingVMC());
      try {
        final list = await service.loadQuestions();
        emit(QuestionsLoadedVMC(list));
      } catch (e) {
        emit(QuestionsErrorVMC(e.toString()));
      }
    });

    on<LoadAvailableQuestionsVMC>((event, emit) async {
      emit(QuestionsLoadingVMC());
      try {
        final list = await service.loadAvailableQuestions(event.partidaId, event.playerId);
        emit(QuestionsLoadedVMC(list));
      } catch (e) {
        emit(QuestionsErrorVMC(e.toString()));
      }
    });
  }
}