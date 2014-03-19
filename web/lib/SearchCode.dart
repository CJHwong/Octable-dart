library SearchCode;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class SearchCode extends IDB {
  var dbname, version, _db, request, mode;

  SearchCode(String dbname, num version, String request, String mode) {
    this.dbname = dbname;
    this.version = version;
    this.request = request;
    this.mode = mode;
  }

  void onDbOpened(Database db) {
    _db = db;
    var trans = _db.transaction('Courses', 'readonly');
    var store = trans.objectStore('Courses');
    var cursors = store.index(mode).openCursor(autoAdvance: false);

    var courseList = querySelector('#search-list').children[0];
        courseList.children.clear(); // Clear previous DOM

    var count = 0;
    cursors.listen((cursor) {
      if (mode == 'title') {
        if (cursor.value['title'].startsWith(request)) {
          _addToList(cursor);
          count += 1;
        }
      } else if (mode == 'code') {
        if (cursor.value['code'].startsWith(request)) {
          _addToList(cursor);
          count += 1;
        }
      } else if (mode == 'time') {
        var time = cursor.value['time'].trim();
        time = time.split(',');
        for (var t in time) {
          if (t.startsWith(request)) {
            _addToList(cursor);
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

  void _addToList(var cursor) {
    var cellObj = new Cell();
    var courseList = querySelector('#search-list').children[0];

    var courseTitle = new SpanElement();
     courseTitle.text = '${cursor.value["title"]}';

     var courseCode = new SpanElement();
     courseCode.text = '課程代碼: ${cursor.value["code"]}';

     var courseContent = new SpanElement();
     courseContent.text = '${cursor.value["professor"]} | 學分數: ${cursor.value["credits"]} | ';

     var courseObligatory = new AnchorElement();
     if (cursor.value["obligatory"] == '必修') {
       courseObligatory.classes.add('obligatory-btn');
     } else if (cursor.value["obligatory"] == '選修') {
       courseObligatory.classes.add('elective-btn');
     }
     courseObligatory.href = '#';
     courseObligatory.text = cursor.value["obligatory"];
     courseContent.append(courseObligatory);

     var courseElement = new LIElement();
     courseElement.attributes['class'] = 'subject';
     courseElement.attributes['code'] = cursor.value['code'];
     courseElement.children.addAll([courseTitle, courseCode, courseContent]);

     // Handle mouse event
     var values = cursor.value;
     courseObligatory.onClick.listen((Event e) {
       cellObj.add(values);
     });
     courseObligatory.onMouseOver.listen((Event e) {
       cellObj.display(values, 'show');
     });
     courseObligatory.onMouseOut.listen((Event e) {
       cellObj.display(values, 'hide');
     });

     courseList.append(courseElement);
  }
}