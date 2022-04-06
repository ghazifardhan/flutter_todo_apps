import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertodo/blocs/todo.state.dart';
import 'package:fluttertodo/models/todo.model.dart';
import 'package:fluttertodo/repositories/todo.repo.dart';
import 'package:sqflite/sqlite_api.dart';

class TodoBloc extends Cubit<TodoState> {

  final _todoRepo = TodoRepository();
  final Database database;
  TodoBloc({required this.database}) : super(const InitTodoState(0));

  int _counter = 1;
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> getTodos() async {
    try {
      _todos = await _todoRepo.getTodos(database: database);
      emit(InitTodoState(_counter++));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> addTodos(String text) async {
    try {
      await _todoRepo.addTodo(database: database, text: text);
      emit(InitTodoState(_counter++));
      getTodos();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> removeTodo(int id) async {
    try {
      await _todoRepo.removeTodo(database: database, id: id);
      emit(InitTodoState(_counter++));
      getTodos();
    } catch (e) {
      log(e.toString());
    }
  }
}