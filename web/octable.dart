library Octable;

import 'dart:html';
import 'dart:convert';
import 'lib/Cell.dart';
import 'lib/CreateDB.dart';
import 'lib/DeptSearch.dart';
import 'lib/CustomSearch.dart';

class Octable {
  var college, version;

  Octable(String college, num version) {
    this.college = college;
    this.version = version;
  }

  void open() {
    this._prepareUI();
    this._loadData();
  }

  void _prepareUI() {
    // Dept selection
    querySelector('#dept-select').onChange.listen((Event e) {
      var request = e.target;
      var grade = querySelector('#grade-select');
      grade.value = '0';
      new DeptSearch(college, version, request.value, grade.value).open();
    });

    // Grade selection
    querySelector('#grade-select').onChange.listen((Event e) {
      var request = querySelector('#dept-select');
      var grade = e.target;
      new DeptSearch(college, version, request.value, grade.value).open();
    });

    // Code searching
    querySelector('#search-input').onInput.listen((Event e) {
      var deptSelect = querySelector('#dept-select');
      deptSelect.value = '請選擇科系';
      var gradeSelect = querySelector('#grade-select');
      gradeSelect.value = '0';

      var request = e.target;
      var mode = querySelector('#search-mode');
      if (request.value != "") {
        new CustomSearch(college, version, request.value, mode.value).open();
      } else {
        var searchList = querySelector('#search-list')
              ..children[0].children.clear();
      }
    });

    // College selection
    Storage localStorage = window.localStorage;
    if (localStorage['dbOpened'] == null) {
      localStorage['dbOpened'] = '{}';
    }
    var colleges = {'nchu': '中興大學', 'ncku': '成功大學'};
    var collegeSelect = querySelector('#college-select');
    for (var key in colleges.keys) {
      var opt = new OptionElement()
            ..value = key
            ..text = colleges[key];
      collegeSelect.append(opt);
    }
    collegeSelect.value = college;
    querySelector('#college-select').onChange.listen((Event e) {
      print('Changing college...');
      var option = e.target;
      this.college = option.value;
      _loadData();
    });

    // Touch events
    var currentColumn = 0;
    var touchStartX, touchStartY;
    var touchDistanceX, touchDistanceY;
    var threshold = 50;

    var column = querySelectorAll('.column')
          ..onTouchStart.listen((TouchEvent e) {
            touchDistanceX = 0;
            touchDistanceY = 0;

            var touchObj = e.changedTouches[0];
            touchStartX = touchObj.page.x;
            touchStartY = touchObj.page.y;

            e.preventDefault();
          })
          ..onTouchMove.listen((TouchEvent e) {
            //e.preventDefault();
          })
          ..onTouchEnd.listen((TouchEvent e) {
            var touchObj = e.changedTouches[0];
            touchDistanceX = touchObj.page.x - touchStartX;
            touchDistanceY = touchObj.page.y - touchStartY;

            if (touchDistanceY < 50 && touchDistanceX < -100) {
              var columns = ['Mon', 'Tue', 'Wed', 'Thr',
                             'Fri', 'Sat', 'Sun'];
              if (currentColumn == 6) {
                return;
              }
              querySelector('#' + columns[currentColumn])
                ..style.display = 'none';
              currentColumn += 1;
              querySelector('#' + columns[currentColumn])
                ..style.display = 'inline-block';
                //..style.left = '0px';
            } else if (touchDistanceY < 50 && touchDistanceX > 100) {
              var columns = ['Mon', 'Tue', 'Wed', 'Thr',
                             'Fri', 'Sat', 'Sun'];
              if (currentColumn == 0) {
                return;
              }
              querySelector('#' + columns[currentColumn])
                ..attributes.remove('style');
              currentColumn -= 1;
              querySelector('#' + columns[currentColumn])
                ..style.display = 'inline-block';
            } else {
              print('top or down');
            }

            e.preventDefault();
          });
  }

  void _loadData() {
    var collegeSelect = querySelector('#college-select');
    Storage localStorage = window.localStorage;
    Map dbOpened = JSON.decode(localStorage['dbOpened']);
    if (dbOpened.keys.contains(college)) {
      print('Loading data from indexedDB...');
      new DeptSearch(college, version, 'open', '0').open();
      Cell.addSelected();
    } else {
      print('Downloading JSON from server...');

      var host = window.location.host;
      var url = 'http://$host/Octable/web/data/$college/$college.json';
      var request = HttpRequest.getString(url)
          .then(_onDataLoaded);
    }
  }

  void _onDataLoaded(String responseText) {
    new CreateDB(college, version, JSON.decode(responseText)).open()
    .then((Event e) {
      new DeptSearch(college, version, 'open', '0').open();
    });

    Storage localStorage = window.localStorage;
    Map dbOpened = JSON.decode(localStorage['dbOpened']);
    dbOpened[college] = '';
    localStorage['dbOpened'] = JSON.encode(dbOpened);
    localStorage['selectedCourses'] = '{}';
  }
}

void main() {
  new Octable('nchu', 1).open();
}