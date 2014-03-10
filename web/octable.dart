library Octable;

import 'dart:html';
import 'dart:convert';
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
  }

  void _prepareUI() {
    var collegeSelect = querySelector('#school');
    collegeSelect.value = COLLEGE;
    collegeSelect.onChange.listen((Event e) {
      var select = e.target;
      this.COLLEGE = select.value;
    }, onDone: () {
      _loadData(COLLEGE);
    });

    // Sidebar display
    var sidebar = querySelector('#sidebar');
    querySelector('#show-sidebar').onClick.listen((Event e) {
      sidebar.style.right = '0px';
    });
    querySelector('#hide-sidebar').onClick.listen((Event e) {
      sidebar.attributes.remove('style');
    });

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
    querySelector('#searchCode').onInput.listen((Event e) {
      var request = e.target;
      querySelector('#searchList').children.clear();
      if (request.value != "") {
        new SearchCode(DBNAME, VERSION, request.value).open();
        querySelector('#searchResult').style.display = 'block';
        querySelector('#searchList').style.display = 'inline-block';
      } else {
        querySelector('#searchResult').attributes.remove('style');
        querySelector('#searchList').attributes.remove('style');
      }
    });

    /*
    // College selection
    querySelector('#school').value = COLLEGE;
    querySelector('#school').onChange.listen((Event e) {
      var option = e.target;
      this.COLLEGE = option.value;
      _loadData(COLLEGE);
    });
    */
  }

  void _loadData(String college) {
    var host = window.location.host;
    var url = 'http://$host/Octable/web/data/$college/$college.json';
    var request = HttpRequest.getString(url)
        .then(_onDataLoaded);
  }

  void _onDataLoaded(String responseText) {
    jsonObj = JSON.decode(responseText);
    new CreateDB(DBNAME, VERSION, jsonObj).open()
    .then((Event e) {
      new SearchDept('Octable', 1, 'open', '0').open();
    });
  }
}

void main() {
  new Octable('Octable', 1, 'nchu').open();
}