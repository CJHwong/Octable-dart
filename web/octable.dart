library Octable;

import 'dart:html';
import 'dart:convert';
import 'lib/IDB.dart';
import 'lib/Cell.dart';
import 'lib/CreateDB.dart';
import 'lib/SearchDept.dart';
import 'lib/SearchCode.dart';

class Octable {
  var DBNAME, VERSION, COLLEGE;
  var jsonObj;

  Octable(String DBNAME, num VERSION, String COLLEGE) {
    this.DBNAME = DBNAME;
    this.VERSION = VERSION;
    this.COLLEGE = COLLEGE;
  }

  void open() {
    this._prepareUI();
    this._loadData(COLLEGE);
//    this._selectCollege();
  }

  void _prepareUI() {
    // Dept selection
    querySelector('#department').onChange.listen((Event e) {
      var request = e.target;
      var grade = querySelector('#grade');
      grade.value = '0';
      new SearchDept(DBNAME, VERSION, request.value, grade.value).open();
    });

    // Grade selection
    querySelector('#grade').onChange.listen((Event e) {
      var request = querySelector('#department');
      var grade = e.target;
      new SearchDept(DBNAME, VERSION, request.value, grade.value).open();
    });

    // Code searching
    querySelector('#search-input').onInput.listen((Event e) {
      var request = e.target;
      var mode = querySelector('#search-mode');
      if (request.value != "") {
        new SearchCode(DBNAME, VERSION, request.value, mode.value).open();
      } else {
        var searchList = querySelector('#search-list');
        searchList.children[0].children.clear();
      }
    });
  }

  void _selectCollege() {
    var body = querySelector('body');
    var selectDialog = new DivElement();
    selectDialog.classes.add('selectDialog');

    var select = new SelectElement();
    select.attributes['id'] = 'collegeSelection';

    var colleges = {'中興大學': 'nchu', '成功大學': 'ncku'};
    for (var college in colleges.keys) {
      var option = new OptionElement();
      option.text = college;
      option.value = colleges[college];
      select.append(option);
    }

    var submit = new ButtonElement();

    submit.attributes['id'] = 'collegeSubmit';
    submit.onClick.listen((Event e) {
      submit.remove();
      select.remove();

      var loading = new DivElement();
      loading.attributes['id'] = 'loading';
      selectDialog.append(loading);

      _loadData(select.value);
    },
    onDone: () {
      var loading = querySelector('#loading');
      loading.remove();
      selectDialog.remove();
    });

    selectDialog.append(select);
    selectDialog.append(submit);
    body.append(selectDialog);
  }

  void _loadData(String college) {
    if (college != COLLEGE) {
      IDB.deleteDatabase();
      this.COLLEGE = college;
    }
    Storage localStorage = window.localStorage;
    if (localStorage['dbOpened'] == 'true') {
      new SearchDept('Octable', 1, 'open', '0').open();
      var cellObj= new Cell();
      cellObj.addSelected();
    } else {
      print('Downloading JSON from server');
      var host = window.location.host;
      var url = 'http://$host/Octable/web/data/$college/$college.json';
      var request = HttpRequest.getString(url)
          .then(_onDataLoaded);
    }
  }

  void _onDataLoaded(String responseText) {
    jsonObj = JSON.decode(responseText);
    new CreateDB(DBNAME, VERSION, jsonObj).open()
    .then((Event e) {
      new SearchDept('Octable', 1, 'open', '0').open();
    });
    Storage localStorage = window.localStorage;
    localStorage['dbOpened'] = 'true';
    var cellObj= new Cell();
    cellObj.addSelected();
  }
}

void main() {
  new Octable('Octable', 1, 'nchu').open();
}