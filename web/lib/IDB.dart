library IDB;

import 'dart:html';
import 'dart:indexed_db';
import 'dart:async';

class IDB {
  var dbname, version, _db;

  Future open() {
    return window.indexedDB.open(dbname,
      version: version,
      onUpgradeNeeded: initializeDatabase)
      .then(onDbOpened)
      .catchError(onError);
  }

  static void deleteDatabase() {
    window.indexedDB.deleteDatabase('Octable');
  }

  void initializeDatabase(VersionChangeEvent e) {
    // Reserved
  }

  void onDbOpened(Database db) {
    _db = db;
  }

  void onError(e) {
    print('An error occurred: {$e}');
  }
}