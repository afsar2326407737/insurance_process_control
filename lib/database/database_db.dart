import 'package:cbl/cbl.dart';

class DatabaseDB {

  late Database db;
  // initialize the db
  Future<void> initdb() async{
    db = await Database.openAsync('inspection_db');
  }

  // close the db
  Future<void> close() async{
    db.close();
  }
}