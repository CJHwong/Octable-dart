library Octable;

import 'dart:html';
import 'dart:convert';
import 'lib/Cell.dart';
import 'lib/CreateDB.dart';
import 'lib/DeptSearch.dart';
import 'lib/CustomSearch.dart';

class Octable {
  var dbname, version, college;

  Octable(String dbname, num version, String college) {
    this.dbname = dbname;
    this.version = version;
    this.college = college;
  }

  void open() {
    this._prepareUI();
    this._loadData();
//    this._selectCollege();
  }

  void _prepareUI() {
    // Dept selection
    querySelector('#dept-select').onChange.listen((Event e) {
      var request = e.target;
      var grade = querySelector('#grade-select');
      grade.value = '0';
      new DeptSearch(dbname, version, request.value, grade.value, college).open();
    });

    // Grade selection
    querySelector('#grade-select').onChange.listen((Event e) {
      var request = querySelector('#dept-select');
      var grade = e.target;
      new DeptSearch(dbname, version, request.value, grade.value, college).open();
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
        new CustomSearch(dbname, version, request.value, mode.value, college).open();
      } else {
        var searchList = querySelector('#search-list')
              ..children[0].children.clear();
      }
    });
  }

//  void _selectCollege() {
//    var body = querySelector('body');
//    var selectDialog = new DivElement()
//          ..classes.add('selectDialog');
//
//    var select = new SelectElement()
//          ..attributes['id'] = 'collegeSelection';
//
//    var colleges = {'中興大學': 'nchu', '成功大學': 'ncku'};
//    for (var college in colleges.keys) {
//      var option = new OptionElement()
//            ..text = college
//            ..value = colleges[college];
//      select.append(option);
//    }
//
//    var submit = new ButtonElement();
//
//    submit.attributes['id'] = 'collegeSubmit';
//    submit.onClick.listen((Event e) {
//      submit.remove();
//      select.remove();
//
//      var loading = new DivElement()
//            ..attributes['id'] = 'loading';
//      selectDialog.append(loading);
//
//      _loadData(select.value);
//    },
//    onDone: () {
//      var loading = querySelector('#loading')
//            ..remove();
//      selectDialog.remove();
//    });
//
//    selectDialog
//      ..append(select)
//      ..append(submit);
//    body.append(selectDialog);
//  }

  void _loadData() {
    Storage localStorage = window.localStorage;
    if (localStorage['dbOpened'] == 'true') {
      print('Loading data from indexedDB');

      new DeptSearch(dbname, version, 'open', '0', college).open();
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
    new CreateDB(dbname, version, JSON.decode(responseText), college).open()
    .then((Event e) {
      new DeptSearch(dbname, version, 'open', '0', college).open();
    });

    Storage localStorage = window.localStorage;
    localStorage['dbOpened'] = 'true';
    localStorage['selectedCourses'] = '{}';
  }
}

void main() {
  new Octable('Octable', 1, 'nchu').open();
}