library CustomSearch;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class CustomSearch extends IDB {
  var _db;
  var dbname, version, request, mode, indexName;

  CustomSearch(String dbname, num version, String request, String mode, String indexName) {
    this.dbname = dbname;
    this.version = version;
    this.request = request;
    this.mode = mode;
    this.indexName = indexName;
  }

  void onDbOpened(Database db) {
    _db = db;
    var trans = _db.transaction(indexName, 'readonly');
    var store = trans.objectStore(indexName);
    var cursors = store.index(mode).openCursor(autoAdvance: false);

    var courseList = querySelector('#search-list').children[0]
          ..children.clear(); // Clear previous DOM

    var count = 0;
    cursors.listen((cursor) {
      if (mode == 'title') {
        if (cursor.value['title'].startsWith(request)) {
          _updateSearchList(cursor);
          count += 1;
        }
      } else if (mode == 'code') {
        if (cursor.value['code'].startsWith(request)) {
          _updateSearchList(cursor);
          count += 1;
        }
      } else if (mode == 'time') {
        var times = cursor.value['time'].trim();
        for (var time in times.split(',')) {
          if (time.startsWith(request)) {
            _updateSearchList(cursor);
            count += 1;
            break;
          }
        }
      }

      if (count == 7) {
        return;
      } else {
        cursor.next();
      }
    });
  }

  void _updateSearchList(var cursor) {
    var courseList = querySelector('#search-list').children[0];

    var courseTitle = new SpanElement()
          ..text = '${cursor.value["title"]}';

     var courseCode = new SpanElement()
          ..text = '課程代碼: ${cursor.value["code"]}';

     var courseContent = new SpanElement()
          ..text = '${cursor.value["professor"]} | 學分數: ${cursor.value["credits"]} | ';
     var courseObligatory = new AnchorElement();
     if (cursor.value["obligatory"] == '必修') {
       courseObligatory.classes.add('obligatory-btn');
     } else if (cursor.value["obligatory"] == '選修') {
       courseObligatory.classes.add('elective-btn');
     }
     courseObligatory
      ..href = '#'
      ..text = cursor.value["obligatory"];
     courseContent.append(courseObligatory);
     // Handle mouse event
     var values = cursor.value;
     courseObligatory.onClick.listen((Event e) {
       Cell.add(values);
     });
     courseObligatory.onMouseOver.listen((Event e) {
       Cell.display(values, 'show');
     });
     courseObligatory.onMouseOut.listen((Event e) {
       Cell.display(values, 'hide');
     });

     var courseElement = new LIElement()
          ..attributes['class'] = 'subject'
          ..attributes['code'] = cursor.value['code']
          ..children.addAll([courseTitle, courseCode, courseContent]);
     courseList.append(courseElement);
  }
}