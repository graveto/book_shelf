import 'package:book_shelf/widgets/isbn_scanner.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'add_book_screen.dart';
import '../models/book.dart';
import '../helpers/database_helper.dart';
import 'edit_book_screen.dart';
import '../widgets/book_list.dart';
import '../widgets/book_search_bar.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  String searchText = '';
  bool _isScanning = false;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final bookList = await DatabaseHelper.instance.getBooks();

    setState(() {
      books = bookList;
      books.sort((a, b) => int.parse(a.number).compareTo(int.parse(b.number)));
      filteredBooks = List.from(books);
    });
  }

  void _scanISBN() async {
    // Navigate to the ISBNScanner widget
    final isbn = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ISBNScanner(
          onISBNScanned: (isbn) {
            // Handle the scanned ISBN here (e.g., call _fetchAndAddBook)
            _fetchAndAddBook(isbn);
          },
        ),
      ),
    );
  }

  Future<void> _fetchAndAddBook(String isbn) async {
    String title = '';
    String author = '';

    try {
      final response = await http.get(Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['totalItems'] > 0) {
          final bookData = jsonData['items'][0]['volumeInfo'];

          title = bookData['title'] ?? 'Unknown Title';

          if (bookData.containsKey('authors') && bookData['authors'] is List) {
            author = bookData['authors'].join(', ');
          }

          Book book = Book(
              title: title, author: author, isbn: isbn, series: '', number: '');

          await DatabaseHelper.instance.insertBook(book);
          setState(() {
            bool bookExists = books.any((book) => book.isbn == isbn); // ||
            //  filteredBooks.any((book) => book.isbn == isbn);

            if (bookExists) {
              _showSnackBar('You already own this book'); // Show message
            } else {
              books.add(book);
              _showSnackBar('Book added');
            }

            filteredBooks = List.from(books);

            _controller?.stop();
            _isScanning = false;
          });
        } else {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddBookScreen(isbn: isbn),
            ),
          );

          if (newBook != null) {
            // Add the new book to the list
            setState(() {
              books.add(newBook as Book);
              filteredBooks = List.from(books);
              _controller?.stop();
              _isScanning = false;
            });
          }
        }
      } else {
        setState(() {
          _showSnackBar('Error fetching book details');
          _controller?.stop();
          _isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        _showSnackBar('Error: $e');
        _controller?.stop();
        _isScanning = false;
      });
    }
  }

  void _filterBooks(String query) {
    setState(() {
      searchText = query;
      filteredBooks = books
          .where((book) =>
              book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase()) ||
              book.series.toLowerCase().contains(query.toLowerCase()) ||
              book.number.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteBook(Book book) {
    setState(() {
      books.remove(book);
      filteredBooks.remove(book);
    });

    DatabaseHelper.instance.deleteBook(book);
  }

  void _navigateToAddBookScreen() async {
    final newBook = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => AddBookScreen(isbn: ''), // Pass an empty ISBN
      ),
    );

    if (newBook != null) {
      setState(() {
        books.add(newBook as Book);
        filteredBooks = List.from(books);
      });
    }
  }

  void _editBook(Book book) async {
    final updatedBook = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => EditBookScreen(book: book),
      ),
    );

    if (updatedBook != null) {
      setState(() {
        // Find the index of the book to update
        final index = books.indexWhere((b) => b.isbn == updatedBook.isbn);
        if (index != -1) {
          books[index] = updatedBook as Book;
          filteredBooks = List.from(books); // Update filtered list
        }
      });
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
        title: Text(
          'Shelfie',
          style: TextStyle(
            color: Color.fromARGB(
              255,
              28,
              20,
              20,
            ),
          ),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BookSearchBar(onSearchChanged: _filterBooks),
            SizedBox(height: 16),
            Expanded(
              child: BookList(
                books: filteredBooks,
                onDelete: _deleteBook,
                onEdit: _editBook, // Pass the _deleteBook function
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addBookButton', // Unique hero tag
            onPressed: _navigateToAddBookScreen,
            child: Icon(Icons.add),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _scanISBN,
            child: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
