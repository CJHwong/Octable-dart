library ExportSVG;

import 'dart:html';
import 'dart:convert';
import 'dart:svg';

class ExportSVG {
  static SvgSvgElement bindCourse(SvgSvgElement svg) {
    Storage localStorage = window.localStorage;
    Map selectedCourses = JSON.decode(localStorage['selectedCourses']);
    
    for (var key in selectedCourses.keys) {
      for (String day in selectedCourses[key]['time'].split(',')) {
        var date = int.parse(day[0]);
        var times = day.substring(1, day.length).split('');
        for (var time in times) {
          time = int.parse(time);
          
          var text = new TextElement()
              ..attributes['x'] = (45/3 + 91 * (date-1)).toString()
              ..attributes['y'] = (20/3 + 40 * time).toString()
              ..attributes['font-size'] = '12'
              ..text = selectedCourses[key]['title'];
          
          svg.append(text);
        }
      }
    }
    
    return svg;
  }
    
  static SvgSvgElement createTable() {
    var svg = new SvgSvgElement()
          ..attributes['id'] = 'export-svg'
          ..attributes['baseProfile'] = 'full'
          ..attributes['width'] = '637'
          ..attributes['height'] = '620'
          ..attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    // Draw Cells
    for (var i = 0; i < 15; i++) {
      var rect = new RectElement()
            ..attributes['x'] = '0'
            ..attributes['width'] = '100%';
      if (i == 0) {
        rect.attributes['height'] = '20';
      } else {
        rect.attributes['height'] = '40';
      }
      
      if (i % 2 != 0 || i == 1) {
        rect.attributes['fill'] = '#E5E5E5';
      } else {
        rect.attributes['fill'] = 'white';
      }
      
      rect.attributes['y'] = (i > 0 ? 20 + 40 * (i - 1):0).toString();
      
      svg.append(rect);
    }
    
    // Draw Days
    var days = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
    for (var i = 0; i < 7; i++) {
      var text = new TextElement()
            ..attributes['x'] = (45 + 91 * i).toString()
            ..attributes['y'] = '15'
            ..attributes['font-size'] = '12'
            ..attributes['text-anchor'] = 'middle'
            ..attributes['fill'] = 'grey'
            ..text = days[i];      
      
      svg.append(text);
    }
    
    svg = ExportSVG.bindCourse(svg);
    
    return svg;
  }
  
  static void exportToSVG() {
    var body = querySelector('body')
          ..style.overflow = 'hidden';
    var container = new DivElement()
          ..id = 'popup-container'
          ..append(ExportSVG.createTable())
          ..onClick.listen((Event e) {
            var popupContainer = querySelector('#popup-container');
            popupContainer.remove();
            body.attributes.remove('style');
          });

    body.append(container);
  }
}