import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jogoteca/blocs/questions/questions_event.dart';
import 'package:jogoteca/blocs/questions/questions_state.dart';

import '../../service/firebase_service.dart';

class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  final FirebaseService service;
  QuestionsBloc(this.service) : super(QuestionsInitial()) {
    on<LoadQuestions>((event, emit) async {
      emit(QuestionsLoading());
      try {
        final list = await service.loadQuestions();
        emit(QuestionsLoaded(list));
      } catch (e) {
        emit(QuestionsError(e.toString()));
      }
    });

    on<AddQuestion>((event, emit) async {
      try {
        await service.addQuestions(event.pergunta, event.respostaChatgpt);
        add(LoadQuestions());
      } catch (e) {
        emit(QuestionsError(e.toString()));
      }
    });

    on<EditQuestion>((event, emit) async {
      try {
        await service.editQuestion(event.id, event.pergunta, event.respostaChatgpt);
        add(LoadQuestions());
      } catch (e) {
        emit(QuestionsError(e.toString()));
      }
    });

    on<DeleteQuestion>((event, emit) async {
      try {
        await service.deleteQuestion(event.id);
        add(LoadQuestions());
      } catch (e) {
        emit(QuestionsError(e.toString()));
      }
    });
  }
}