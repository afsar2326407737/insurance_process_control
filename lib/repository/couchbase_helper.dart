import 'package:cbl/cbl.dart';

class CouchbaseHelper {
  static Database? _db;

  Future<Database> initCouchbase() async {
    _db ??= await Database.openAsync('inspections_db');
    return _db!;
  }

  static Database get db {
    if (_db == null) {
      throw Exception('Database not initialized. Call initCouchbase() first.');
    }
    return _db!;
  }
}