library UI;

import 'dart:html';
import 'dart:convert';
import 'Cell.dart';
import 'CreateDB.dart';
import 'DeptSearch.dart';
import 'CustomSearch.dart';
import 'ExportSVG.dart';
import 'LocalStorage.dart';

class UI {
  var _college, _version;
  Map _colleges = {
    'nchu': '中興大學',
    'ncku': '成功大學',
    'ntnu': '台灣師範大學'
  };

  UI({String college, num version}) {
    if (!LocalStorage.has('college')) {
      LocalStorage.set('college', college);
    }
    this._college = LocalStorage.get('college');
    this._version = version;
  }

  void load() {
    this._addEventListener();
    this._loadData();
  }

  void _addEventListener() {
    // Dept selection
    querySelector('#dept-select').onChange.listen((Event e) {
      SelectElement request = e.target;
      SelectElement grade = querySelector('#grade-select');
      grade.value = '0';
      new DeptSearch(_college, _version, request.value, grade.value).open();
    });

    // Grade selection
    querySelector('#grade-select').onChange.listen((Event e) {
      SelectElement request = querySelector('#dept-select');
      SelectElement grade = e.target;
      new DeptSearch(_college, _version, request.value, grade.value).open();
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
        new CustomSearch(_college, _version, request.value, mode.value).open();
      } else {
        DivElement searchList = querySelector('#search-list')..children[0].children.clear();
      }
    });

    // College selection
    if (!LocalStorage.has('dbOpened')) {
      LocalStorage.set('dbOpened', '{}');
    }

    SelectElement collegeSelect = querySelector('#college-select');
    for (String key in _colleges.keys) {
      OptionElement opt = new OptionElement()
          ..value = key
          ..text = _colleges[key];
      collegeSelect.append(opt);
    }
    collegeSelect.value = LocalStorage.get('college');
    querySelector('#college-select').onChange.listen((Event e) {
      print('Changing college...');
      SelectElement option = e.target;
      _college = option.value;
      LocalStorage.set('college', option.value);
      _loadData();
    });

    // Export button
    querySelector('#export-btn')..onClick.listen((Event e) {
          ExportSVG.download();
        });
  }

  void showPopup(Element element, bool removable) {
    BodyElement body = querySelector('body')..style.overflow = 'hidden';
    DivElement container = new DivElement()
        ..id = 'popup-container'
        ..append(element);
    if (removable) {
        container.onClick.listen((Event e) {
          DivElement popupContainer = querySelector('#popup-container');
          popupContainer.remove();
          body.attributes.remove('style');
        });
    }
    body.append(container);
  }

  void removePopup() {
    BodyElement body = querySelector('body');
    DivElement container = querySelector('#popup-container');
    if (container != null) {
      container.remove();
    }
    body.attributes.remove('style');
  }

  void _loadingAnimation() {
    DivElement shape = new DivElement();
    shape.id = 'circleG';
    for (int i = 1; i <= 3; i++) {
      DivElement block = new DivElement()
      ..className = 'circleG'
      ..id = 'circleG_' + i.toString();
      shape.append(block);
    }
    shape.append(new SpanElement()..text = 'Loading courses');
    showPopup(shape, false);
  }

  void _loadData() {
    Map dbOpened = JSON.decode(LocalStorage.get('dbOpened'));
    if (dbOpened.keys.contains(_college)) {
      print('Loading data from indexedDB...');
      new DeptSearch(_college, _version, 'open', '0').open();
      Cell.addSelected();
    } else {
      print('Downloading JSON from server...');
      _loadingAnimation();
      String host = window.location.host;
      String url = "";
      print(host);
      if (host == '127.0.0.1:3030') {
        url = 'http://$host/Octable/web/static/data/$_college/$_college.json';
      } else {
        url = 'http://$host/static/data/$_college/$_college.json';
      }
      HttpRequest.getString(url).then(_onDataLoaded);
    }
  }

  void _onDataLoaded(String responseText) {
    new CreateDB(_college, _version, JSON.decode(responseText)).open().then((Event e) {
      new DeptSearch(_college, _version, 'open', '0').open();
      Map dbOpened = JSON.decode(LocalStorage.get('dbOpened'));
      dbOpened[_college] = '';
      LocalStorage.set('dbOpened', JSON.encode(dbOpened));
      LocalStorage.set('selectedCourses', '{}');
      removePopup();
    });
    print('Done');
  }
}
