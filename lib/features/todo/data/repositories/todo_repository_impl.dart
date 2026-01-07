import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource local;
  TodoRepositoryImpl(this.local);

  @override
  Future<void> addTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    await local.addTodo(model);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await local.deleteTodo(id);
  }

  @override
  Future<List<Todo>> getTodos() async {
    final models = await local.getTodos();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    await local.updateTodo(model);
  }
}
