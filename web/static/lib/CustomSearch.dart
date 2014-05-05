library CustomSearch;

import 'dart:html';
import 'dart:async';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class CustomSearch extends IDB {
  Database _db;
  var dbname, version, request, mode;

  CustomSearch(String dbname, num version, String request, String mode) {
    this.dbname = dbname;
    this.version = version;
    this.request = request;
    this.mode = mode;
  }

  void onDbOpened(Database db) {
    _db = db;
    Transaction trans = _db.transaction('Courses', 'readonly');
    ObjectStore store = trans.objectStore('Courses');
    Stream<CursorWithValue> cursors = store.index(mode).openCursor(autoAdvance: false);

    UListElement searchList = querySelector('#search-list').children[0]..children.clear(); // Clear previous DOM

    int count = 0;
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
        String times = cursor.value['time'].trim();
        for (String time in times.split(',')) {
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
    UListElement searchList = querySelector('#search-list').children[0];

    SpanElement courseTitle = new SpanElement()..text = '${cursor.value["title"]}';

    SpanElement courseCode = new SpanElement()..text = '課程代碼: ${cursor.value["code"]}';

    SpanElement courseContent = new SpanElement()..text = '${cursor.value["professor"]} | 學分數: ${cursor.value["credits"]} | ';
    AnchorElement courseObligatory = new AnchorElement();
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
    Map values = cursor.value;
    courseObligatory.onClick.listen((Event e) {
      Cell.add(values);
    });
    courseObligatory.onMouseOver.listen((Event e) {
      Cell.display(values, 'show');
    });
    courseObligatory.onMouseOut.listen((Event e) {
      Cell.display(values, 'hide');
    });

    LIElement courseElement = new LIElement()
        ..attributes['class'] = 'subject'
        ..attributes['code'] = cursor.value['code']
        ..children.addAll([courseTitle, courseCode, courseContent]);
    searchList.append(courseElement);
  }
}
