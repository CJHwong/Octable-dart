library SearchCode;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';

class SearchCode extends IDB {
  var dbname, version, _db, request;

  SearchCode(String dbname, num version, String request) {
    this.dbname = dbname;
    this.version = version;
    this.request = request;
  }

  void onDbOpened(Database db) {
    _db = db;
    var trans = _db.transaction('Courses', 'readonly');
    var store = trans.objectStore('Courses');
    var cursors = store.index('code').openCursor(autoAdvance: false);

    var result = querySelector('#searchResult').children[0];

    var count = 0;
    cursors.listen((cursor) {
      if (cursor.value['code'].startsWith(request)) {
        var courseElement = new LIElement();
        var courseTitle = new SpanElement();
        courseTitle.text = cursor.value['title'];

        var courseContent = new SpanElement();
        courseContent.text = '課程代碼: ' + cursor.value['code'];

        courseElement.children.addAll([courseTitle, courseContent]);
        result.children.add(courseElement);
        count += 1;
      }

      if (count == 5) {
        return;
      } else {
        cursor.next();
      }
    });
  }
}