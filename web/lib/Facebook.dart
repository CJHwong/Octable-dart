library Facebook;

import 'dart:html';
import 'dart:js';

class Facebook {
  static void prepare() {
    Facebook fbObj = new Facebook();
    ButtonElement btn = querySelector('#facebook-login');
    btn.onClick.listen((Event) {
      fbObj.login();
    });
  }

  void login() {
    JsObject fb = context['FB'];
    fb.callMethod('login', [_loginCallback]);
  }

  void logout() {
    JsObject fb = context['FB'];
    fb.callMethod('logout', [_loginCallback]);
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
