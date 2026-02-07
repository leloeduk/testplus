import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool done;

  TodoModel({required this.id, required this.title, required this.done});

  factory TodoModel.fromEntity(Todo t) =>
      TodoModel(id: t.id, title: t.title, done: t.done);
  Todo toEntity() => Todo(id: id, title: title, done: done);
}
