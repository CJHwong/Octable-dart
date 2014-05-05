library Octable;

import 'dart:html';
import 'dart:convert';
import 'lib/Cell.dart';
import 'lib/CreateDB.dart';
import 'lib/DeptSearch.dart';
import 'lib/CustomSearch.dart';
import 'lib/ExportSVG.dart';
import 'lib/Facebook.dart';

class Octable {
  var college, version;

  Octable(String college, num version) {
    Storage localStorage = window.localStorage;
    if (localStorage['college'] == null) {
      localStorage['college'] = college;
    }
    this.college = localStorage['college'];
    this.version = version;
  }

  void open() {
    this._prepareUI();
    this._loadData();
  }

  void _prepareUI() {
    // Dept selection
    querySelector('#dept-select').onChange.listen((Event e) {
      SelectElement request = e.target;
      SelectElement grade = querySelector('#grade-select');
      grade.value = '0';
      new DeptSearch(college, version, request.value, grade.value).open();
    });

    // Grade selection
    querySelector('#grade-select').onChange.listen((Event e) {
      SelectElement request = querySelector('#dept-select');
      SelectElement grade = e.target;
      new DeptSearch(college, version, request.value, grade.value).open();
    });

    // Code searching
    querySelector('#search-input').onInput.listen((Event e) {
      SelectElement deptSelect = querySelector('#dept-select');
      deptSelect.value = '請選擇科系';
      SelectElement gradeSelect = querySelector('#grade-select');
      gradeSelect.value = '0';

      InputElement request = e.target;
      SelectElement mode = querySelector('#search-mode');
      if (request.value != "") {
        new CustomSearch(college, version, request.value, mode.value).open();
      } else {
        UListElement searchList = querySelector('#search-list')..children[0].children.clear();
      }
    });

    // College selection
    Storage localStorage = window.localStorage;
    if (localStorage['dbOpened'] == null) {
      localStorage['dbOpened'] = '{}';
    }
    Map colleges = {
      'nchu': '中興大學',
      'ncku': '成功大學',
      'ntnu': '台灣師範大學'
    };
    SelectElement collegeSelect = querySelector('#college-select');
    for (String key in colleges.keys) {
      OptionElement opt = new OptionElement()
          ..value = key
          ..text = colleges[key];
      collegeSelect.append(opt);
    }
    collegeSelect.value = localStorage['college'];
    querySelector('#college-select').onChange.listen((Event e) {
      print('Changing college...');
      SelectElement option = e.target;
      this.college = option.value;
      localStorage['college'] = option.value;
      _loadData();
    });

    // Export button
    ButtonElement exportBtn = querySelector('#export-btn')..onClick.listen((Event e) {
          var exportContent = ExportSVG.createTable().outerHtml;
          Blob blob = new Blob([exportContent]);
          AnchorElement downloadSvg = new AnchorElement()
              ..text = 'Export'
              ..href = Url.createObjectUrlFromBlob(blob)
              ..attributes['download'] = 'timetatable.svg'
              ..dispatchEvent(new CustomEvent('click'));
        });
  }

  void _loadData() {
    SelectElement collegeSelect = querySelector('#college-select');
    Storage localStorage = window.localStorage;
    Map dbOpened = JSON.decode(localStorage['dbOpened']);
    if (dbOpened.keys.contains(college)) {
      print('Loading data from indexedDB...');
      new DeptSearch(college, version, 'open', '0').open();
      Cell.addSelected();
    } else {
      print('Downloading JSON from server...');

      String host = window.location.host;
      String url = 'http://$host/Octable/web/static/data/$college/$college.json';
      var request = HttpRequest.getString(url).then(_onDataLoaded);
    }
  }

  void _onDataLoaded(String responseText) {
    new CreateDB(college, version, JSON.decode(responseText)).open().then((Event e) {
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
  Facebook.prepare();
  print(ExportSVG.toDataUrl());
}