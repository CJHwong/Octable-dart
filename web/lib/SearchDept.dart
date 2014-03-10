library SearchDept;

import 'dart:html';
import 'dart:indexed_db';
import 'IDB.dart';

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

    var obligatory = querySelector('#obligatory').children[0];
    var elective = querySelector('#elective').children[0];

    // Clear previous DOM
    obligatory.children.clear();
    elective.children.clear();

    cursors.listen((cursor) {
      if (grade == '0' || cursor.value['grade'] == grade) {
        var courseTitle = new SpanElement();
        courseTitle.text = cursor.value['title'];

        var courseContent = new SpanElement();
        courseContent.text = '授課教師: ' + cursor.value['professor'] + '學分數: ' + cursor.value['credits'];

        var courseElement = new LIElement();
        courseElement.attributes['class'] = 'subject';
        courseElement.attributes['code'] = cursor.value['code'];
        courseElement.children.addAll([courseTitle, courseContent]);

        // Handle mouse event
        var values = cursor.value;
        courseElement.onClick.listen((Event e) {
          _addCell(values);
        });
        courseElement.onMouseOver.listen((Event e) {
          _displayCell(values, 'show');
        });
        courseElement.onMouseOut.listen((Event e) {
          _displayCell(values, 'hide');
        });

        if (cursor.value['obligatory'] == '必修') {
          obligatory.append(courseElement);
        } else if (cursor.value['obligatory'] == '選修') {
          elective.append(courseElement);
        }
      }
    });
  }

  void _addCell(Map values) {
    var timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0])];
      time = time.substring(1, time.length);

      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');
        if (cell.innerHtml != "") {
          return;
        } else {
          var courseContent = new SpanElement();
          courseContent.text = values['code'] + ' ' + values['title'];
          cell.attributes['code'] = values['code'];
          cell.attributes['time'] = values['time'].trim();
          cell.classes.add('activedCell');
          cell.append(courseContent);

          cell.onClick.listen((Event e) {
            var cell = e.target;
            _removeCell(cell);
          });
        }
      }
    });
  }

  void _removeCell(var clickedCell) {
    var timeList = clickedCell.attributes['time'].split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0])];
      time = time.substring(1, time.length);
      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');
        cell.attributes.remove('code');
        cell.attributes.remove('time');
        cell.classes.remove('activedCell');
        cell.children.clear();
      }
    });
  }

  void _displayCell(Map values, String behave) {
    var timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0])];
      time = time.substring(1, time.length);

      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');

        if (behave == 'show') {
          if (cell.innerHtml != "") {
            if (cell.attributes['code'] == values['code']) {
              return;
            } else {
              cell.style.backgroundColor = '#FF1C2D';
            }
          } else {
            cell.style.backgroundColor = '#ADC7C5';
          }
        } else if (behave == 'hide') {
          cell.attributes.remove('style');
        }
      }
    });
  }
}