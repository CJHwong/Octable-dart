library Cell;

import 'dart:html';
import 'dart:convert';

class Cell {
  static String SELECTED = '#ADC7C5',
                 CONFLICT = '#FF1C2D',
                 HOVERED = '#D6B86D';

  void add(Map values) {
    var timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0])];
      time = time.substring(1, time.length);

      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');

        if (cell.attributes['code'] != null) {
          return;
        } else {
          var courseContent = new SpanElement();
          courseContent.text = values['title'];
          var course = cell.children[0];
          course.style.backgroundColor = SELECTED;
          course.append(courseContent);

          course.onDoubleClick.listen((Event e) {
            var cell = e.target;
            remove(cell.parent);
          });

          cell.attributes['code'] = values['code'];
          cell.attributes['time'] = values['time'].trim();
        }
      }
    });

    Storage localStorage = window.localStorage;
    if (localStorage['selectedCourses'] == null) {
      var selectedCourses = new Map();
      selectedCourses[values['code']] = values;
      localStorage['selectedCourses'] = JSON.encode(selectedCourses);
    } else {
      var selectedCourses = JSON.decode(localStorage['selectedCourses']);
      selectedCourses[values['code']] = values;
      localStorage['selectedCourses'] = JSON.encode(selectedCourses);
    }
  }

  void remove(var clickedCell) {
    if (clickedCell.attributes['time'] == null) {
      return;
    }

    Storage localStorage = window.localStorage;
    var selectedCourses = JSON.decode(localStorage['selectedCourses']);
    selectedCourses.remove(clickedCell.attributes['code']);
    localStorage['selectedCourses'] = JSON.encode(selectedCourses);

    var timeList = clickedCell.attributes['time'].split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0])];
      time = time.substring(1, time.length);
      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');
        cell.attributes.remove('code');
        cell.attributes.remove('time');
        cell.attributes.remove('style');
        cell.children.clear();
        cell.onDoubleClick.listen((Event e) {}).cancel();
      }
    });
  }

  void display(Map values, String behave) {
      var timeList = values['time'].trim().split(',');
      timeList.forEach((String time) {
        var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
        var day = days[int.parse(time[0])];
        time = time.substring(1, time.length);

        for (var t in time.split('')) {
          var cell = querySelector('#$day' + '-$t');

          if (behave == 'show') {
            var course = cell.children[0];

            if (cell.attributes['code'] != null) {
              if (cell.attributes['code'] == values['code']) {
                return;
              } else {
                course.style.backgroundColor = CONFLICT;
              }
            } else {
              course.style.backgroundColor = HOVERED;
            }
          } else if (behave == 'hide') {
            var course = cell.children[0];

            if (course.innerHtml.isEmpty) {
              course.attributes.remove('style');
            } else {
              course.style.backgroundColor = SELECTED;
            }
          }
        }
      });
    }

  void addSelected() {
    Storage localStorage = window.localStorage;
    Map selectedCourses = JSON.decode(localStorage['selectedCourses']);
    for (var value in selectedCourses.values) {
      add(value);
    }
  }
}