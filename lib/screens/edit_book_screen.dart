// File: edit_book_screen.dart
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../helpers/database_helper.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  EditBookScreen({required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _isbnController = TextEditingController(text: widget.book.isbn);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final updatedBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text, // Keep the ISBN same
      );

      DatabaseHelper.instance.updateBook(updatedBook); // Update in database

      Navigator.of(context).pop(updatedBook); // Return the updated book data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
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
                enabled: false, // Make ISBN field read-only
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}