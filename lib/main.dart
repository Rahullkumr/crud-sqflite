// lib/main.dart

import 'package:flutter/material.dart';
import 'helpers/db_helper.dart';
import 'models/student.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student CRUD App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StudentListPage(),
    );
  }
}

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  late Future<List<Student>> _studentList;

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  _refreshStudentList() {
    setState(() {
      _studentList = DBHelper().getStudents();
    });
  }

  _showForm({Student? student}) {
    final _nameController = TextEditingController(text: student?.name ?? '');
    final _ageController =
        TextEditingController(text: student?.age.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
                return;
              }
              if (student == null) {
                DBHelper().insertStudent(Student(
                  name: _nameController.text,
                  age: int.parse(_ageController.text),
                ));
              } else {
                DBHelper().updateStudent(Student(
                  id: student.id,
                  name: _nameController.text,
                  age: int.parse(_ageController.text),
                ));
              }
              _refreshStudentList();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  _deleteStudent(int id) {
    DBHelper().deleteStudent(id);
    _refreshStudentList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student CRUD App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No students found.',
                style: TextStyle(fontSize: 30),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final student = snapshot.data![index];
                return ListTile(
                  title: Text(student.name),
                  subtitle: Text('Age: ${student.age}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showForm(student: student);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteStudent(student.id!);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
