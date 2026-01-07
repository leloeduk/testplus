import 'package:hive/hive.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> addTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<void> updateTodo(TodoModel todo);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box box;
  TodoLocalDataSourceImpl(this.box);

  @override
  Future<void> addTodo(TodoModel todo) async {
    await box.put(todo.id, todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await box.delete(id);
  }

  @override
  Future<List<TodoModel>> getTodos() async {
    final values = box.values.cast<TodoModel>().toList();
    return values;
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    await box.put(todo.id, todo);
  }
}
