import 'package:cbl/cbl.dart';

import '../model/user_model.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> openDatabase() async {
    if (_database != null) return _database!;
    _database = await Database.openAsync('my_database');
    return _database!;
  }

  static Future<void> addUser(User user) async {
    final db = await openDatabase();
    final doc = MutableDocument(user.toMap());
    await db.saveDocument(doc);
  }

  static Future<void> getUsers() async {
    final db = await openDatabase();
    print('Database path: ${db.path}');
  }


  Future<void> checkthecouchsetup() async {
    // Open the database (creating it if it doesn’t exist).
    final database = await Database.openAsync('database');

    // Create a collection, or return it if it already exists.
    final collection = await database.createCollection('components');

    // Create a new document.
    final mutableDocument = MutableDocument({'type': 'SDK', 'majorVersion': 2});
    await collection.saveDocument(mutableDocument);

    print(
      'Created document with id ${mutableDocument.id} and '
          'type ${mutableDocument.string('type')}.',
    );

    // Update the document.
    mutableDocument.setString('Dart', key: 'language');
    await collection.saveDocument(mutableDocument);

    print(
      'Updated document with id ${mutableDocument.id}, '
          'adding language ${mutableDocument.string("language")!}.',
    );

    // Read the document.
    final document = (await collection.document(mutableDocument.id))!;

    print(
      'Read document with id ${document.id}, '
          'type ${document.string('type')} and '
          'language ${document.string('language')}.',
    );

    // Create a query to fetch documents of type SDK.
    print('Querying Documents of type=SDK.');
    final query = await database.createQuery('''
    SELECT * FROM components
    WHERE type = 'SDK'
  ''');

    // Run the query.
    final result = await query.execute();
    final results = await result.allResults();
    print('Number of results: ${results.length}');

    // Close the database.
    await database.close();
  }
}
