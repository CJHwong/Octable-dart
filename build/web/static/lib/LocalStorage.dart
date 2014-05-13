library LocalStorage;

import 'dart:html';

class LocalStorage {
  static Storage _localStorage = window.localStorage;

  static void set(String target, String value) {
    _localStorage[target] = value;
  }

  static String get(String target) {
    return _localStorage[target];
  }

  static bool has(String target) {
    return _localStorage[target] != null ? true : false;
  }
}
