library DeptSearch;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class DeptSearch extends IDB {
  var _db;
  var dbname, version, request, grade;

  DeptSearch(String dbname, num version, String request, String grade) {
    this.dbname = dbname;
    this.version = version;
    this.request = request;
    this.grade = grade;
  }

  void onDbOpened(Database db) {
    _db = db;
    var trans = _db.transaction('Courses', 'readonly');
    var store = trans.objectStore('Courses');
    var cursors = store.index('department').openCursor(autoAdvance: true);

    List depts = ['請選擇科系']; // Record added dept name
    cursors.listen((cursor) {
      if (!depts.contains(cursor.value['department'])) {
        depts.add(cursor.value['department']);
      }
    },
    onDone: () {
      if (request == 'open') {
        var deptSelect = querySelector('#dept-select')
              ..children.clear();
        for (var dept in depts) {
          var deptName = new OptionElement()
                ..value = dept
                ..text = dept;
          deptSelect.append(deptName);
        }
      } else {
        _updateSearchList(request);
      }
    });
  }

  void _updateSearchList(String dept) {
    var trans = _db.transaction('Courses', 'readonly');
    var store = trans.objectStore('Courses');
    var cursors = store.index('department').openCursor(key: dept, autoAdvance: true);

    var courseList = querySelector('#search-list').children[0]
          ..children.clear(); // Clear previous DOM

    cursors.listen((cursor) {
      if (grade == '0' || cursor.value['grade'] == grade) {
        var courseTitle = new SpanElement()
              ..text = '${cursor.value["title"]}';

        var courseCode = new SpanElement()
              ..text = '課程代碼: ${cursor.value["code"]}';

        var courseContent = new SpanElement()
              ..text = '${cursor.value["professor"]} | 學分數: ${cursor.value["credits"]} | ';
        var courseObligatory = new AnchorElement()
              ..href = '#'
              ..text = cursor.value["obligatory"];
        if (cursor.value["obligatory"] == '必修') {
          courseObligatory.classes.add('obligatory-btn');
        } else if (cursor.value["obligatory"] == '選修') {
          courseObligatory.classes.add('elective-btn');
        }
        // Handle mouse event
        var values = cursor.value;
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

        var courseElement = new LIElement()
              ..attributes['class'] = 'subject'
              ..attributes['code'] = cursor.value['code']
              ..children.addAll([courseTitle, courseCode, courseContent]);
        courseList.append(courseElement);
      }
    });
  }
}