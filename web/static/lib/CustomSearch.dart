library CustomSearch;

import 'dart:html';
import 'dart:async';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class CustomSearch extends IDB {
  Database _db;
  var dbname, version, _request, _mode;

  CustomSearch(String dbname, num version, String request, String mode) {
    this.dbname = dbname;
    this.version = version;
    this._request = request;
    this._mode = mode;
  }

  void onDbOpened(Database db) {
    _db = db;
    Transaction trans = _db.transaction('Courses', 'readonly');
    ObjectStore store = trans.objectStore('Courses');
    Stream<CursorWithValue> cursors = store.index(_mode).openCursor(autoAdvance: false);

    UListElement searchList = querySelector('#search-list').children[0]..children.clear(); // Clear previous DOM

    int count = 0;
    cursors.listen((cursor) {
      if (_mode == 'title') {
        if (cursor.value['title'].startsWith(_request)) {
          _updateSearchList(cursor);
          count += 1;
        }
      } else if (_mode == 'code') {
        if (cursor.value['code'].startsWith(_request)) {
          _updateSearchList(cursor);
          count += 1;
        }
      } else if (_mode == 'time') {
        String times = cursor.value['time'].trim();
        for (String time in times.split(',')) {
          if (time.startsWith(_request)) {
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

    LIElement courseElement = new LIElement()
            ..attributes['class'] = 'subject'
            ..attributes['code'] = cursor.value['code'];

    // Handle mouse event
    Map values = cursor.value;
    courseElement.onClick.listen((Event e) {
      Cell.add(values);
    });
    courseElement.onMouseOver.listen((Event e) {
      Cell.display(values, 'show');
    });
    courseElement.onMouseOut.listen((Event e) {
      Cell.display(values, 'hide');
    });

    courseElement
        ..children.addAll([courseTitle, courseCode, courseContent]);
    searchList.append(courseElement);
  }
}
