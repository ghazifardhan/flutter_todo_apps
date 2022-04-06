import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertodo/blocs/database.bloc.dart';
import 'package:fluttertodo/blocs/database.state.dart';
import 'package:fluttertodo/blocs/todo.bloc.dart';
import 'package:fluttertodo/blocs/todo.state.dart';

void main() {
  BlocOverrides.runZoned(
    () => runApp(MultiBlocProvider(providers: [
      BlocProvider<DatabaseBloc>(create: (context) => DatabaseBloc()..initDatabase())
    ], child: const MyApp()))
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Todo Apps'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _text = "";
  TodoBloc? _todoBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocConsumer<DatabaseBloc, DatabaseState>(
        listener: (context, state) {
          if (state is LoadDatabaseState) { 
            _todoBloc = TodoBloc(database: context.read<DatabaseBloc>().database!);
          }
        },
        builder: (context, state) {
          if (state is LoadDatabaseState) {
            return BlocProvider<TodoBloc>(
              create: (context) => _todoBloc!..getTodos(),
              child: BlocConsumer<TodoBloc, TodoState>(
                listener: (context, todoState) {},
                builder: (context, todoState) {
                  if (todoState is InitTodoState) {
                    final todos = _todoBloc!.todos;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            maxLines: 1,
                            onChanged: (value) {
                              setState(() {
                                _text = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10.0,),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: todos.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10.0,),
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(child: Text(
                                      todos[index].text,
                                      style: const TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold
                                      ),
                                    )),
                                    IconButton(
                                      onPressed: () {
                                        _todoBloc!.removeTodo(todos[index].id);
                                      }, 
                                      icon: const Icon(Icons.delete)
                                    )
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }

                  return Container();
                },
              )
            );
          }

          return const Center(child: Text('Database not loaded'),);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_todoBloc != null) {
            log(_text);
            _todoBloc!.addTodos(_text);
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
