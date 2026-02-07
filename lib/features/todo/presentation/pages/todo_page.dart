import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with TickerProviderStateMixin {
  bool _isSearching = false;
  String _searchQuery = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(
          () => _searchQuery = _searchController.text.trim().toLowerCase(),
        );
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        title: AnimatedCrossFade(
          firstChild: Text(
            'Tasks',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          secondChild: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _isSearching = false);
                  },
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          crossFadeState: _isSearching
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        actions: [
          IconButton(
            tooltip: _isSearching ? 'Close search' : 'Search',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              if (_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
              _isSearching = !_isSearching;
            }),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear_completed') {
                context.read<TodoBloc>().add(ClearCompletedEvent());
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear completed'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TodoError) {
              return Center(
                child: Text(state.message, style: theme.textTheme.bodyLarge),
              );
            }
            if (state is TodoLoaded) {
              final todos = state.todos;
              final filtered = _searchQuery.isEmpty
                  ? todos
                  : todos
                        .where(
                          (t) => t.title.toLowerCase().contains(_searchQuery),
                        )
                        .toList();

              if (todos.isEmpty) {
                return _buildEmptyState(context);
              }

              if (_searchQuery.isNotEmpty && filtered.isEmpty) {
                return Center(
                  child: Text(
                    'No results for "$_searchQuery"',
                    style: theme.textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final t = filtered[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: theme.colorScheme.surface,
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => context.read<TodoBloc>().add(
                              DeleteTodoEvent(t.id),
                            ),
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: _buildHighlightedTitle(t.title, done: t.done),
                        leading: GestureDetector(
                          onLongPress: () => _showAddDialog(context, todo: t),
                          onTap: () =>
                              context.read<TodoBloc>().add(ToggleTodoEvent(t)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: t.done
                                  ? Colors.greenAccent.shade700
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.12,
                                ),
                              ),
                            ),
                            child: Icon(
                              t.done ? Icons.check : Icons.circle_outlined,
                              color: t.done
                                  ? Colors.white
                                  : theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: Text(
          'Add task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox,
            size: 72,
            color: theme.colorScheme.onBackground.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text('No tasks yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first task',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: Text('Create task', style: GoogleFonts.poppins()),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, {bool done = false}) {
    if (_searchQuery.isEmpty) {
      return Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      );
    }
    final lower = title.toLowerCase();
    final matchIndex = lower.indexOf(_searchQuery);
    if (matchIndex == -1) {
      return Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      );
    }
    final before = title.substring(0, matchIndex);
    final match = title.substring(matchIndex, matchIndex + _searchQuery.length);
    final after = title.substring(matchIndex + _searchQuery.length);
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: const TextStyle(
              backgroundColor: Colors.yellowAccent,
              color: Colors.black,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, {Todo? todo}) {
    final controller = TextEditingController(text: todo?.title ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  todo == null ? 'Add Task' : 'Edit Task',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final title = controller.text.trim();
                    if (title.isNotEmpty) {
                      if (todo == null) {
                        final id = DateTime.now().millisecondsSinceEpoch
                            .toString();
                        final newTodo = Todo(id: id, title: title);
                        context.read<TodoBloc>().add(AddTodoEvent(newTodo));
                      } else {
                        final updated = todo.copyWith(title: title);
                        context.read<TodoBloc>().add(UpdateTodoEvent(updated));
                      }
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: Text(todo == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
