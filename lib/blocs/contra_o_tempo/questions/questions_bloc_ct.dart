import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_event_ct.dart';
import 'package:jogoteca/blocs/contra_o_tempo/questions/questions_state_ct.dart';
import 'package:jogoteca/service/contra_o_tempo/contra_o_tempo_service.dart';


class QuestionsBlocCT extends Bloc<QuestionsEventCT, QuestionsStateCT> {
  final ContraOTempoService service;

  QuestionsBlocCT(this.service) : super(QuestionsInitialCT()) {
    on<LoadQuestionsCT>((event, emit) async {
      emit(QuestionsLoadingCT());
      try {
        final question = await service.loadQuestions();
        emit(QuestionsLoadedCT(question));
      } catch (e) {
        emit(QuestionsErrorCT(e.toString()));
      }
    });

    on<ResetQuestionsCT>((event, emit) => emit(QuestionsInitialCT()));
  }
}