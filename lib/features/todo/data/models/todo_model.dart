import 'package:hive/hive.dart';
import '../../domain/entities/todo.dart';

class TodoModel {
  String id;
  String title;
  bool done;

  TodoModel({required this.id, required this.title, required this.done});

  factory TodoModel.fromEntity(Todo t) =>
      TodoModel(id: t.id, title: t.title, done: t.done);
  Todo toEntity() => Todo(id: id, title: title, done: done);
}

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 0;

  @override
  TodoModel read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final done = reader.readBool();
    return TodoModel(id: id, title: title, done: done);
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeBool(obj.done);
  }
}
