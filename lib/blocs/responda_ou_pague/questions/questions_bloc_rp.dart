import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_event_rp.dart';
import 'package:jogoteca/blocs/responda_ou_pague/questions/questions_state_rp.dart';
import 'package:jogoteca/service/responda_ou_pague/responsa_ou_pague_service.dart';


class QuestionsBlocRP extends Bloc<QuestionsEventRP, QuestionsStateRP> {
  final ResponsaOuPagueService service;

  QuestionsBlocRP(this.service) : super(QuestionInitialRP()) {

    on<LoadQuestionRP>((event, emit) async {
      emit(QuestionLoadingRP());
      try {
        final question = await service.loadQuestion(
            event.classificacao,
            event.answeredQuestions,
            event.recentQuestions
        );
        emit(QuestionLoadedRP(question));
      } catch (e) {
        emit(QuestionErrorRP(e.toString()));
      }
    });

    on<ResetQuestionRP>((event, emit) => emit(QuestionInitialRP()));
  }
}