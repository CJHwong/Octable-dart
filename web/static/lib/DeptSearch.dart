library DeptSearch;

import 'dart:html';
import 'dart:async';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class DeptSearch extends IDB {
  Database _db;
  var dbname, version, _request, _grade;

  DeptSearch(String dbname, num version, String request, String grade) {
    this.dbname = dbname;
    this.version = version;
    this._request = request;
    this._grade = grade;
  }

  void onDbOpened(Database db) {
    _db = db;
    Transaction trans = _db.transaction('Courses', 'readonly');
    ObjectStore store = trans.objectStore('Courses');
    Stream<CursorWithValue> cursors = store.index('department').openCursor(autoAdvance: true);

    List depts = ['請選擇科系']; // Record added dept name
    cursors.listen((cursor) {
      if (!depts.contains(cursor.value['department'])) {
        depts.add(cursor.value['department']);
      }
    }, onDone: () {
      if (_request == 'open') {
        SelectElement deptSelect = querySelector('#dept-select')..children.clear();
        for (String dept in depts) {
          OptionElement deptName = new OptionElement()
              ..value = dept
              ..text = dept;
          deptSelect.append(deptName);
        }
      } else {
        _updateSearchList(_request);
      }
    });
  }

  void _updateSearchList(String dept) {
    Transaction trans = _db.transaction('Courses', 'readonly');
    ObjectStore store = trans.objectStore('Courses');
    Stream<CursorWithValue> cursors = store.index('department').openCursor(key: dept, autoAdvance: true);

    UListElement searchList = querySelector('#search-list').children[0]..children.clear(); // Clear previous DOM

    cursors.listen((cursor) {
      if (_grade == '0' || cursor.value['grade'] == _grade) {
        SpanElement courseTitle = new SpanElement()..text = '${cursor.value["title"]}';

        SpanElement courseCode = new SpanElement()..text = '課程代碼: ${cursor.value["code"]}';

        SpanElement courseContent = new SpanElement()..text = '${cursor.value["professor"]} | 學分數: ${cursor.value["credits"]} | ';
        AnchorElement courseObligatory = new AnchorElement()
            ..href = '#'
            ..text = cursor.value["obligatory"];
        if (cursor.value["obligatory"] == '必修') {
          courseObligatory.classes.add('obligatory-btn');
        } else if (cursor.value["obligatory"] == '選修') {
          courseObligatory.classes.add('elective-btn');
        }
        // Handle mouse event
        Map values = cursor.value;
        courseObligatory
            ..onClick.listen((Event e) {
              Cell.add(values);
            })
            ..onMouseOver.listen((Event e) {
              Cell.display(values, 'show');
            })
            ..onMouseOut.listen((Event e) {
              Cell.display(values, 'hide');
            });
        courseContent.append(courseObligatory);

        LIElement courseElement = new LIElement()
            ..attributes['class'] = 'subject'
            ..attributes['code'] = cursor.value['code']
            ..children.addAll([courseTitle, courseCode, courseContent]);
        searchList.append(courseElement);
      }
    });
  }
}
