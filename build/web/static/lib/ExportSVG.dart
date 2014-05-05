library ExportSVG;

import 'dart:html';
import 'dart:convert';
import 'dart:svg';
import 'package:utf/utf.dart';
import 'package:crypto/crypto.dart';

class ExportSVG {
  static SvgSvgElement bindCourse(SvgSvgElement svg) {
    Storage localStorage = window.localStorage;
    Map selectedCourses = JSON.decode(localStorage['selectedCourses']);

    for (String key in selectedCourses.keys) {
      for (String day in selectedCourses[key]['time'].split(',')) {
        int date = int.parse(day[0]);
        List times = day.substring(1, day.length).split('');
        for (var time in times) {
          Map to_time = {
            '1': 1,
            '2': 2,
            '3': 3,
            '4': 4,
            'N': 5,
            '5': 6,
            '6': 7,
            '7': 8,
            '8': 9,
            '9': 10,
            'A': 11,
            'B': 12,
            'C': 13,
            'D': 14
          };
          time = to_time[time];

          String x = (45 / 3 + 91 * (date - 1)).toString();

          TextElement text = new TextElement()
              ..attributes['width'] = '91'
              ..attributes['height'] = '40'
              ..attributes['x'] = x
              ..attributes['y'] = (20 / 5 + 40 * time).toString()
              ..attributes['font-size'] = '12';

          List title = [];
          for (int i = 0; i < selectedCourses[key]['title'].length; i += 5) {
            int end = i + 5 < selectedCourses[key]['title'].length ? i + 5 : selectedCourses[key]['title'].length;
            title.add(selectedCourses[key]['title'].substring(i, end));
          }
          for (String part in title) {
            TSpanElement tspan = new TSpanElement()
                ..attributes['x'] = x
                ..attributes['dy'] = (13 * title.indexOf(part)).toString()
                ..text = part;

            text.append(tspan);
          }

          svg.append(text);
        }
      }
    }

    return svg;
  }

  static SvgSvgElement createTable() {
    SvgSvgElement svg = new SvgSvgElement()
        ..attributes['version'] = '1.2'
        ..attributes['id'] = 'export-svg'
        ..attributes['baseProfile'] = 'full'
        ..attributes['width'] = '637'
        ..attributes['height'] = '580'
        ..attributes['xmlns'] = 'http://www.w3.org/2000/svg';
    // Draw Cells
    for (int i = 0; i < 15; i++) {
      RectElement rect = new RectElement()
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

      rect.attributes['y'] = (i > 0 ? 20 + 40 * (i - 1) : 0).toString();

      svg.append(rect);
    }

    // Draw Days
    List days = ['Mon', 'Tue', 'Wed', 'Thr', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < 7; i++) {
      TextElement text = new TextElement()
          ..attributes['x'] = (45 + 91 * i).toString()
          ..attributes['y'] = '15'
          ..attributes['font-size'] = '12'
          ..attributes['text-anchor'] = 'middle'
          ..attributes['fill'] = 'grey'
          ..text = days[i];

      svg.append(text);
    }

    svg = bindCourse(svg);

    return svg;
  }

  static String toDataUrl() {
    List bytes = encodeUtf8(ExportSVG.createTable().outerHtml);
    String base64 = CryptoUtils.bytesToBase64(bytes);
    return 'data:image/svg+xml;base64,' + base64;
  }

  static void displaySVG() {
    BodyElement body = querySelector('body')..style.overflow = 'hidden';
    DivElement container = new DivElement()
        ..id = 'popup-container'
        ..append(ExportSVG .createTable())
        ..onClick.listen((Event e) {
          DivElement popupContainer = querySelector('#popup-container');
          popupContainer.remove();
          body.attributes.remove('style');
        });

    body.append(container);
  }
}
