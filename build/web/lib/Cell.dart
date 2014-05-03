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
    SpanElement creditsCounter = querySelector('#credits');
    creditsCounter.text = (double.parse(creditsCounter.text) + double.parse(values['credits'])).toString();

    // Add to each cell
    List timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      List days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      String day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);

      for (String t in time.split('')) {
        DivElement cell = querySelector('#$day' + '-$t');

        if (cell.attributes['code'] != null) {
          return;
        } else {
          DivElement timetable = querySelector('#timetable');
          AnchorElement courseTitle = new AnchorElement()
              ..href = '#'
              ..text = values['title']
              ..onClick.listen((Event e) {
                DivElement courseBox = querySelector('#course-box');
                courseBox.remove();

                DivElement detailContainer = new DivElement()
                    ..attributes['id'] = 'popup-container'
                    ..onClick.listen((Event e) {
                      DivElement container = querySelector('#popup-container');
                      container.remove();
                    });
                DivElement detail = new DivElement()..attributes['id'] = 'course-detail';
                SpanElement title = new SpanElement()..text = '課程名稱: ${values["title"]}';
                SpanElement professor = new SpanElement()..text = '授課教授: ${values["professor"]}';
                SpanElement credits = new SpanElement()..text = '學分數: ${values["credits"]}';
                SpanElement location = new SpanElement()..text = '授課教室: ${values["location"]}';
                detail.children.addAll([title, professor, credits, location]);
                detailContainer.append(detail);

                BodyElement body = querySelector('body')..append(detailContainer);
              })
              ..onMouseOver.listen((Event e) {
                DivElement courseBox = new DivElement()
                    ..attributes['id'] = 'course-box'
                    ..style.top = (cell.offsetTop).toString() + 'px'
                    ..style.left = (cell.parent.offsetLeft + cell.offsetWidth).toString() + 'px';
                SpanElement title = new SpanElement()..text = '課程名稱: ${values["title"]}';
                SpanElement professor = new SpanElement()..text = '授課教授: ${values["professor"]}';
                SpanElement credits = new SpanElement()..text = '學分數: ${values["credits"]}';
                SpanElement location = new SpanElement()..text = '授課教室: ${values["location"]}';
                courseBox.children.addAll([title, professor, credits, location]);

                timetable.append(courseBox);
              })
              ..onMouseLeave.listen((Event e) {
                DivElement courseBox = querySelector('#course-box');
                if (courseBox != null) {
                  courseBox.remove();
                }
              });

          SpanElement courseContent = new SpanElement()..append(courseTitle);

          DivElement course = cell.children[0]
              ..style.backgroundColor = SELECTED
              ..append(courseContent);

          cell
              ..attributes['code'] = values['code']
              ..attributes['time'] = values['time'].trim();
        }
      }
    });

    // Add to selected courses list
    LIElement courseElement = new LIElement()
        ..attributes['class'] = 'subject'
        ..attributes['code'] = values['code']
        ..attributes['time'] = values['time'].trim();

    SpanElement courseTitle = new SpanElement()..text = '${values["title"]}';

    SpanElement courseCode = new SpanElement()..text = '課程代碼: ${values["code"]}';

    SpanElement courseContent = new SpanElement()..text = '${values["professor"]} | 學分數: ${values["credits"]} | ';
    AnchorElement courseObligatory = new AnchorElement()..text = values["obligatory"];
    if (values["obligatory"] == '必修') {
      courseObligatory.classes.add('obligatory-btn');
    } else if (values["obligatory"] == '選修') {
      courseObligatory.classes.add('elective-btn');
    }
    AnchorElement courseRemove = new AnchorElement()
        ..text = '移除'
        ..href = '#'
        ..classes.add('remove-btn')
        ..onClick.listen((Event e) {
          String code = values['code'];
          String time = values['time'];
          String credits = values['credits'];
          Cell.remove(code, time, credits);
        });
    courseContent
        ..append(courseObligatory)
        ..append(courseRemove);

    courseElement.children.addAll([courseTitle, courseCode, courseContent]);

    UListElement selectedCoursesList = querySelector('#selected-courses').children[0]..append(courseElement);

    print('Added $values');
  }

  static void remove(String code, String time, String credits) {
    // Remove from localStorage
    Storage localStorage = window.localStorage;
    Map selectedCourses = JSON.decode(localStorage['selectedCourses'])..remove(code);
    localStorage['selectedCourses'] = JSON.encode(selectedCourses);

    // Decrease credits counter
    SpanElement creditsCounter = querySelector('#credits');
    creditsCounter.text = (double.parse(creditsCounter.text) - double.parse(credits)).toString();

    // Remove from each cell
    List timeList = time.split(',');
    timeList.forEach((String time) {
      List days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      String day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);
      for (String t in time.split('')) {
        DivElement cell = querySelector('#$day' + '-$t')
            ..attributes.remove('code')
            ..attributes.remove('time');
        DivElement course = cell.children[0]
            ..attributes.remove('style')
            ..children.clear();
      }
    });

    // Remove from selected courses list
    UListElement selectedCoursesList = querySelector('#selected-courses').children[0];
    for (LIElement li in selectedCoursesList.children) {
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

    List timeList = values['time'].trim().split(',');
    timeList.forEach((String time) {
      List days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
      String day = days[int.parse(time[0]) % 7];
      time = time.substring(1, time.length);

      for (String t in time.split('')) {
        DivElement cell = querySelector('#$day' + '-$t');
        DivElement course = cell.children[0];

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
      for (Map value in selectedCourses.values) {
        Cell.add(value, auto: true);
      }
    }
  }
}
