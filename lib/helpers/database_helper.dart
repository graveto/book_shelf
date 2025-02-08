import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseHelper {
  static final _databaseName = "book_database.db";
  static final _databaseVersion = 1;

  static final table = 'books';

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnAuthor = 'author';
  static final columnIsbn = 'isbn';
  static final columnSeries = 'series';
  static final columnNumber = 'number';

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database!= null) return _database!;
    // Lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // This opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnAuthor TEXT NOT NULL,
            $columnIsbn TEXT NOT NULL,
            $columnSeries TEXT NOT NULL,
            $columnNumber TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId =?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId =?', whereArgs: [id]);
  }

  // Convert a Book object to a map
  Map<String, dynamic> _bookToMap(Book book) {
    return {
      columnTitle: book.title,
      columnAuthor: book.author,
      columnIsbn: book.isbn,
      columnSeries: book.series,
      columnNumber: book.number,
    };
  }

  // Convert a list of Book objects to a list of maps
  List<Map<String, dynamic>> _bookListToMapList(List<Book> books) {
    return books.map((book) => _bookToMap(book)).toList();
  }

  // Convert a map to a Book object
  Book _mapToBook(Map<String, dynamic> map) {
    return Book(
      title: map[columnTitle],
      author: map[columnAuthor],
      isbn: map[columnIsbn],
      series: map[columnSeries],
      number: map[columnNumber],
    );
  }

  // Convert a list of maps to a list of Book objects
  List<Book> _mapListToBookList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => _mapToBook(map)).toList();
  }

  // Insert a book into the database
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      table,
      _bookToMap(book),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all books from the database
  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return _mapListToBookList(maps);
  }

  // Update a book in the database
  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      table,
      _bookToMap(book),
      where: '$columnIsbn =?',
      whereArgs: [book.isbn],
    );
  }

  // Delete a book from the database
  Future<void> deleteBook(Book book) async {
    final db = await database;
    await db.delete(
      table,
      where: '$columnIsbn =?',
      whereArgs: [book.isbn],
    );
  }
}