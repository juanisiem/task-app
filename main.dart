import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  final List<Todo> _importantTodos = [];
  final List<DeletedTodo> _deletedTodos = [];
  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    if (_textController.text.isEmpty) return;
    setState(() {
      _todos.add(Todo(
        text: _textController.text,
        completed: false,
      ));
    });
    _textController.clear();
  }

  void _toggleTodoCompletion(int index) {
    setState(() {
      _todos[index].completed = !_todos[index].completed;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      final deletedTodo = DeletedTodo(
        todo: _todos.removeAt(index),
        deletionDate: DateTime.now(),
      );
      _deletedTodos.add(deletedTodo);
      _scheduleDeletion(deletedTodo);
    });
  }

  void _scheduleDeletion(DeletedTodo deletedTodo) {
    Timer(Duration(days: 7), () {
      setState(() {
        _deletedTodos.remove(deletedTodo);
      });
    });
  }

  void _restoreTodoFromTrash(int index) {
    setState(() {
      _todos.add(_deletedTodos.removeAt(index).todo);
    });
  }

  void _deleteTodoPermanently(int index) {
    setState(() {
      _deletedTodos.removeAt(index);
    });
  }

  void _addToImportant(int index) {
    setState(() {
      _importantTodos.add(_todos.removeAt(index));
    });
  }

  void _removeFromImportant(int index) {
    setState(() {
      _todos.add(_importantTodos.removeAt(index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Your To Do List')),
        backgroundColor: Colors.blueAccent,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.star),
              title: Text('Important'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ImportantScreen(importantTodos: _importantTodos, removeFromImportant: _removeFromImportant)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Tareas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Papelera'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrashScreen(deletedTodos: _deletedTodos, restoreTodoFromTrash: _restoreTodoFromTrash, deleteTodoPermanently: _deleteTodoPermanently)),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      filled: true,
                      fillColor: Colors.blue[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (text) => _addTodo(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blueAccent),
                  onPressed: _addTodo,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  color: todo.completed ? Colors.green[50] : Colors.red[50],
                  child: ListTile(
                    title: Text(
                      todo.text,
                      style: TextStyle(
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.completed ? Colors.green : Colors.red,
                      ),
                    ),
                    leading: Checkbox(
                      value: todo.completed,
                      onChanged: (bool? value) {
                        _toggleTodoCompletion(index);
                      },
                      activeColor: Colors.blueAccent,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.star, color: Colors.blueAccent),
                          onPressed: () {
                            _addToImportant(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.blueAccent),
                          onPressed: () {
                            _deleteTodo(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImportantScreen extends StatelessWidget {
  final List<Todo> importantTodos;
  final Function(int) removeFromImportant;

  ImportantScreen({required this.importantTodos, required this.removeFromImportant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Important Tasks')),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: importantTodos.length,
        itemBuilder: (context, index) {
          final todo = importantTodos[index];
          return Card(
            color: todo.completed ? Colors.green[50] : Colors.red[50],
            child: ListTile(
              title: Text(
                todo.text,
                style: TextStyle(
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.completed ? Colors.green : Colors.red,
                ),
              ),
              leading: Checkbox(
                value: todo.completed,
                onChanged: (bool? value) {
                  // Handle completion in the main screen
                },
                activeColor: Colors.blueAccent,
              ),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.blueAccent),
                onPressed: () {
                  removeFromImportant(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrashScreen extends StatelessWidget {
  final List<DeletedTodo> deletedTodos;
  final Function(int) restoreTodoFromTrash;
  final Function(int) deleteTodoPermanently;

  TrashScreen({
    required this.deletedTodos,
    required this.restoreTodoFromTrash,
    required this.deleteTodoPermanently,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Trash')),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: deletedTodos.length,
              itemBuilder: (context, index) {
                final deletedTodo = deletedTodos[index];
                return Card(
                  child: ListTile(
                    title: Text(deletedTodo.todo.text),
                    subtitle: Text(
                      'Deleted on: ${deletedTodo.deletionDate}',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.restore, color: Colors.blueAccent),
                          onPressed: () {
                            restoreTodoFromTrash(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () {
                            deleteTodoPermanently(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Notes in trash will be automatically deleted after 7 days.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class Todo {
  String text;
  bool completed;

  Todo({
    required this.text,
    required this.completed,
  });
}

class DeletedTodo {
  Todo todo;
  DateTime deletionDate;

  DeletedTodo({
    required this.todo,
    required this.deletionDate,
  });
}
