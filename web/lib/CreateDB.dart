library CreateDB;

import 'dart:indexed_db';
import 'IDB.dart';

class CreateDB extends IDB {
  var dbname, version, _db, jsonObj, indexName;
  var keys = ['obligatory', 'code', 'title', 'credits', 'time',
              'grade', 'professor', 'language', 'note', 'department'];

  CreateDB(String dbname, num version, var jsonObj, String indexName) {
    this.dbname = dbname;
    this.version = version;
    this.jsonObj = jsonObj;
    this.indexName = indexName;
  }

  void initializeDatabase(VersionChangeEvent e) {
    Database db = (e.target as Request).result;

    var objectStore = db.createObjectStore(indexName, autoIncrement: true);
    for (var NAME_INDEX in keys) {
      var index = objectStore.createIndex(NAME_INDEX, NAME_INDEX, unique: false);
    }
    for (var data in jsonObj) {
      objectStore.add(data);
    }
  }
}