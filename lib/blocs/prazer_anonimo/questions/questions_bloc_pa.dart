import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/prazer_anonimo/questions/questions_event_pa.dart';
import 'package:jogoteca/blocs/prazer_anonimo/questions/questions_state_pa.dart';
import 'package:jogoteca/service/prazer_anonimo/prazer_anonimo_service.dart';

class QuestionsBlocPA extends Bloc<QuestionsEventPA, QuestionsStatePA> {
  final PrazerAnonimoService service;

  QuestionsBlocPA(this.service) : super(QuestionsInitialPA()) {
    on<LoadQuestionsPA>((event, emit) async {
      emit(QuestionsLoadingPA());
      try {
        final list = await service.loadQuestions();
        emit(QuestionsLoadedPA(list));
      } catch (e) {
        emit(QuestionsErrorPA(e.toString()));
      }
    });
  }
}