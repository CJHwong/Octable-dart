library SearchDept;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';
import 'Cell.dart';

class SearchDept extends IDB {
  var dbname, version, _db, request, grade;

  SearchDept(String dbname, num version, String request, String grade) {
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

    var depts = []; // Record added dept name
    cursors.listen((cursor) {
      if (!depts.contains(cursor.value['department'])) {
        depts.add(cursor.value['department']);
      }
    },
    onDone: () {
      if (request == 'open') {
        _addToCourseList(depts[0]);
        for (var dept in depts) {
          _addToDeptSelect(dept);
        }
      } else {
        _addToCourseList(request);
      }
    });
  }

  void _addToDeptSelect(String dept) {
    var deptSelect = querySelector('#department');
    var deptName = new OptionElement();
    deptName.value = dept;
    deptName.text = dept;
    deptSelect.append(deptName);
  }

  void _addToCourseList(String dept) {
    var trans = _db.transaction('Courses', 'readonly');
    var store = trans.objectStore('Courses');
    var cursors = store.index('department').openCursor(key: dept, autoAdvance: true);

    var courseList = querySelector('#dept-search-list').children[0];
    courseList.children.clear(); // Clear previous DOM

    cursors.listen((cursor) {
      var cellObj = new Cell();

      if (grade == '0' || cursor.value['grade'] == grade) {
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
    });
  }
}