import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/data/datasources/todo_local_data_source.dart';
import 'features/todo/data/repositories/todo_repository_impl.dart';
import 'features/todo/presentation/bloc/todo_bloc.dart';
import 'features/todo/presentation/pages/todo_page.dart';
import 'features/todo/domain/repositories/todo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  final box = await Hive.openBox<TodoModel>('todos');
  final local = TodoLocalDataSourceImpl(box);
  final repo = TodoRepositoryImpl(local);

  runApp(MyApp(repo));
}

class MyApp extends StatelessWidget {
  final TodoRepository repository;
  const MyApp(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TodoBloc(repository)..add(LoadTodos()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const TodoPage(),
      ),
    );
  }
}
