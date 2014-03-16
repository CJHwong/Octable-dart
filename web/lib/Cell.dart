library Cell;

import 'dart:html';

class Cell {
  void add(Map values) {
      var timeList = values['time'].trim().split(',');
      timeList.forEach((String time) {
        var days = ['sun', 'mon', 'tue', 'wed', 'thr', 'fri', 'sat'];
        var day = days[int.parse(time[0])];
        time = time.substring(1, time.length);

        for (var t in time.split('')) {
          var cell = querySelector('#$day' + '-$t');
          if (cell.children.isNotEmpty) {
            return;
          } else {
            var courseContent = new SpanElement();
            courseContent.text = values['title'];
            var course = new DivElement();
            course.classes.add('course');
            course.append(courseContent);

            cell.attributes['code'] = values['code'];
            cell.attributes['time'] = values['time'].trim();
            cell.classes.add('activedCell');
            cell.append(course);

            cell.onDoubleClick.listen((Event e) {
              var cell = e.target;
              remove(cell);
            });
          }
        }
      });
    }

  void remove(var clickedCell) {
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
}