import 'package:flutter/material.dart';
import 'package:todolistapp/models/colors.dart';
import 'package:todolistapp/data/database.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = MyDatabase();
  TextEditingController titleTEC = TextEditingController();
  TextEditingController detailTEC = TextEditingController();

  Future insert(String title, String detail) async => await database
      .into(database.todoItems)
      .insert(TodoItemsCompanion.insert(title: title, detail: detail));

  Future<List<TodoItem>> getAll() => database.select(database.todoItems).get();

  Future update(TodoItem todoItem, String newTitle, String newDetail) async =>
      await database.update(database.todoItems).replace(
          TodoItem(id: todoItem.id, title: newTitle, detail: newDetail));

  Future delete(TodoItem todoItem) async =>
      await database.delete(database.todoItems).delete(todoItem);

  void todoDialog(TodoItem? todoItem) {
    if (todoItem != null) {
      titleTEC.text = todoItem.title;
      detailTEC.text = todoItem.detail;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            content: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '${todoItem != null ? 'Detail' : 'Tambah'} Todo',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Judul',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: detailTEC,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Detail',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (todoItem != null) {
                              update(todoItem, titleTEC.text, detailTEC.text);
                            } else {
                              insert(titleTEC.text, detailTEC.text);
                            }
                            setState(() {});
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            titleTEC.clear();
                            detailTEC.clear();
                          },
                          child: const Text(
                            'Simpan',
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: customGrenn,
        title: const Text(
          'Todolist App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<TodoItem>>(
          future: getAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: ((context, index) {
                    return Card(
                      child: ListTile(
                        onTap: () {
                          todoDialog(snapshot.data![index]);
                        },
                        title: Text(snapshot.data![index].title),
                        subtitle: Text(snapshot.data![index].detail),
                        trailing: ElevatedButton(
                          onPressed: () {
                            delete(snapshot.data![index]);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(Icons.delete),
                        ),
                      ),
                    );
                  }),
                );
              } else {
                return const Center(
                  child: Text('Belum Ada Data'),
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleTEC.clear();
          detailTEC.clear();
          todoDialog(null);
        },
        backgroundColor: customGrenn,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
