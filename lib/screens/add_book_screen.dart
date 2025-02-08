import 'package:flutter/material.dart';
import '../models/book.dart';
import '../helpers/database_helper.dart';

class AddBookScreen extends StatefulWidget {
  final String isbn;

  const AddBookScreen({super.key, required this.isbn});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late var _titleController = TextEditingController();
  late var _authorController = TextEditingController();
  late TextEditingController _isbnController;
  late var _seriesController = TextEditingController();
  late var _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isbnController =
        TextEditingController(text: widget.isbn); // Initialize with ISBN
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _seriesController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: widget.isbn,
        series: _seriesController.text,
        number: _numberController.text,
      );

      DatabaseHelper.instance.insertBook(newBook); // Add to database

      Navigator.of(context).pop(newBook); // Return the new book data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
        255,
        140,
        140,
        140,
      ),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          'Add Book Manually',
          style: TextStyle(
            color: Color.fromARGB(
              255,
              28,
              20,
              20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'ISBN'),
                controller: _isbnController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the ISBN';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the title';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Author'),
                controller: _authorController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the author';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Series'),
                controller: _seriesController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Series';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Book Number'),
                controller: _numberController,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
