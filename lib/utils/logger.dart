import 'dart:developer' as developer;

class Logger {
  static void info(String message, [Map<String, Object?>? params]) {
    developer.log(
      message,
      name: 'mozzfood.info',
      error: null,
      sequenceNumber: null,
      level: 800,
      zone: null,
    );
  }

  static void warn(String message, [Object? error]) {
    developer.log(message, name: 'mozzfood.warn', error: error, level: 900);
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    developer.log(message, name: 'mozzfood.error', error: error, level: 1000);
    if (stack != null)
      developer.log(stack.toString(), name: 'mozzfood.error.stack');
  }
}
