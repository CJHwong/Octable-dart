library Octable;

import 'lib/UI.dart';
import 'lib/Facebook.dart';

void main() {
  new UI(college: 'nchu', version: 1).load();
  Facebook.prepare();
}
