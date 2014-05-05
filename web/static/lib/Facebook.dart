library Facebook;

import 'dart:html';
import 'dart:js';
import 'ExportSVG.dart';

class Facebook {
  static void prepare() {
    Facebook fbObj = new Facebook();
    fbObj.init();

    ButtonElement loginBtn = querySelector('#facebook-login');
    if (fbObj.signin()) {
      loginBtn.text = 'Logout';
    } else {
      loginBtn.text = 'Login';
    }
    loginBtn.onClick.listen((Event) {
      fbObj.login();
    });

    ButtonElement shareBtn = querySelector('#facebook-share');
    shareBtn.onClick.listen((Event) {
      fbObj.share();
    });
  }

  void init() {
    JsObject fb = context['FB'];
    JsObject p = new JsObject.jsify({
      'appId': '751950231512641',
      'xfbml': true,
      'version': 'v2.0'
    });
    fb.callMethod('init', [p]);
  }

  bool signin() {
    JsObject fb = context['FB'];
    if (fb.callMethod('getAccessToken', []) != null) {
      return true;
    } else {
      return false;
    }
  }

  void login() {
    JsObject fb = context['FB'];
    JsObject perm = new JsObject.jsify({
      'scope': 'email, public_profile, user_friends'
    });
    fb.callMethod('login', [_loginCallback, perm]);
  }

  void logout() {
    JsObject fb = context['FB'];
    fb.callMethod('logout', [_loginCallback]);
  }

  void share() {
    JsObject fb = context['FB'];
    JsObject content = new JsObject.jsify({
      'method': 'feed',
      'name': 'Octable',
      'caption': 'Your time scheduler',
      'description': 'Hey! Come to see my timetable of this semester!',
      'source': ExportSVG.toDataUrl()
    });
    fb.callMethod('ui', [content, _shareCallback]);
  }

  void _shareCallback(JsObject response) {
    if (response == null || response['error'] != null) {
      print('Error occured');
    } else {
      print('Post ID: ' + response['id'].toString());
    }
  }

  void _loginCallback(response) {
    Facebook fbObj = new Facebook();
    JsObject fb = context['FB'];
    if (fb.callMethod('getAuthResponse', []) != null) {
      ButtonElement btn = querySelector('#facebook-login')
          ..text = 'Logout'
          ..onClick.listen((Event) {
            fbObj.logout();
          });
    } else {
      ButtonElement btn = querySelector('#facebook-login')
          ..text = 'Login'
          ..onClick.listen((Event) {
            fbObj.login();
          });
    }
  }
}
