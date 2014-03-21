library Cell;

import 'dart:html';
import 'dart:convert';

class Cell {
  static final String SELECTED = '#ADC7C5',
                       CONFLICT = '#FF1C2D',
                       HOVERED = '#D6B86D';

  static bool cellConflict = false;

  static void add(Map values, {bool auto: false}) {
    if (values['time'] == '') {
      return;
    }

    // Prevent conflict or selected courses from being add
    Storage localStorage = window.localStorage;
    Map selectedCourses = JSON.decode(localStorage['selectedCourses']);
    if (cellConflict || (!auto && selectedCourses.keys.toList().contains(values['code']))) {
      return;
    }

    // Add to localStorage
    selectedCourses[values['code']] = values;
    localStorage['selectedCourses'] = JSON.encode(selectedCourses);

    // Increase credits counter
    var creditsCounter = querySelector('#credits');
    creditsCounter.text = (int.parse(creditsCounter.text) + int.parse(values['credits'])).toString();

    // Add to each cell
    List timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);

      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');

        if (cell.attributes['code'] != null) {
          return;
        } else {
          var timetable = querySelector('#timetable');
          var courseTitle = new AnchorElement()
                ..href = '#'
                ..text = values['title']
                ..onMouseOver.listen((Event e) {
                  var courseDetail = new DivElement()
                        ..attributes['id'] = 'course-detail'
                        ..style.top = (cell.offsetTop + 48).toString() + 'px'
                        ..style.left = (cell.parent.offsetLeft + cell.offsetWidth).toString() + 'px';
                  var title = new SpanElement()
                        ..text = '課程名稱: ${values["title"]}';
                  var professor = new SpanElement()
                        ..text = '授課教授: ${values["professor"]}';
                  var credits = new SpanElement()
                        ..text = '學分數: ${values["credits"]}';
                  var location = new SpanElement()
                        ..text = '授課教室: ${values["location"]}';
                  courseDetail.children.addAll([title, professor, credits, location]);

                  timetable.append(courseDetail);
                })
                ..onMouseLeave.listen((Event e) {
                  var courseDetail = querySelector('#course-detail');
                  courseDetail.remove();
                });

          var courseContent = new SpanElement()
                ..append(courseTitle);

          var course = cell.children[0]
                ..style.backgroundColor = SELECTED
                ..append(courseContent);

          cell
            ..attributes['code'] = values['code']
            ..attributes['time'] = values['time'].trim();
        }
      }
    });

    // Add to selected courses list
    var courseElement = new LIElement()
          ..attributes['class'] = 'subject'
          ..attributes['code'] = values['code']
          ..attributes['time'] = values['time'].trim();

    var courseTitle = new SpanElement()
          ..text = '${values["title"]}';

    var courseCode = new SpanElement()
          ..text = '課程代碼: ${values["code"]}';

    var courseContent = new SpanElement()
          ..text = '${values["professor"]} | 學分數: ${values["credits"]} | ';
    var courseObligatory = new AnchorElement()
          ..text = values["obligatory"];
    if (values["obligatory"] == '必修') {
      courseObligatory.classes.add('obligatory-btn');
    } else if (values["obligatory"] == '選修') {
      courseObligatory.classes.add('elective-btn');
    }
    var courseRemove = new AnchorElement()
          ..text = '移除'
          ..href = '#'
          ..classes.add('remove-btn')
          ..onClick.listen((Event e) {
            String code = values['code'];
            String time = values['time'];
            String credits = values['credits'];
            Cell.remove(code , time, credits);
          });
    courseContent
      ..append(courseObligatory)
      ..append(courseRemove);

    courseElement.children.addAll([courseTitle, courseCode, courseContent]);

    var selectedCoursesList = querySelector('#selected-courses').children[0]
          ..append(courseElement);

    print('Added $values');
  }

  static void remove(String code, String time, String credits) {
    // Remove from localStorage
    Storage localStorage = window.localStorage;
    var selectedCourses = JSON.decode(localStorage['selectedCourses'])
          ..remove(code);
    localStorage['selectedCourses'] = JSON.encode(selectedCourses);

    // Decrease credits counter
    var creditsCounter = querySelector('#credits');
    creditsCounter.text = (int.parse(creditsCounter.text) - int.parse(credits)).toString();

    // Remove from each cell
    var timeList = time.split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);
      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t')
              ..attributes.remove('code')
              ..attributes.remove('time');
        var course = cell.children[0]
              ..attributes.remove('style')
              ..children.clear();
      }
    });

    // Remove from selected courses list
    var selectedCoursesList = querySelector('#selected-courses').children[0];
    for (var li in selectedCoursesList.children) {
      if (li.attributes['code'] == code) {
        li.remove();
        break;
      }
    }

    print('Removed $code');
    print(localStorage['selectedCourses']);
  }

  static void display(Map values, String behave) {
    if (values['time'] == '') {
      return;
    }

    var timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      var day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);

      for (var t in time.split('')) {
        var cell = querySelector('#$day' + '-$t');
        var course = cell.children[0];

        if (behave == 'show') {
          if (cell.attributes['code'] != null) {
            if (cell.attributes['code'] == values['code']) {
              cellConflict = true;
              return;
            } else {
              cellConflict = true;
              course.style.backgroundColor = CONFLICT;
            }
          } else {
            course.style.backgroundColor = HOVERED;
          }
        } else if (behave == 'hide') {
          if (course.innerHtml.isEmpty) {
            course.attributes.remove('style');
          } else {
            course.style.backgroundColor = SELECTED;
          }
          cellConflict = false;
        }
      }
    });
  }

  static void addSelected() {
    Storage localStorage = window.localStorage;
    if (localStorage['selectedCourses'] != null) {
      Map selectedCourses = JSON.decode(localStorage['selectedCourses']);
      for (var value in selectedCourses.values) {
        Cell.add(value, auto: true);
      }
    }
  }
}