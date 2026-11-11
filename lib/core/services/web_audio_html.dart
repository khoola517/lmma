// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

void playWebChime() {
  try {
    if (js.context.hasProperty('khadematyPlayChime')) {
      js.context.callMethod('khadematyPlayChime');
    }
  } catch (_) {}
}
